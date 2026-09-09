#include "MusicLibraryModel.h"
#include <QDirIterator>
#include <QFileInfo>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <algorithm>

MusicLibraryModel::MusicLibraryModel(QObject * parent) : QAbstractListModel(parent){}

int MusicLibraryModel::rowCount(const QModelIndex & parent) const
{
    if(parent.isValid())
        return 0;
    return m_tracks.size();
}

int MusicLibraryModel::count() const
{
    return m_tracks.size();
}

QVariant MusicLibraryModel::data(const QModelIndex & index,int role) const
{
    if(!index.isValid())
        return {};

    if(index.row() < 0 || index.row() >= m_tracks.size())
        return {};

    const MusicTrack & track = m_tracks[index.row()];
    switch(role)
    {
    case FilePathRole:
        return track.filePath;
    case TitleRole:
        return track.title;
    case ArtistRole:
        return track.artist;
    case AlbumRole:
        return track.album;
    case DurationRole:
        return track.duration;
    case FavoriteRole:
        return track.favorite;
    case LastPlayedRole:
        return track.lastPlayed;
    default:
        return {};
    }
}

QHash<int,QByteArray> MusicLibraryModel::roleNames() const
{
    return {
        {FilePathRole, "filePath"},
        {TitleRole, "title"},
        {ArtistRole,"artist"},
        {AlbumRole,"album"},
        {DurationRole,"duration"},
        {FavoriteRole,"favorite"},
        {LastPlayedRole,"lastPlayed"}
    };
}

void MusicLibraryModel::scanDirectory(const QString & directory)
{
    beginResetModel();
    m_tracks.clear();
    QStringList filters {
        "*.mp3",
        "*.wav",
        "*.flac",
        "*.m4a",
        "*.aac",
        "*.ogg"
    };
    //从哪里开始扫描   哪些文件名符合要求  只要求扫描文件  递归扫描子目录
    QDirIterator iterator(directory,filters,QDir::Files,QDirIterator::Subdirectories);
    while(iterator.hasNext())
    {
        QString filePath = iterator.next();
        QFileInfo info(filePath);
        MusicTrack track;
        track.filePath = info.absoluteFilePath();
        QString baseName = info.completeBaseName();
        QStringList parts = baseName.split(" - ");
        //提取文件名中的序号 歌曲 歌手
        if(parts.size() >= 3)
        {
            track.title = parts[1].trimmed();
            track.artist = parts[2].trimmed();
            track.album = track.title + " (单曲)";
        }else if(parts.size() == 2)
        {
            track.title = parts[0].trimmed();
            track.artist = parts[1].trimmed();
            track.album = track.title + " (单曲)";
        }else {
            track.title = baseName;
            track.artist = "未知歌手";
            track.album = "热门单曲";
        }
        //读取同名.lrc文件解析最后一行的时间戳得到毫秒总时长
        QString lrcPath = info.absolutePath() + "/" + baseName + ".lrc";
        QFile lrcFile(lrcPath);
        if(lrcFile.exists() && lrcFile.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            QTextStream stream(&lrcFile);
            static const QRegularExpression regex(R"(\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\])");
            qint64 lastTimestamp = 0;
            while(!stream.atEnd())
            {
                QString line = stream.readLine();
                QRegularExpressionMatchIterator it = regex.globalMatch(line);
                while(it.hasNext())
                {
                    QRegularExpressionMatch match = it.next();
                    int mm = match.captured(1).toInt();     //分
                    int ss = match.captured(2).toInt();     //秒
                    QString frac = match.captured(3);
                    int ms = 0;
                    if(frac.length() == 1)
                    {
                        ms = frac.toInt() * 100;
                    }else if(frac.length() == 2)
                    {
                        ms = frac.toInt() * 10;
                    }else if(frac.length() >= 3)
                    {
                        ms = frac.left(3).toInt();
                    }
                    qint64 t = (mm * 60 + ss) * 1000 + ms;
                    if(t > lastTimestamp)
                        lastTimestamp = t;
                }
            }
            if(lastTimestamp > 0)
            {
                track.duration = lastTimestamp + 5000;
            }
            lrcFile.close();
        }
        if(track.duration <= 0 && info.size() > 0)
        {
            track.duration = (info.size() / 16000) * 1000;  //兜底估算
        }
        m_tracks.append(track);
    }
    std::sort(m_tracks.begin(),m_tracks.end(),[](const MusicTrack & a,const MusicTrack & b){
        return a.filePath.localeAwareCompare(b.filePath) < 0;
    });
    endResetModel();
    emit countChanged();
}


//更新MP3元数据信息
void MusicLibraryModel::updateMetadata(int index,const QString &title,const QString &artist,const QString &album,qint64 duration)
{
    if(index < 0 || index >= m_tracks.size())
        return;

    MusicTrack & track = m_tracks[index];
    if(!title.isEmpty())
        track.title = title;
    if(!artist.isEmpty())
        track.artist = artist;
    if(!album.isEmpty())
        track.album = album;
    if(duration > 0)
        track.duration = duration;
    //index成员函数继承自QAbstractListModel  将index行转换为QModelIndex
    QModelIndex modelIndex = this->index(index);
    //继承自QAbstractItemModel的方法 QAbstractItemModel 是 QAbstractListModel的父类  从哪一行开始变化 到哪一行变化结束 哪些role发生了变化
    emit dataChanged(modelIndex,modelIndex,{TitleRole,ArtistRole,AlbumRole,DurationRole});
}

//最近播放
void MusicLibraryModel::markPlayed(int index)
{
    if(index < 0 || index >= m_tracks.size())
        return;
    m_tracks[index].lastPlayed = QDateTime::currentDateTime();
    QModelIndex modelIndex = this->index(index);
    emit dataChanged(modelIndex,modelIndex,{LastPlayedRole});
}

//喜欢歌曲
void MusicLibraryModel::toggleFavorite(int index)
{
    if(index < 0 || index >= m_tracks.size())
        return;
    m_tracks[index].favorite = !m_tracks[index].favorite;
    QModelIndex modelIndex = this->index(index);
    emit dataChanged(modelIndex,modelIndex,{FavoriteRole});
}

//获取歌曲
MusicTrack MusicLibraryModel::trackAt(int index) const
{
    if(index < 0 || index >= m_tracks.size())
        return {};
    return m_tracks[index];
}

void MusicLibraryModel::setLyrics(int index,const QVector<LyricLine> &lyrics)
{
    if(index < 0 || index >= m_tracks.size())
        return;
    m_tracks[index].lyrics = lyrics;
}


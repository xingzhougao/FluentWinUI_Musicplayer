#pragma once

#include <QAbstractListModel>
#include <QVector>

#include "MusicTrack.h"

class MusicLibraryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        FilePathRole = Qt::UserRole + 1,
        TitleRole,
        ArtistRole,
        AlbumRole,
        DurationRole,
        FavoriteRole,
        LastPlayedRole
    };

    Q_ENUM(Roles)

    explicit MusicLibraryModel (QObject * parent = nullptr);
    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role) const override;
    QHash<int,QByteArray> roleNames() const override;
    int count() const;

    //扫描一个音乐目录
    Q_INVOKABLE void scanDirectory(const QString & directory);
    //喜欢/取消喜欢
    Q_INVOKABLE void toggleFavorite(int index);
    //获取歌曲
    MusicTrack trackAt(int index) const;
    //QMediaPlayer读取元数据后更新Model
    void updateMetadata(int index,const QString &title,const QString &artist,const QString &album,qint64 duration);
    //标记最近播放
    void markPlayed(int index);
    void setLyrics(int index,const QVector<LyricLine> &lyrics);

signals:
    void countChanged();

private:
    QVector<MusicTrack> m_tracks;
};

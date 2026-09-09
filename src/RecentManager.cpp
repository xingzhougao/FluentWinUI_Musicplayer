#include "RecentManager.h"
#include <QFileInfo>
#include <QDebug>

RecentManager::RecentManager(QObject * parent)
    : QObject(parent)
    , m_model(new MusicLibraryModel(this))
{
    connect(m_model, &MusicLibraryModel::countChanged, this, &RecentManager::countChanged);
    loadRecentTracks();
}

MusicLibraryModel* RecentManager::model() const
{
    return m_model;
}

int RecentManager::count() const
{
    return m_model ? m_model->count() : 0;
}

QString RecentManager::getIniPath() const
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QDir dir(configDir);
    if (!dir.exists())
        dir.mkpath(".");
    return dir.filePath("recent_tracks.ini");
}

void RecentManager::recordTrack(const MusicTrack & track)
{
    if (track.filePath.isEmpty())
        return;

    int existingIndex = m_model->indexOfFilePath(track.filePath);
    if (existingIndex == 0)
    {
        // 已经是首位，更新最新播放时间并保存
        m_model->markPlayed(0);
        saveRecentTracks();
        return;
    }

    if (existingIndex > 0)
    {
        // 已经存在，平滑移到第 1 首（index 0）
        m_model->moveTrack(existingIndex, 0);
        m_model->markPlayed(0);
    }
    else
    {
        // 不在列表中，在最前面插入新纪录
        MusicTrack newTrack = track;
        newTrack.lastPlayed = QDateTime::currentDateTime();
        m_model->insertTrack(0, newTrack);
    }

    // 保证最多保留 100 首
    while (m_model->count() > 100)
    {
        m_model->removeTrack(m_model->count() - 1);
    }

    saveRecentTracks();
    emit countChanged();
}

void RecentManager::clearHistory()
{
    m_model->clear();
    saveRecentTracks();
    emit countChanged();
}

void RecentManager::removeTrack(int index)
{
    if (index < 0 || index >= m_model->count())
        return;
    m_model->removeTrack(index);
    saveRecentTracks();
    emit countChanged();
}

void RecentManager::loadRecentTracks()
{
    QString path = getIniPath();
    if (!QFile::exists(path))
        return;

    QSettings settings(path, QSettings::IniFormat);
    int size = settings.beginReadArray(QStringLiteral("recent_tracks"));
    for (int i = 0; i < size && i < 100; ++i)
    {
        settings.setArrayIndex(i);
        QString filePath = settings.value(QStringLiteral("filePath")).toString();
        if (filePath.isEmpty() || !QFileInfo::exists(filePath))
            continue;

        MusicTrack track;
        track.filePath = filePath;
        track.title = settings.value(QStringLiteral("title")).toString();
        track.artist = settings.value(QStringLiteral("artist")).toString();
        track.album = settings.value(QStringLiteral("album")).toString();
        track.duration = settings.value(QStringLiteral("duration")).toLongLong();
        track.favorite = settings.value(QStringLiteral("favorite")).toBool();
        QString lastPlayedStr = settings.value(QStringLiteral("lastPlayed")).toString();
        if (!lastPlayedStr.isEmpty())
            track.lastPlayed = QDateTime::fromString(lastPlayedStr, Qt::ISODate);

        m_model->appendTrack(track);
    }
    settings.endArray();
    qDebug() << "加载最近播放记录完成，共" << m_model->count() << "首";
}

void RecentManager::saveRecentTracks()
{
    QString path = getIniPath();
    QSettings settings(path, QSettings::IniFormat);
    settings.clear();
    settings.beginWriteArray(QStringLiteral("recent_tracks"), m_model->count());
    for (int i = 0; i < m_model->count(); ++i)
    {
        settings.setArrayIndex(i);
        const MusicTrack track = m_model->trackAt(i);
        settings.setValue(QStringLiteral("filePath"), track.filePath);
        settings.setValue(QStringLiteral("title"), track.title);
        settings.setValue(QStringLiteral("artist"), track.artist);
        settings.setValue(QStringLiteral("album"), track.album);
        settings.setValue(QStringLiteral("duration"), track.duration);
        settings.setValue(QStringLiteral("favorite"), track.favorite);
        settings.setValue(QStringLiteral("lastPlayed"), track.lastPlayed.toString(Qt::ISODate));
    }
    settings.endArray();
    settings.sync();
}

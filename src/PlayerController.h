#pragma once

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QVector>
#include <QString>
#include <QVariantList>
#include <QPointer>

#include "MusicLibraryModel.h"

class RecentManager;
class FavoriteManager;

class PlayerController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title NOTIFY trackChanged)
    Q_PROPERTY(QString artist READ artist NOTIFY trackChanged)
    Q_PROPERTY(bool playing READ playing NOTIFY playingChanged)
    Q_PROPERTY(double progress READ progress WRITE setProgress NOTIFY progressChanged)
    Q_PROPERTY(double volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(bool favorite READ favorite NOTIFY favoriteChanged)
    Q_PROPERTY(int playMode READ playMode WRITE setPlayMode NOTIFY playModeChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QString currentLyric READ currentLyric NOTIFY currentLyricChanged)
    Q_PROPERTY(QVariantList lyricList READ lyricList NOTIFY lyricListChanged)
    Q_PROPERTY(int currentLyricIndex READ currentLyricIndex NOTIFY currentLyricIndexChanged)
    Q_PROPERTY(MusicLibraryModel* currentLibrary READ currentLibrary NOTIFY currentLibraryChanged)

public:
    explicit PlayerController(MusicLibraryModel * library,QObject * parent = nullptr);
    QString title() const;
    QString currentLyric() const;
    QVariantList lyricList() const;
    int currentLyricIndex() const;
    QString artist() const;
    bool playing() const;
    double progress() const;
    double volume() const;
    qint64 position() const;
    qint64 duration() const;
    bool muted() const;
    bool favorite() const;
    int playMode() const;
    int currentIndex() const;
    MusicLibraryModel * currentLibrary() const;
    Q_INVOKABLE void setLibrary(MusicLibraryModel * library);
    void setRecentManager(RecentManager * manager);
    void setFavoriteManager(FavoriteManager * manager);
    Q_INVOKABLE void togglePlay();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void restart();
    //用户在歌曲列表点击一首歌
    Q_INVOKABLE void playIndex(int index);
    Q_INVOKABLE void toggleFavorite();
    Q_INVOKABLE QString formatTime(qint64 milliseconds) const;
    Q_INVOKABLE void seek(qint64 milliseconds);
    Q_INVOKABLE void seekToLyric(int index);
    Q_INVOKABLE void playFromModel(MusicLibraryModel * library,int index);

public slots:
    void setProgress(double value);
    void setVolume(double value);
    void setMuted(bool muted);
    void setPlayMode(int mode);

signals:
    void trackChanged();
    void playingChanged();
    void progressChanged();
    void volumeChanged();
    void positionChanged();
    void durationChanged();
    void mutedChanged();
    void favoriteChanged();
    void playModeChanged();
    void currentIndexChanged();
    void currentLyricChanged();
    void lyricListChanged();
    void currentLyricIndexChanged();
    void playbackError(const QString &message);
    void currentLibraryChanged();

private:
    void selectTrack(int index,bool autoPlay = true);
    void readMetaData();
    void handleEndOfMedia();
    void loadLyrics(int index);
    void updateCurrentLyric(qint64 position);

private:
    QPointer<MusicLibraryModel> m_library = nullptr;
    QMediaPlayer * m_player = nullptr;
    QAudioOutput * m_audioOutput = nullptr;
    int m_index = -1;
    //0 顺序 1随机 2单曲循环
    int m_playMode = 0;
    QString m_currentLyric;
    int m_currentLyricIndex = -1;
    QVariantList m_lyricList;
    RecentManager * m_recentManager = nullptr;
    FavoriteManager * m_favoriteManager = nullptr;
};

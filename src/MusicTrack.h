#pragma once

#include <QString>
#include <QDateTime>
#include <QVector>
#include "Lyric.h"

struct MusicTrack{
    QString filePath;
    QString title;
    QString artist;
    QString album;
    qint64 duration = 0;
    bool favorite = false;
    //最近播放时间
    QDateTime lastPlayed;
    //当前歌曲的歌词
    QVector<LyricLine> lyrics;
};


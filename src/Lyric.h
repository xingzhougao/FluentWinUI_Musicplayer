#pragma once
#include <QString>
#include <QtGlobal>

struct LyricLine
{
    qint64 timeMs = 0;  //这一句歌词出现的时间 单位ms
    QString text;
};

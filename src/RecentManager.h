#pragma once

#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include "MusicTrack.h"
#include "MusicLibraryModel.h"

class RecentManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MusicLibraryModel* model READ model CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit RecentManager(QObject * parent = nullptr);
    ~RecentManager() override = default;

    MusicLibraryModel* model() const;
    int count() const;

    // 记录一首已播放的歌曲（去重置顶，上限100首）
    Q_INVOKABLE void recordTrack(const MusicTrack & track);

    // 清空历史播放记录
    Q_INVOKABLE void clearHistory();

    // 移除单首历史记录
    Q_INVOKABLE void removeTrack(int index);

    // 加载与保存 ini 配置文件
    void loadRecentTracks();
    void saveRecentTracks();

signals:
    void countChanged();

private:
    QString getIniPath() const;

private:
    MusicLibraryModel * m_model = nullptr;
};

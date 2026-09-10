#pragma once

#include <QObject>
#include <QList>
#include <QVariantList>
#include <QVariantMap>
#include "MusicLibraryModel.h"

class FavoriteManager;

struct PlaylistEntry {
    QString id;
    QString name;
    QString coverUrl;
    MusicLibraryModel* model = nullptr;
};

class PlaylistManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int playlistCount READ playlistCount NOTIFY playlistsChanged)
    Q_PROPERTY(QVariantList playlists READ getPlaylists NOTIFY playlistsChanged)

public:
    explicit PlaylistManager(QObject * parent = nullptr);
    ~PlaylistManager() override;

    int playlistCount() const;

    // 获取所有歌单信息摘要列表（用于 QML 渲染卡片）
    Q_INVOKABLE QVariantList getPlaylists() const;

    // 新建歌单，返回新建的歌单 ID
    Q_INVOKABLE QString createPlaylist(const QString & name, const QString & coverUrl = "");

    // 删除指定歌单
    Q_INVOKABLE bool deletePlaylist(const QString & id);

    // 获取指定歌单的 Model（用于歌曲列表渲染与播放）
    Q_INVOKABLE MusicLibraryModel* getPlaylistModel(const QString & id) const;

    // 获取指定歌单名称
    Q_INVOKABLE QString getPlaylistName(const QString & id) const;

    // 获取指定歌单封面
    Q_INVOKABLE QString getPlaylistCover(const QString & id) const;

    // 向歌单添加歌曲
    Q_INVOKABLE bool addTrackToPlaylist(const QString & playlistId, MusicLibraryModel* source, int sourceIndex);

    // 从歌单移除歌曲
    Q_INVOKABLE bool removeTrackFromPlaylist(const QString & playlistId, int trackIndex);

    // 移动歌单内歌曲顺序
    Q_INVOKABLE bool moveTrackInPlaylist(const QString & playlistId, int fromIndex, int toIndex);

    // 检查歌曲是否已在歌单中
    Q_INVOKABLE bool playlistContainsTrack(const QString & playlistId, const QString & filePath) const;

    // 持久化保存与加载
    void loadPlaylists();
    void savePlaylists();
    void setFavoriteManager(FavoriteManager * manager);

signals:
    void playlistsChanged();

private:
    QString getSaveFilePath() const;
    MusicTrack resolveTrackFromFile(const QString & filePath) const;

private:
    QList<PlaylistEntry> m_playlists;
    FavoriteManager * m_favoriteManager = nullptr;
};

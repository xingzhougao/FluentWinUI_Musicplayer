#pragma once

#include <QObject>
#include <QSet>
#include <QList>
#include "MusicTrack.h"

class MusicLibraryModel;

class FavoriteManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit FavoriteManager(QObject * parent = nullptr);
    ~FavoriteManager() override = default;

    MusicLibraryModel * model() const;
    int count() const;

    //检查是否收藏
    Q_INVOKABLE bool isFavorite(const QString & filePath) const;
    //切换收藏状态
    Q_INVOKABLE void toggleFavoriteTrack(const MusicTrack & track);
    Q_INVOKABLE void setTrackFavorite(const MusicTrack & track,bool favorite);

    //注册关联Model 用于全局状态双向同步
    void registerModel(MusicLibraryModel * model);
    void unregisterModel(MusicLibraryModel * model);
    void applyToModel(MusicLibraryModel * model);

    //INI持久化
    void loadFavorites();
    void saveFavorites();

signals:
    void countChanged();
    void favoriteChanged(const QString & filePath,bool isFavorite);

private:
    QString getIniPath() const;
    void syncFavoriteToModels(const QString & filePath,bool isFavorite);
    MusicLibraryModel * m_model = nullptr;
    QSet<QString> m_favoritePaths;
    QList<MusicLibraryModel *> m_registeredModels;
};

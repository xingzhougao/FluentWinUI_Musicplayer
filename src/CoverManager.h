#pragma once

#include <QObject>
#include <QString>
#include <QImage>
#include <QHash>
#include <QMutex>

class CoverManager : public QObject
{
    Q_OBJECT

public:
    static CoverManager & instance();

    // 根据音频文件路径获取封面 URL（返回 file:/// 协议本地路径；若无封面返回空字符串）
    Q_INVOKABLE QString getCoverUrl(const QString & audioFilePath);

    // 清空缓存与内存映射
    void clearCache();

private:
    explicit CoverManager(QObject * parent = nullptr);
    ~CoverManager() override = default;
    Q_DISABLE_COPY(CoverManager)

    // 核心提取函数
    QImage extractCover(const QString & filePath);
    QImage extractFromMp3(const QString & filePath);
    QImage extractFromFlac(const QString & filePath);
    QImage extractFromM4a(const QString & filePath);
    QString searchCompanionImage(const QString & filePath);

    QString ensureCacheDir();

    mutable QMutex m_mutex;
    QHash<QString, QString> m_memoryCache; // filePath -> coverUrl
    QString m_cacheDir;
};

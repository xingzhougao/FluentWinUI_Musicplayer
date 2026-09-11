#include "CoverManager.h"
#include "AppConfig.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QUrl>
#include <QtEndian>
#include <QDebug>

CoverManager & CoverManager::instance()
{
    static CoverManager mgr;
    return mgr;
}

CoverManager::CoverManager(QObject * parent)
    : QObject(parent)
{
    ensureCacheDir();
}

QString CoverManager::ensureCacheDir()
{
    if (m_cacheDir.isEmpty())
    {
        m_cacheDir = AppConfig::instance().configDir() + QStringLiteral("/covers");
    }
    QDir dir(m_cacheDir);
    if (!dir.exists())
    {
        dir.mkpath(QStringLiteral("."));
    }
    return m_cacheDir;
}

void CoverManager::clearCache()
{
    QMutexLocker locker(&m_mutex);
    m_memoryCache.clear();
}

QString CoverManager::searchCompanionImage(const QString & filePath)
{
    QFileInfo audioInfo(filePath);
    if (!audioInfo.exists())
        return {};

    QDir dir = audioInfo.dir();
    const QString baseName = audioInfo.completeBaseName();

    // 优先匹配同名图片
    const QStringList nameCandidates = {
        baseName + QStringLiteral(".jpg"),
        baseName + QStringLiteral(".png"),
        baseName + QStringLiteral(".jpeg"),
        baseName + QStringLiteral(".webp"),
        QStringLiteral("cover.jpg"),
        QStringLiteral("cover.png"),
        QStringLiteral("folder.jpg"),
        QStringLiteral("folder.png"),
        QStringLiteral("album.jpg")
    };

    for (const QString & name : nameCandidates)
    {
        QString candidatePath = dir.filePath(name);
        if (QFile::exists(candidatePath))
        {
            return QUrl::fromLocalFile(candidatePath).toString();
        }
    }

    return {};
}

QImage CoverManager::extractFromMp3(const QString & filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    // 读取 ID3v2 头部 (10 字节)
    QByteArray header = file.read(10);
    if (header.size() < 10 || !header.startsWith("ID3"))
        return {};

    quint8 vMajor = static_cast<quint8>(header[3]);
    // ID3v2 标签大小为 7 位安全整数
    quint32 tagSize = ((static_cast<quint8>(header[6]) & 0x7F) << 21) |
                      ((static_cast<quint8>(header[7]) & 0x7F) << 14) |
                      ((static_cast<quint8>(header[8]) & 0x7F) << 7)  |
                      (static_cast<quint8>(header[9]) & 0x7F);

    if (tagSize == 0 || tagSize > 25 * 1024 * 1024) // 限制最大 25MB
        return {};

    QByteArray tagData = file.read(tagSize);
    file.close();

    // 查找 APIC 帧（ID3v2.3 / ID3v2.4）或 PIC 帧（ID3v2.2）
    int frameIdx = -1;
    if (vMajor >= 3)
    {
        frameIdx = tagData.indexOf("APIC");
    }
    else if (vMajor == 2)
    {
        frameIdx = tagData.indexOf("PIC");
    }

    if (frameIdx < 0)
        return {};

    // 在 APIC 帧之后寻找 JPEG / PNG 图像魔数特征
    // JPEG: 0xFF, 0xD8, 0xFF
    // PNG:  0x89, 'P', 'N', 'G'
    const char jpegMagic[] = "\xFF\xD8\xFF";
    const char pngMagic[]  = "\x89PNG";

    int imgStart = tagData.indexOf(QByteArray(jpegMagic, 3), frameIdx);
    if (imgStart < 0)
    {
        imgStart = tagData.indexOf(QByteArray(pngMagic, 4), frameIdx);
    }

    if (imgStart > 0 && imgStart < tagData.size())
    {
        QByteArray imgData = tagData.mid(imgStart);
        QImage image;
        if (image.loadFromData(imgData))
        {
            return image;
        }
    }

    return {};
}

QImage CoverManager::extractFromFlac(const QString & filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QByteArray magic = file.read(4);
    if (magic != "fLaC")
        return {};

    while (!file.atEnd())
    {
        QByteArray blockHeader = file.read(4);
        if (blockHeader.size() < 4)
            break;

        bool isLast = (static_cast<quint8>(blockHeader[0]) & 0x80) != 0;
        quint8 blockType = static_cast<quint8>(blockHeader[0]) & 0x7F;
        quint32 blockSize = (static_cast<quint8>(blockHeader[1]) << 16) |
                            (static_cast<quint8>(blockHeader[2]) << 8)  |
                             static_cast<quint8>(blockHeader[3]);

        if (blockType == 6) // METADATA_BLOCK_PICTURE
        {
            QByteArray blockData = file.read(blockSize);
            if (blockData.size() >= 32)
            {
                // 解析 FLAC 图片块
                quint32 mimeLen = qFromBigEndian<quint32>(reinterpret_cast<const uchar*>(blockData.constData() + 4));
                int pos = 8 + mimeLen;
                if (pos + 4 <= blockData.size())
                {
                    quint32 descLen = qFromBigEndian<quint32>(reinterpret_cast<const uchar*>(blockData.constData() + pos));
                    pos += 4 + descLen + 16; // 跳过描述与宽度、高度、位深、颜色数 (共16字节)
                    if (pos + 4 <= blockData.size())
                    {
                        quint32 dataLen = qFromBigEndian<quint32>(reinterpret_cast<const uchar*>(blockData.constData() + pos));
                        pos += 4;
                        if (pos + dataLen <= static_cast<quint32>(blockData.size()))
                        {
                            QByteArray picData = blockData.mid(pos, dataLen);
                            QImage img;
                            if (img.loadFromData(picData))
                            {
                                return img;
                            }
                        }
                    }
                }

                // 回退：直接在块内寻找 JPEG/PNG 魔数特征
                int imgStart = blockData.indexOf(QByteArray("\xFF\xD8\xFF", 3));
                if (imgStart < 0)
                    imgStart = blockData.indexOf(QByteArray("\x89PNG", 4));
                if (imgStart >= 0)
                {
                    QImage img;
                    if (img.loadFromData(blockData.mid(imgStart)))
                        return img;
                }
            }
            break;
        }
        else
        {
            file.seek(file.pos() + blockSize);
        }

        if (isLast)
            break;
    }

    return {};
}

QImage CoverManager::extractFromM4a(const QString & filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    // 针对 M4A / AAC (MP4 容器)：只读取头部前 4MB 扫描 covr 盒子
    QByteArray data = file.read(4 * 1024 * 1024);
    int covrIdx = data.indexOf("covr");
    if (covrIdx >= 0)
    {
        int dataAtomIdx = data.indexOf("data", covrIdx);
        if (dataAtomIdx >= 0 && dataAtomIdx + 16 < data.size())
        {
            // data 盒子后第 8 字节开始为真实图像数据
            QByteArray imgData = data.mid(dataAtomIdx + 8);
            QImage img;
            if (img.loadFromData(imgData))
            {
                return img;
            }
        }
    }
    return {};
}

QImage CoverManager::extractCover(const QString & filePath)
{
    QString ext = QFileInfo(filePath).suffix().toLower();
    if (ext == QStringLiteral("mp3"))
    {
        return extractFromMp3(filePath);
    }
    else if (ext == QStringLiteral("flac"))
    {
        return extractFromFlac(filePath);
    }
    else if (ext == QStringLiteral("m4a") || ext == QStringLiteral("aac") || ext == QStringLiteral("mp4"))
    {
        return extractFromM4a(filePath);
    }

    // 其他格式尝试通用 APIC/魔数提取
    QImage img = extractFromFlac(filePath);
    if (!img.isNull())
        return img;
    return extractFromMp3(filePath);
}

QString CoverManager::getCoverUrl(const QString & audioFilePath)
{
    if (audioFilePath.isEmpty())
        return {};

    QMutexLocker locker(&m_mutex);

    // 1. 检查内存缓存
    if (m_memoryCache.contains(audioFilePath))
    {
        return m_memoryCache.value(audioFilePath);
    }

    // 2. 检查磁盘缓存文件
    ensureCacheDir();
    QByteArray hash = QCryptographicHash::hash(audioFilePath.toUtf8(), QCryptographicHash::Md5).toHex();
    QString cacheFilePath = m_cacheDir + QStringLiteral("/") + QString::fromLatin1(hash) + QStringLiteral(".jpg");

    if (QFile::exists(cacheFilePath))
    {
        QString url = QUrl::fromLocalFile(cacheFilePath).toString();
        m_memoryCache.insert(audioFilePath, url);
        return url;
    }

    // 3. 检查伴随文件（同名图片或同目录 cover.jpg）
    QString companionUrl = searchCompanionImage(audioFilePath);
    if (!companionUrl.isEmpty())
    {
        m_memoryCache.insert(audioFilePath, companionUrl);
        return companionUrl;
    }

    // 4. 从音频文件提取内嵌封面
    QImage coverImg = extractCover(audioFilePath);
    if (!coverImg.isNull())
    {
        // 规整图片尺寸至合适大小（最大 600x600，保证清晰度同时控制体积）
        if (coverImg.width() > 600 || coverImg.height() > 600)
        {
            coverImg = coverImg.scaled(600, 600, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }

        if (coverImg.save(cacheFilePath, "JPG", 88))
        {
            QString url = QUrl::fromLocalFile(cacheFilePath).toString();
            m_memoryCache.insert(audioFilePath, url);
            qDebug() << "[CoverManager] 提取并缓存封面成功:" << audioFilePath << "->" << cacheFilePath;
            return url;
        }
    }

    // 5. 无封面：记录空结果至内存缓存，避免重复提取
    m_memoryCache.insert(audioFilePath, QString());
    return {};
}

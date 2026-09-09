#include <QGuiApplication>              //Qt GUI程序基础应用对象
#include <QQmlApplicationEngine>        //用于加载运行QML
#include <QQmlContext>
#include <QQuickStyle>
#include "PlayerController.h"
#include "MusicLibraryModel.h"
#include "PlaylistManager.h"
#include "RecentManager.h"
#include <QDir>

int main(int argc,char * argv[])
{
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc,argv);
    //创建音乐库Model
    MusicLibraryModel library;
    library.scanDirectory(R"(D:\Qt_Project\FluentWinUI_Musicplayer\qml\music_resource\loadmusic_by_default)");
    //创建推荐音乐库 每次程序启动后重新抽取
    MusicLibraryModel recommendLibrary;
    QString recommendDir = R"(D:\Qt_Project\FluentWinUI_Musicplayer\downloaded_songs)";
    if (!QDir(recommendDir).exists() || QDir(recommendDir).isEmpty())
        recommendDir = R"(D:\Qt_Project\FluentWinUI_Musicplayer\qml\music_resource\loadmusic_by_default)";
    recommendLibrary.scanRandomDirectory(recommendDir,42);
    //创建播放器
    PlayerController player(&library);
    //创建歌单管理器
    PlaylistManager playlistManager;
    //创建最近播放管理器
    RecentManager recentManager;
    player.setRecentManager(&recentManager);

    QQmlApplicationEngine engine;       //创建QML引擎
    engine.rootContext()->setContextProperty("player",&player);
    engine.rootContext()->setContextProperty("musicLibrary",&library);
    engine.rootContext()->setContextProperty("recommendLibrary",&recommendLibrary);
    engine.rootContext()->setContextProperty("playlistManager",&playlistManager);
    engine.rootContext()->setContextProperty("recentManager",&recentManager);
    engine.rootContext()->setContextProperty("recentLibrary",recentManager.model());

    QObject::connect(&engine,&QQmlApplicationEngine::objectCreationFailed,&app,
                     [](){QCoreApplication::exit(-1);},Qt::QueuedConnection);

    //从名为FluentWinUI_Musicplayer的QML模块中加载Main.qml
    engine.loadFromModule("FluentWinUI_Musicplayer","Main");
    return app.exec();
}
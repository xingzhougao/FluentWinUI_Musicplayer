#include <QGuiApplication>              //Qt GUI程序基础应用对象
#include <QQmlApplicationEngine>        //用于加载运行QML
#include <QQmlContext>
#include <QQuickStyle>
#include "PlayerController.h"
#include "MusicLibraryModel.h"

int main(int argc,char * argv[])
{
    QQuickStyle::setStyle("Basic");
    QGuiApplication app(argc,argv);
    //创建音乐库Model
    MusicLibraryModel library;
    library.scanDirectory(R"(D:\Qt_Project\FluentWinUI_Musicplayer\qml\music_resource\loadmusic_by_default)");
    //创建播放器
    PlayerController player(&library);
    QQmlApplicationEngine engine;       //创建QML引擎
    engine.rootContext()->setContextProperty("player",&player);
    engine.rootContext()->setContextProperty("musicLibrary",&library);

    QObject::connect(&engine,&QQmlApplicationEngine::objectCreationFailed,&app,
                     [](){QCoreApplication::exit(-1);},Qt::QueuedConnection);

    //从名为FluentWinUI_Musicplayer的QML模块中加载Main.qml
    engine.loadFromModule("FluentWinUI_Musicplayer","Main");
    return app.exec();
}
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QQuickStyle>
#include <QStringLiteral>
#include "MangaController.h"
#include "DatabaseManager.h"
#include "ChapterController.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("BinusStudent");
    app.setOrganizationDomain("binus.ac.id");
    app.setApplicationName("QtYomi");

    QQuickStyle::setStyle("Basic");

    if (!DatabaseManager::instance().init())
    {
        qWarning() << "Failed to initialize database!";
    }

    // --- FIX: Create Controller BEFORE Engine ---
    MangaController controller;
    // --------------------------------------------
    ChapterController chapterController;
    QQmlApplicationEngine engine;

    // Register Controller
    engine.rootContext()->setContextProperty("mangaController", &controller);
    engine.rootContext()->setContextProperty("chapterController", &chapterController);

    const QUrl url(u"qrc:/QtYomi/content/App.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
                     {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}

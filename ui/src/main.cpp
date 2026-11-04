// Startet die CARVOS-Oberfläche.
//
// Normal laufen die einkompilierten QML-Dateien. Mit --dev UI-ORDNER werden sie
// stattdessen aus dem Quellordner geladen und beim Speichern automatisch neu geladen.

#include <QCommandLineParser>
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFileSystemWatcher>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlExtensionPlugin>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>
#include <QUrl>

#include <memory>

Q_IMPORT_QML_PLUGIN(CarvosPlugin)

namespace {

class LiveReloader : public QObject
{
public:
    explicit LiveReloader(const QString &uiDir)
        : m_uiDir(uiDir)
    {
        // Editoren speichern in mehreren Schritten, daher kurz abwarten.
        m_timer.setSingleShot(true);
        m_timer.setInterval(200);
        connect(&m_timer, &QTimer::timeout, this, &LiveReloader::reload);
        connect(&m_watcher, &QFileSystemWatcher::directoryChanged, &m_timer, qOverload<>(&QTimer::start));
        connect(&m_watcher, &QFileSystemWatcher::fileChanged, &m_timer, qOverload<>(&QTimer::start));
        load();
    }

private:
    void load()
    {
        m_engine = std::make_unique<QQmlApplicationEngine>();
        m_engine->addImportPath(m_uiDir + QStringLiteral("/imports"));
        m_engine->load(QUrl::fromLocalFile(m_uiDir + QStringLiteral("/content/App.qml")));
        watch();
    }

    void watch()
    {
        const QStringList folders = {m_uiDir + QStringLiteral("/content"),
                                     m_uiDir + QStringLiteral("/imports/Carvos")};
        for (const QString &folder : folders) {
            m_watcher.addPath(folder);
            const QStringList files = QDir(folder).entryList({QStringLiteral("*.qml")}, QDir::Files);
            for (const QString &file : files)
                m_watcher.addPath(folder + QLatin1Char('/') + file);
        }
    }

    void reload()
    {
        const QList<QObject *> roots = m_engine->rootObjects();
        for (QObject *root : roots) {
            if (auto *window = qobject_cast<QQuickWindow *>(root))
                window->close();
        }
        m_engine.reset();
        load();
        qInfo().noquote() << "Oberfläche neu geladen";
    }

    QString m_uiDir;
    QFileSystemWatcher m_watcher;
    QTimer m_timer;
    std::unique_ptr<QQmlApplicationEngine> m_engine;
};

} // namespace

int main(int argc, char *argv[])
{
    // Das Display hat feste 1024x600 Pixel, Desktop-Skalierung würde das verfälschen.
    if (qEnvironmentVariableIsEmpty("QT_ENABLE_HIGHDPI_SCALING"))
        qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");

    QGuiApplication app(argc, argv);
    // Legt fest, wo die Einstellungen gespeichert werden.
    QCoreApplication::setOrganizationName(QStringLiteral("CARVOS"));
    QCoreApplication::setApplicationName(QStringLiteral("carvos-ui"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("CARVOS-Oberfläche"));
    parser.addHelpOption();
    const QCommandLineOption devOption(QStringLiteral("dev"),
                                       QStringLiteral("QML aus dem Quellordner laden und bei Änderungen neu laden"),
                                       QStringLiteral("ui-ordner"));
    parser.addOption(devOption);
    parser.process(app);

    if (parser.isSet(devOption)) {
        // Alle Fenster sind beim Neuladen kurz geschlossen.
        QGuiApplication::setQuitOnLastWindowClosed(false);
        LiveReloader reloader(QDir(parser.value(devOption)).absolutePath());
        return app.exec();
    }

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [] { QCoreApplication::exit(EXIT_FAILURE); }, Qt::QueuedConnection);
    engine.loadFromModule("CarvosApp", "App");
    return app.exec();
}

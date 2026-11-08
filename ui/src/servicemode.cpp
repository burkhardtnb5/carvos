#include "servicemode.h"

#include <QFile>

namespace {

const QString statusFile = QStringLiteral("/run/carvos/service-mode");
const QString versionFile = QStringLiteral("/opt/carvos/VERSION");
const QString unit = QStringLiteral("carvos-service-mode.service");
constexpr int maxLogLines = 500;
constexpr int startTimeoutMs = 15000;

} // namespace

ServiceMode::ServiceMode(QObject *parent)
    : QObject(parent)
{
    QFile file(versionFile);
    m_version = file.open(QIODevice::ReadOnly) ? QString::fromUtf8(file.readAll()).trimmed()
                                               : QStringLiteral("Entwicklung");

    // Der Stand ist eine kleine Datei; Abfragen nur, solange der Service-Modus läuft.
    m_poll.setInterval(1000);
    connect(&m_poll, &QTimer::timeout, this, &ServiceMode::readStatus);

    connect(&m_starter, &QProcess::finished, this, [this](int exitCode, QProcess::ExitStatus status) {
        if (status != QProcess::NormalExit || exitCode != 0)
            startFailed(QString::fromUtf8(m_starter.readAllStandardError()).trimmed());
    });
    connect(&m_starter, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart)
            startFailed(QStringLiteral("systemctl nicht gefunden"));
    });

    m_journal.setProcessChannelMode(QProcess::MergedChannels);
    connect(&m_journal, &QProcess::readyReadStandardOutput, this, &ServiceMode::readJournal);

    // Läuft der Service-Modus schon (z. B. weil das Update die Oberfläche neu gestartet hat)?
    readStatus();
}

bool ServiceMode::active() const
{
    return m_phase == QLatin1String("start") || m_phase == QLatin1String("netz")
           || m_phase == QLatin1String("update");
}

void ServiceMode::start()
{
    if (active() || m_starting)
        return;
    // Bis der Dienst seine erste Zeile schreibt, steht noch der alte Durchlauf in der Datei.
    m_staleInvocation = m_invocation;
    m_starting = true;
    m_startTime.start();
    stopJournal();
    m_logLines.clear();
    emit logChanged();
    setState(QStringLiteral("start"), QStringLiteral("Service-Modus wird gestartet"));
    m_starter.start(QStringLiteral("systemctl"), {QStringLiteral("start"), QStringLiteral("--no-block"), unit});
    m_poll.start();
}

void ServiceMode::setLogEnabled(bool enabled)
{
    if (m_logEnabled == enabled)
        return;
    m_logEnabled = enabled;
    emit logEnabledChanged();
    updateJournal();
}

void ServiceMode::readStatus()
{
    QFile file(statusFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        if (m_starting && m_startTime.elapsed() > startTimeoutMs)
            startFailed(QStringLiteral("Der Dienst hat sich nicht gemeldet"));
        return;
    }

    QString phase, message, invocation;
    const QStringList lines = QString::fromUtf8(file.readAll()).split(QLatin1Char('\n'));
    for (const QString &line : lines) {
        const qsizetype eq = line.indexOf(QLatin1Char('='));
        if (eq < 0)
            continue;
        const QString key = line.left(eq);
        const QString value = line.mid(eq + 1);
        if (key == QLatin1String("phase"))
            phase = value;
        else if (key == QLatin1String("message"))
            message = value;
        else if (key == QLatin1String("invocation"))
            invocation = value;
    }

    if (m_starting) {
        if (invocation == m_staleInvocation) {
            if (m_startTime.elapsed() > startTimeoutMs)
                startFailed(QStringLiteral("Der Dienst hat sich nicht gemeldet"));
            return;
        }
        m_starting = false;
    }

    m_invocation = invocation;
    setState(phase, message);
    if (!active())
        m_poll.stop();
    else if (!m_poll.isActive())
        m_poll.start();
    updateJournal();
}

void ServiceMode::setState(const QString &phase, const QString &message)
{
    if (phase == m_phase && message == m_message)
        return;
    m_phase = phase;
    m_message = message;
    emit changed();
}

void ServiceMode::startFailed(const QString &reason)
{
    m_starting = false;
    m_poll.stop();
    QString text = QStringLiteral("Der Service-Modus ließ sich nicht starten.");
    if (!reason.isEmpty())
        text += QLatin1Char(' ') + reason;
    setState(QStringLiteral("fehler"), text);
}

// Liest das Journal genau dieses Durchlaufs (alle Ausgaben des Dienstes und von carvos-update).
// Braucht Lesezugriff aufs Journal: Gruppe adm oder systemd-journal.
void ServiceMode::updateJournal()
{
    const bool wanted = m_logEnabled && !m_starting && !m_invocation.isEmpty();
    if (!wanted) {
        stopJournal();
        return;
    }
    if (m_journal.state() != QProcess::NotRunning && m_journalInvocation == m_invocation)
        return;
    stopJournal();
    m_logLines.clear();
    m_partialLine.clear();
    emit logChanged();
    m_journalInvocation = m_invocation;
    m_journal.start(QStringLiteral("journalctl"),
                    {QStringLiteral("--follow"), QStringLiteral("--lines=all"), QStringLiteral("--output=cat"),
                     QStringLiteral("_SYSTEMD_INVOCATION_ID=") + m_invocation});
}

void ServiceMode::stopJournal()
{
    if (m_journal.state() == QProcess::NotRunning)
        return;
    m_journal.kill();
    m_journal.waitForFinished(1000);
}

void ServiceMode::readJournal()
{
    m_partialLine += m_journal.readAllStandardOutput();
    const qsizetype end = m_partialLine.lastIndexOf('\n');
    if (end < 0)
        return;
    const QString complete = QString::fromUtf8(m_partialLine.left(end));
    m_partialLine.remove(0, end + 1);
    m_logLines += complete.split(QLatin1Char('\n'));
    if (m_logLines.size() > maxLogLines)
        m_logLines.erase(m_logLines.begin(), m_logLines.end() - maxLogLines);
    emit logChanged();
}

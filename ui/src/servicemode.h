#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <QProcess>
#include <QStringList>
#include <QTimer>

// Verbindung der Oberfläche zum Service-Modus. Die eigentliche Arbeit macht der
// Root-Dienst carvos-service-mode.service. Die Oberfläche startet ihn nur (polkit
// erlaubt das der Gruppe carvos) und zeigt den Stand aus /run/carvos/service-mode an.
// Im Entwicklermodus liest sie zusätzlich das Journal des laufenden Durchlaufs mit.
// Später übernimmt das carvosd.
class ServiceMode : public QObject
{
    Q_OBJECT
    // start, netz, update, fertig, fehler – oder leer, wenn noch nie gelaufen
    Q_PROPERTY(QString phase READ phase NOTIFY changed)
    Q_PROPERTY(QString message READ message NOTIFY changed)
    Q_PROPERTY(bool active READ active NOTIFY changed)
    Q_PROPERTY(QString log READ log NOTIFY logChanged)
    Q_PROPERTY(bool logEnabled READ logEnabled WRITE setLogEnabled NOTIFY logEnabledChanged)
    Q_PROPERTY(QString version READ version CONSTANT)

public:
    explicit ServiceMode(QObject *parent = nullptr);

    QString phase() const { return m_phase; }
    QString message() const { return m_message; }
    bool active() const;
    QString log() const { return m_logLines.join(QLatin1Char('\n')); }
    bool logEnabled() const { return m_logEnabled; }
    void setLogEnabled(bool enabled);
    QString version() const { return m_version; }

    Q_INVOKABLE void start();

signals:
    void changed();
    void logChanged();
    void logEnabledChanged();

private:
    void readStatus();
    void setState(const QString &phase, const QString &message);
    void startFailed(const QString &reason);
    void updateJournal();
    void stopJournal();
    void readJournal();

    QString m_phase;
    QString m_message;
    QString m_invocation;
    QString m_staleInvocation;
    bool m_starting = false;
    QElapsedTimer m_startTime;
    bool m_logEnabled = false;
    QString m_journalInvocation;
    QByteArray m_partialLine;
    QStringList m_logLines;
    QString m_version;
    QProcess m_starter;
    QProcess m_journal;
    QTimer m_poll;
};

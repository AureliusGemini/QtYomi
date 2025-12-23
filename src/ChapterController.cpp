#include "ChapterController.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

ChapterController::ChapterController(QObject *parent) : QObject(parent)
{
    m_netManager = new QNetworkAccessManager(this);
}

void ChapterController::loadChapter(const QString &chapterId)
{
    qDebug() << "[READER] Loading Chapter ID:" << chapterId;
    m_pages.clear();
    emit pagesChanged();

    // 1. Fetch Chapter Metadata from MangaDex
    QUrl url("https://api.mangadex.org/at-home/server/" + chapterId);
    QNetworkRequest request(url);

    QNetworkReply *reply = m_netManager->get(request);

    // Ignore SSL for Binus Network
    reply->ignoreSslErrors();
    connect(reply, &QNetworkReply::sslErrors, reply, [reply]()
            { reply->ignoreSslErrors(); });

    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject root = doc.object();
            
            // MangaDex returns a "baseUrl" and a list of "filenames"
            QString baseUrl = root["baseUrl"].toString();
            QString hash = root["chapter"].toObject()["hash"].toString();
            QJsonArray dataArr = root["chapter"].toObject()["data"].toArray();

            QVariantList newPages;
            for (const auto &val : dataArr) {
                QString filename = val.toString();
                // Construct full URL: baseUrl + /data/ + hash + / + filename
                QString fullUrl = QString("%1/data/%2/%3").arg(baseUrl, hash, filename);
                newPages.append(fullUrl);
            }

            m_pages = newPages;
            emit pagesChanged();
            qDebug() << "[READER] Loaded" << m_pages.size() << "pages from API.";
            
        } else {
            qWarning() << "[READER] Network Failed (Cloudflare?). Loading DEMO mode.";
            generateDemoPages();
        }
        reply->deleteLater(); });
}

void ChapterController::generateDemoPages()
{
    // This ensures you have something to show if the API blocks you
    QVariantList demo;
    // Just some random placeholders
    demo.append("https://via.placeholder.com/600x800/FF0000/FFFFFF?text=Page+1");
    demo.append("https://via.placeholder.com/600x800/00FF00/FFFFFF?text=Page+2");
    demo.append("https://via.placeholder.com/600x800/0000FF/FFFFFF?text=Page+3");
    demo.append("https://via.placeholder.com/600x800/FFFF00/000000?text=Page+4");
    m_pages = demo;
    emit pagesChanged();
}
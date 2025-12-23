#include "MangaController.h"
#include "DatabaseManager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QThreadPool>
#include <QNetworkRequest>
#include <QNetworkReply>

MangaController::MangaController(QObject *parent) : QObject(parent) {
    m_netManager = new QNetworkAccessManager(this);
    refreshLibrary();
}

void MangaController::searchManga(const QString &queryText) {
    if (queryText.isEmpty()) return;

    qDebug() << "\n[MULTITHREADING] UI Action received on Thread:" << QThread::currentThread();

    // JIKAN API (Unblocked)
    QUrl url("https://api.jikan.moe/v4/manga");
    QUrlQuery query;
    query.addQueryItem("q", queryText);
    query.addQueryItem("limit", "20");
    query.addQueryItem("sfw", "true");
    url.setQuery(query);

    qDebug() << "[NETWORKING] Sending GET Request to:" << url.toString();

    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "QtYomi/1.0");

    QNetworkReply *reply = m_netManager->get(request);

    connect(reply, &QNetworkReply::sslErrors, reply, [reply]() {
        reply->ignoreSslErrors();
    });

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "[NETWORKING] Data Received. Size:" << reply->size() << "bytes";
            QByteArray data = reply->readAll();

            // BACKGROUND THREAD: Parse JSON only
            QThreadPool::globalInstance()->start([this, data]() {
                this->parseSearchResponse(data);
            });
        } else {
            qWarning() << "[NETWORKING] Error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}

void MangaController::parseSearchResponse(const QByteArray &data) {
    // RUNNING ON WORKER THREAD
    QJsonDocument doc = QJsonDocument::fromJson(data);
    const QJsonObject rootObj = doc.object();
    const QJsonArray dataArray = rootObj["data"].toArray();

    QVariantList rawResults;

    for (const auto &val : dataArray) {
        const QJsonObject obj = val.toObject();

        QString id = QString::number(obj["mal_id"].toInt());
        QString title = obj["title"].toString();

        QString coverUrl = "https://dummyimage.com/225x320/000/fff.jpg&text=No+Cover";
        const QJsonObject imagesObj = obj["images"].toObject();
        if (imagesObj.contains("jpg")) {
            coverUrl = imagesObj["jpg"].toObject()["image_url"].toString();
        }

        QVariantMap map;
        map["id"] = id;
        map["title"] = title;
        map["cover"] = coverUrl;
        // NOTE: We do NOT check "inLibrary" here anymore to avoid threading errors

        rawResults.append(map);
    }

    // SWITCH TO MAIN THREAD to check Database
    QMetaObject::invokeMethod(this, [this, rawResults]() {
        QVariantList finalResults;

        // Now we are safe to talk to the Database
        for(const auto &item : rawResults) {
            QVariantMap map = item.toMap();
            map["inLibrary"] = DatabaseManager::instance().isBookmarked(map["id"].toString());
            finalResults.append(map);
        }

        m_searchResults = finalResults;
        emit searchResultsChanged();
        qDebug() << "[UI] Search Results Updated with" << finalResults.size() << "items.";
    });
}

void MangaController::addToLibrary(const QString &id, const QString &title, const QString &coverUrl) {
    DatabaseManager::instance().addToLibrary(id, title, coverUrl);
    refreshLibrary();
    // Refresh button state manually since we can't easily re-search Jikan without rate limits
    // (In a real app, we'd update the model directly, but this is fine for exam)
    QVariantList updatedList;
    for(const auto &item : m_searchResults) {
        QVariantMap map = item.toMap();
        if(map["id"].toString() == id) {
            map["inLibrary"] = true;
        }
        updatedList.append(map);
    }
    m_searchResults = updatedList;
    emit searchResultsChanged();
}

void MangaController::removeFromLibrary(const QString &id) {
    DatabaseManager::instance().removeFromLibrary(id);
    refreshLibrary();

    QVariantList updatedList;
    for(const auto &item : m_searchResults) {
        QVariantMap map = item.toMap();
        if(map["id"].toString() == id) {
            map["inLibrary"] = false;
        }
        updatedList.append(map);
    }
    m_searchResults = updatedList;
    emit searchResultsChanged();
}

void MangaController::refreshLibrary() {
    const auto items = DatabaseManager::instance().getLibrary();
    QVariantList list;
    for (const auto &item : items) {
        QVariantMap map;
        map["id"] = item.id;
        map["title"] = item.title;
        map["cover"] = item.coverUrl;
        list.append(map);
    }
    m_libraryItems = list;
    emit libraryChanged();
}

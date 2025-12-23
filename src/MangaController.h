#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>

class MangaController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList searchResults READ searchResults NOTIFY searchResultsChanged)
    Q_PROPERTY(QVariantList libraryModel READ libraryModel NOTIFY libraryChanged)

public:
    explicit MangaController(QObject *parent = nullptr);

    Q_INVOKABLE void searchManga(const QString &query);
    Q_INVOKABLE void addToLibrary(const QString &id, const QString &title, const QString &coverUrl);
    Q_INVOKABLE void removeFromLibrary(const QString &id);
    Q_INVOKABLE void refreshLibrary();

    QVariantList searchResults() const { return m_searchResults; }
    QVariantList libraryModel() const { return m_libraryItems; }

signals:
    void searchResultsChanged();
    void libraryChanged();

private:
    QNetworkAccessManager *m_netManager;
    QVariantList m_searchResults;
    QVariantList m_libraryItems;

    void parseSearchResponse(const QByteArray &data);
};

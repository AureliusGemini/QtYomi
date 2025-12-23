#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QList>

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    struct LibraryItem {
        QString id;
        QString title;
        QString coverUrl;
    };

    static DatabaseManager& instance();
    bool init();
    bool addToLibrary(const QString &id, const QString &title, const QString &coverUrl);
    bool removeFromLibrary(const QString &id);
    bool isBookmarked(const QString &id);
    QList<LibraryItem> getLibrary();

private:
    DatabaseManager() {}
    QSqlDatabase m_db;
};

#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QVariantList>

class ChapterController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList pages READ pages NOTIFY pagesChanged)

public:
    explicit ChapterController(QObject *parent = nullptr);

    // Call this to load a specific chapter
    Q_INVOKABLE void loadChapter(const QString &chapterId);

    QVariantList pages() const { return m_pages; }

signals:
    void pagesChanged();

private:
    QNetworkAccessManager *m_netManager;
    QVariantList m_pages;

    void generateDemoPages(); // Fallback for presentation
};
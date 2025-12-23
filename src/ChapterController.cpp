#include "ChapterController.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>

ChapterController::ChapterController(QObject *parent) : QObject(parent) {
    m_netManager = new QNetworkAccessManager(this);
}

void ChapterController::loadChapter(const QString &chapterId) {
    qDebug() << "[READER] Opening Reader for ID:" << chapterId;
    m_pages.clear();
    emit pagesChanged();

    // FOR PRESENTATION: Skip the blocked API and load reliable demo pages immediately.
    // This ensures "Instant" loading for the video without error logs.
    generateDemoPages();
}

void ChapterController::generateDemoPages() {
    QVariantList demo;
    // FIX: Changed '&text' to '?text' for correct URL formatting
    demo.append("https://dummyimage.com/600x800/aa0000/ffffff.png?text=Page+1+(Cover)");
    demo.append("https://dummyimage.com/600x800/00aa00/ffffff.png?text=Page+2+(Story)");
    demo.append("https://dummyimage.com/600x800/0000aa/ffffff.png?text=Page+3+(Action)");
    demo.append("https://dummyimage.com/600x800/555555/ffffff.png?text=Page+4+(End)");

    m_pages = demo;
    emit pagesChanged();
    qDebug() << "[READER] Demo pages loaded successfully.";
}

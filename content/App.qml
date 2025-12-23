import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." // Local components (ReaderView)

Window {
    width: 400
    height: 800
    visible: true
    title: "QtYomi"
    color: "#121212" // Dark Theme Background

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Content Area (Switches between Library and Browse) ---
        StackLayout {
            id: stackLayout
            currentIndex: tabBar.currentIndex // 0=Library, 1=Browse, 2=Reader
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- TAB 1: LIBRARY ---
            Item {
                Label {
                    text: "Your Library"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    anchors.top: parent.top
                    anchors.margins: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridView {
                    anchors.fill: parent
                    anchors.topMargin: 60
                    clip: true
                    cellWidth: width / 2
                    cellHeight: 280
                    model: mangaController.libraryModel

                    delegate: Column {
                        width: GridView.view.cellWidth
                        spacing: 8

                        Image {
                            width: 140
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: modelData.cover
                            fillMode: Image.PreserveAspectCrop

                            Rectangle { // Border for visual clarity
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#333"
                                border.width: 1
                                radius: 4
                            }
                        }

                        Text {
                            width: 140
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.title
                            color: "white"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 13
                        }

                        Button {
                            text: "Remove"
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 30
                            flat: true
                            onClicked: mangaController.removeFromLibrary(modelData.id)
                            background: Rectangle {
                                color: "#333"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ff5555" // Red text
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // --- TAB 2: BROWSE ---
            ColumnLayout {
                spacing: 10

                // Search Bar
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.topMargin: 20

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search MangaDex..."
                        color: "black"
                        background: Rectangle { color: "white"; radius: 4 }
                        onAccepted: mangaController.searchManga(text)
                    }
                    Button {
                        text: "Search"
                        onClicked: mangaController.searchManga(searchField.text)
                    }
                }

                // Results Grid
                GridView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: width / 2
                    cellHeight: 280
                    model: mangaController.searchResults

                    delegate: Column {
                        width: GridView.view.cellWidth
                        spacing: 8

                        Image {
                            width: 140
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: modelData.cover
                            fillMode: Image.PreserveAspectCrop
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#333"
                                border.width: 1
                                radius: 4
                            }
                        }

                        Text {
                            width: 140
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.title
                            color: "white"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 13
                        }

                        Button {
                            text: "Read (Demo)"
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 30

                            onClicked: {
                                stackLayout.currentIndex = 2
                                readerView.chapterId = "5430fb39-7711-4022-9233-024bea94e772"
                                chapterController.loadChapter("5430fb39-7711-4022-9233-024bea94e772")
                            }
                        }
                    }
                }
            }

            // --- TAB 3: READER VIEW (NEW) ---
            ReaderView {
                id: readerView
            }
        }

        // --- Bottom Navigation Bar ---
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle { color: "#1e1e1e" }

            TabButton {
                text: "Library"
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#4cc2ff" : "gray"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: "transparent" }
            }
            TabButton {
                text: "Browse"
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#4cc2ff" : "gray"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle { color: "transparent" }
            }
        }
    }
}

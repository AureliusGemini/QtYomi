import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." // Local components (ReaderView)

Window {
    width: 400
    height: 800
    visible: true
    title: "QtYomi"
    color: "#121212"

    // --- GLOBAL STATE ---
    property bool selectionMode: false
    property var selectedIds: []

    function toggleSelection(id) {
        var idx = selectedIds.indexOf(id)
        if (idx >= 0) {
            selectedIds.splice(idx, 1)
        } else {
            selectedIds.push(id)
        }
        selectedIdsChanged()
        if (selectedIds.length === 0) {
            selectionMode = false
        }
    }

    function deleteSelectedItems() {
        for (var i = 0; i < selectedIds.length; i++) {
            mangaController.removeFromLibrary(selectedIds[i])
        }
        selectedIds = []
        selectionMode = false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackLayout {
            id: stackLayout
            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- TAB 1: LIBRARY (Index 0) ---
            Item {
                // Header
                Item {
                    height: 50
                    width: parent.width
                    anchors.top: parent.top

                    Label {
                        text: "Your Library"
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.centerIn: parent
                        visible: !selectionMode
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        visible: selectionMode
                        spacing: 10

                        Button {
                            text: "Cancel"
                            onClicked: {
                                selectionMode = false
                                selectedIds = []
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Label {
                            text: selectedIds.length + " Selected"
                            color: "white"
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Button {
                            text: "Delete (" + selectedIds.length + ")"
                            background: Rectangle {
                                color: "#ff5555"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: deleteSelectedItems()
                        }
                    }
                }

                GridView {
                    anchors.fill: parent
                    anchors.topMargin: 60
                    clip: true
                    cellWidth: width / 2
                    cellHeight: 300
                    model: mangaController.libraryModel

                    delegate: Column {
                        width: GridView.view.cellWidth
                        spacing: 5

                        Item { // Cover Wrapper
                            width: 140
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter

                            Image {
                                anchors.fill: parent
                                source: modelData.cover
                                fillMode: Image.PreserveAspectCrop
                                opacity: (selectionMode && selectedIds.indexOf(modelData.id) === -1) ? 0.5 : 1.0
                            }

                            Rectangle { // Selection Border
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#ff5555"
                                border.width: 4
                                visible: selectionMode && selectedIds.indexOf(modelData.id) >= 0

                                Rectangle {
                                    width: 30
                                    height: 30
                                    color: "#ff5555"
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✓"
                                        color: "white"
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onPressAndHold: {
                                    if (!selectionMode) {
                                        selectionMode = true
                                        toggleSelection(modelData.id)
                                    }
                                }
                                onClicked: {
                                    if (selectionMode) {
                                        toggleSelection(modelData.id)
                                    } else {
                                        readerView.previousTabIndex = 0
                                        stackLayout.currentIndex = 2
                                        chapterController.loadChapter(modelData.id)
                                    }
                                }
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
                            text: "Read"
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 30
                            width: 100
                            visible: !selectionMode
                            onClicked: {
                                readerView.previousTabIndex = 0
                                stackLayout.currentIndex = 2
                                chapterController.loadChapter(modelData.id)
                            }
                        }
                    }
                }
            }

            // --- TAB 2: BROWSE (Index 1) ---
            ColumnLayout {
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.topMargin: 20

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search Manga..."
                        color: "black"
                        background: Rectangle {
                            color: "white"
                            radius: 4
                        }
                        onAccepted: mangaController.searchManga(text)
                    }

                    Button {
                        text: "Search"
                        onClicked: mangaController.searchManga(searchField.text)
                    }
                }

                GridView {
                    id: browseGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: width / 2
                    cellHeight: 320
                    model: mangaController.searchResults

                    Timer {
                        id: scrollFixTimer
                        interval: 10
                        property real savedPos: 0
                        onTriggered: browseGrid.contentY = savedPos
                    }

                    delegate: Column {
                        width: GridView.view.cellWidth
                        spacing: 5

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

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    readerView.previousTabIndex = 1
                                    stackLayout.currentIndex = 2
                                    chapterController.loadChapter(modelData.id)
                                }
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

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Button {
                                text: modelData.inLibrary ? "Saved" : "Add"
                                enabled: !modelData.inLibrary
                                height: 30
                                width: 60
                                onClicked: {
                                    scrollFixTimer.savedPos = browseGrid.contentY
                                    mangaController.addToLibrary(modelData.id, modelData.title, modelData.cover)
                                    scrollFixTimer.restart()
                                }
                            }

                            Button {
                                text: "Read"
                                height: 30
                                width: 60
                                onClicked: {
                                    readerView.previousTabIndex = 1
                                    stackLayout.currentIndex = 2
                                    chapterController.loadChapter(modelData.id)
                                }
                            }
                        }
                    }
                }
            }

            // --- TAB 3: READER (Index 2) ---
            ReaderView {
                id: readerView
            }
        }

        // --- Bottom Navigation Bar ---
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle {
                color: "#1e1e1e"
            }
            visible: !selectionMode

            onCurrentIndexChanged: {
                stackLayout.currentIndex = currentIndex
            }

            TabButton {
                text: "Library"
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#4cc2ff" : "gray"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                }
            }
            TabButton {
                text: "Browse"
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "#4cc2ff" : "gray"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }
}

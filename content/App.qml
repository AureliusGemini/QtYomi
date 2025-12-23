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

    // --- GLOBAL STATE FOR MULTI-SELECT ---
    property bool selectionMode: false
    property var selectedIds: [] // JavaScript Array to hold selected IDs

    // Helper to toggle selection
    function toggleSelection(id) {
        var idx = selectedIds.indexOf(id)
        if (idx >= 0) {
            selectedIds.splice(idx, 1) // Remove if exists
        } else {
            selectedIds.push(id) // Add if new
        }
        selectedIdsChanged() // Force QML to re-evaluate bindings

        // Auto-exit if empty
        if (selectedIds.length === 0) selectionMode = false
    }

    function deleteSelectedItems() {
        // Loop through all selected IDs and remove them
        for (var i = 0; i < selectedIds.length; i++) {
            mangaController.removeFromLibrary(selectedIds[i])
        }
        // Reset mode
        selectedIds = []
        selectionMode = false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- Content Area ---
        StackLayout {
            id: stackLayout
            currentIndex: tabBar.currentIndex // 0=Library, 1=Browse, 2=Reader
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- TAB 1: LIBRARY ---
            Item {
                // HEADER: changes based on Selection Mode
                Item {
                    height: 50
                    width: parent.width
                    anchors.top: parent.top

                    // Normal Header
                    Label {
                        text: "Your Library"
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.centerIn: parent
                        visible: !selectionMode
                    }

                    // Multi-Select Header (Visible only when holding items)
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

                        Item { Layout.fillWidth: true } // Spacer

                        Label {
                            text: selectedIds.length + " Selected"
                            color: "white"
                            font.bold: true
                        }

                        Item { Layout.fillWidth: true } // Spacer

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
                    cellHeight: 320
                    model: mangaController.libraryModel

                    delegate: Column {
                        width: GridView.view.cellWidth
                        spacing: 5

                        // COVER IMAGE WRAPPER
                        Item {
                            width: 140
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter

                            Image {
                                anchors.fill: parent
                                source: modelData.cover
                                fillMode: Image.PreserveAspectCrop
                                opacity: (selectionMode && selectedIds.indexOf(modelData.id) === -1) ? 0.5 : 1.0
                            }

                            // SELECTION OVERLAY (Red Border + Checkmark)
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#ff5555"
                                border.width: 4
                                visible: selectionMode && selectedIds.indexOf(modelData.id) >= 0

                                Rectangle {
                                    width: 30; height: 30
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

                            // INTERACTION AREA (Tap or Hold)
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
                                        // Normal Click: Go to Reader
                                        stackLayout.currentIndex = 2
                                        // Use demo ID for safety
                                        chapterController.loadChapter("demo-chapter")
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

                        // BUTTONS (Hidden during selection mode)
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5
                            visible: !selectionMode

                            // 1. READ BUTTON (NEW!)
                            Button {
                                text: "Read"
                                height: 30
                                width: 60
                                onClicked: {
                                    stackLayout.currentIndex = 2
                                    // Use demo ID for safety
                                    chapterController.loadChapter("demo-chapter")
                                }
                            }

                            // 2. REMOVE BUTTON
                            Button {
                                text: "Remove"
                                height: 30
                                width: 70
                                flat: true
                                background: Rectangle {
                                    color: "#333"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ff5555"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: mangaController.removeFromLibrary(modelData.id)
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
                        placeholderText: "Search Manga..."
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
                    cellHeight: 320
                    model: mangaController.searchResults

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

                            // Make image clickable to read immediately
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    stackLayout.currentIndex = 2
                                    chapterController.loadChapter("demo-chapter")
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

                            // SAVE BUTTON
                            Button {
                                text: modelData.inLibrary ? "Saved" : "Add"
                                enabled: !modelData.inLibrary
                                height: 30
                                width: 60
                                onClicked: mangaController.addToLibrary(modelData.id, modelData.title, modelData.cover)
                            }

                            // READ BUTTON
                            Button {
                                text: "Read"
                                height: 30
                                width: 60
                                onClicked: {
                                    stackLayout.currentIndex = 2
                                    chapterController.loadChapter("demo-chapter")
                                }
                            }
                        }
                    }
                }
            }

            // --- TAB 3: READER VIEW ---
            ReaderView {
                id: readerView
            }
        }

        // --- Bottom Navigation Bar ---
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle { color: "#1e1e1e" }
            visible: !selectionMode // Hide tabs when deleting items to avoid confusion

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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: readerPage
    property string chapterId: "" // Passed from main app
    
    background: Rectangle { color: "black" }

    Component.onCompleted: {
        // When this view opens, tell C++ to fetch images
        if (chapterId) {
            chapterController.loadChapter(chapterId)
        }
    }

    // Top Bar (Navigation)
    header: ToolBar {
        background: Rectangle { color: "#1e1e1e" }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "← Back"
                onClicked: stackLayout.currentIndex = 0 // Go back to Library/Browse
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label {
                text: "Reader"
                color: "white"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 50 } // Spacer
        }
    }

    // The Actual Reader
    ListView {
        id: pageList
        anchors.fill: parent
        model: chapterController.pages
        spacing: 0
        cacheBuffer: 10000 // Preload pixels to make scrolling smooth

        delegate: Image {
            width: ListView.view.width
            // Calculate height to maintain aspect ratio (defaulting to 1.4 ratio if loading)
            height: width * (implicitHeight > 0 ? implicitHeight / implicitWidth : 1.4)
            
            source: modelData
            fillMode: Image.PreserveAspectFit
            asynchronous: true // Important for UI responsiveness!
            
            // Loading Indicator
            BusyIndicator {
                anchors.centerIn: parent
                running: parent.status === Image.Loading
            }
        }
    }
}
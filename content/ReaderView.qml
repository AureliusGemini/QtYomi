import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: readerPage
    property string chapterId: ""

    background: Rectangle { color: "black" }

    Component.onCompleted: {
        if (chapterId) {
            chapterController.loadChapter(chapterId)
        }
    }

    header: ToolBar {
        background: Rectangle { color: "#1e1e1e" }
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "← Back"
                onClicked: {
                    // FIX: Ensure we go back to the Browse Tab (Index 1)
                    stackLayout.currentIndex = 1
                    // FIX: Also update the TabBar to show "Browse" is selected
                    tabBar.currentIndex = 1
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label {
                text: "Reader (Demo Mode)"
                color: "white"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 50 }
        }
    }

    ListView {
        id: pageList
        anchors.fill: parent
        model: chapterController.pages
        spacing: 5
        cacheBuffer: 10000

        delegate: Rectangle {
            // FIX: If image fails, show a colored rectangle
            width: ListView.view.width
            height: 500
            color: index % 2 === 0 ? "#222" : "#333"

            Image {
                anchors.fill: parent
                source: modelData
                fillMode: Image.PreserveAspectFit
                asynchronous: true

                // Show busy indicator while loading
                BusyIndicator {
                    anchors.centerIn: parent
                    running: parent.status === Image.Loading
                }
            }

            // Text to show page number if image fails
            Text {
                anchors.centerIn: parent
                text: "Page " + (index + 1)
                color: "white"
                font.pixelSize: 24
                visible: parent.children[0].status !== Image.Ready
            }
        }
    }
}

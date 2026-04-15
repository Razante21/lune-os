import QtQuick
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Search Bar
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 10
            color: "#12131A"
            border.color: "#C8A8E944"
            border.width: 1

            TextInput {
                anchors.fill: parent
                anchors.margins: 10
                text: "Search manga..."
                color: "#E0E0E0"
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Manga Grid
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 100; cellHeight: 140
            clip: true

            model: 12 // Simulated list
            delegate: Item {
                width: 100; height: 140

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: "#2A2B3D"
                    border.color: "#C8A8E922"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        Rectangle {
                            width: 60; height: 80
                            color: "#3B3C50"
                            radius: 4
                        }
                        Text {
                            text: "Manga " + index
                            color: "#E0E0E0"
                            font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}

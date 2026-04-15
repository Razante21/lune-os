import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "components"
import "../style.qml" as Style

Item {
    id: root
    property bool opened: false
    width: 1000
    height: 700
    visible: opened

    Behavior on opacity { NumberAnimation { duration: 200 } }
    opacity: opened ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Style.background + "CC"
            radius: 24
            border.color: Style.primary + "44"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                Text {
                    text: "Lune Wallpaper Picker"
                    color: Style.primary
                    font.pixelSize: 28
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Filter Bar
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Repeater {
                        model: ["All", "Anime", "Nature", "Cyberpunk", "Abstract"]
                        delegate: Rectangle {
                            height: 32
                            radius: 16
                            color: modelData === "All" ? Style.primary : Style.surface

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: modelData === "All" ? Style.background : Style.text
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }

                // Skewed Wallpaper Grid
                GridView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: 220; cellHeight: 160
                    clip: true

                    model: 10
                    delegate: WallpaperTile {
                        index: index
                    }
                }
            }
        }
    }

    component WallpaperTile : Item {
        property int index: 0
        width: 200
        height: 140

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                fillColor: Style.surface
                strokeColor: Style.primary
                strokeWidth: 2
                joinStyle: ShapePath.RoundJoin

                startX: Style.skewOffset
                startY: 0
                PathLine { x: 200; y: 0 }
                PathLine { x: 200 + Style.skewOffset; y: 140 }
                PathLine { x: 0; y: 140 }
                PathLine { x: Style.skewOffset; y: 0 }
            }
        }

        Image {
            anchors.fill: parent
            source: "https://picsum.photos/200/140?random=" + index
            fillMode: Image.PreserveAspectCrop
            opacity: 0.7
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 10
            text: "Wallpaper " + index
            color: Style.text
            font.pixelSize: 11
            font.bold: true
        }
    }
}

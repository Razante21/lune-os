import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "components"
import "../style.qml" as Style

Item {
    id: root
    property bool opened: false
    width: 800
    height: 500
    visible: opened

    Behavior on opacity { NumberAnimation { duration: 200 } }
    opacity: opened ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Background Backdrop
        Rectangle {
            anchors.fill: parent
            color: Style.background + "AA"
            radius: 24
            border.color: Style.primary + "44"
            border.width: 2
        }

        Grid {
            anchors.centerIn: parent
            columns: 4
            spacing: 20

            Repeater {
                model: ["Browser", "Terminal", "Files", "Settings", "Code", "Music", "Player", "Chat"]
                delegate: AppTile {
                    appName: modelData
                }
            }
        }
    }

    component AppTile : Item {
        property string appName: ""
        width: 140
        height: 100

        Shape {
            id: shape
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
                PathLine { x: 140; y: 0 }
                PathLine { x: 140 + Style.skewOffset; y: 100 }
                PathLine { x: 0; y: 100 }
                PathLine { x: Style.skewOffset; y: 0 }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 48; height: 48
                radius: 12
                color: Style.primary
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "🚀"
                    anchors.centerIn: parent
                    font.pixelSize: 24
                }
            }

            Text {
                text: appName
                color: Style.text
                font.pixelSize: 12
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}

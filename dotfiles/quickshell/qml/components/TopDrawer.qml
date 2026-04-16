import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../style.qml" as Style

Item {
    id: root
    width: parent.width
    height: 450
    visible: false // Controlled by shell.qml
    opacity: 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Rectangle {
        anchors.fill: parent
        color: Style.background + "EE" // Glassmorphism
        radius: 0
        border.color: Style.primary + "44"
        border.width: 2

        // Bottom rounded corners for a "hanging" look
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 20
            color: Style.background + "EE"
            radius: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 25

            Text {
                text: "Lune Control Center"
                color: Style.primary
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Quick Toggles Grid
            GridLayout {
                columns: 3
                Layout.alignment: Qt.AlignHCenter
                columnSpacing: 20
                rowSpacing: 20

                // Generic Toggle Component
                component ToggleButton : Rectangle {
                    width: 120; height: 80
                    radius: 15
                    color: Style.surface
                    border.color: Style.primary + "22"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle {
                            width: 24; height: 24
                            radius: 12
                            color: Style.primary
                        }
                        Text {
                            text: "Toggle"
                            color: Style.text
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                ToggleButton { text: "Wi-Fi" }
                ToggleButton { text: "Bluetooth" }
                ToggleButton { text: "Night Light" }
                ToggleButton { text: "Do Not Disturb" }
                ToggleButton { text: "Performance" }
                ToggleButton { text: "Audio" }
            }

            // Mini Notes Area
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Quick Notes"
                    color: Style.primary
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 120
                    radius: 12
                    color: Style.surface
                    border.color: Style.primary + "22"
                    border.width: 1

                    TextInput {
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "Write something here..."
                        color: Style.text
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignTop
                    }
                }
            }
        }
    }
}

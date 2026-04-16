import QtQuick
import QtQuick.Layouts
import "../style.qml"

Rectangle {
    id: root
    width: 300
    height: parent.height
    color: "transparent"

    // State for sliding animation
    property bool isOpen: false

    // Position: slides from -width to 0
    x: isOpen ? 0 : -width
    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Background with glassmorphism and skewed edge
    Rectangle {
        id: background
        anchors.fill: parent
        color: style.glassColor
        radius: 0 // Straight edge against screen

        // Glass effect border
        Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height
            color: style.accentColor
            opacity: 0.5
        }

        // Content Area
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text {
                text: "Lune Navigation"
                color: "white"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            Rectangle {
                Layout.fillWidth: true
                height: 2
                color: style.accentColor
                opacity: 0.3
            }

            // Mock list of "chapters" or sections
            Repeater {
                model: ["Dashboard", "Media Hub", "Files", "Settings", "About Lune"]
                delegate: ItemDelegate {
                    text: modelData
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Text {
                text: "v0.1.0-alpha"
                color: "white"
                opacity: 0.4
                font.pixelSize: 12
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // Component for list items
    component ItemDelegate : Rectangle {
        property string text: ""
        height: 45
        color: "transparent"
        radius: 8

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: "white"
            opacity: 0.8
            font.pixelSize: 16
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = style.glassColor
            onExited: parent.color = "transparent"
            onClicked: {
                console.log("Selected: " + parent.text);
                root.isOpen = false;
            }
        }
    }
}

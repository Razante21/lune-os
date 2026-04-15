import QtQuick
import QtQuick.Layouts
import "components"
import "../style.qml" as Style

Item {
    id: root
    width: screen.width
    height: 40
    anchors.top: parent.top

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        // Left Island
        BarIsland {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 32
            bgColor: Style.surface + "CC" // Alpha for glassmorphism

            Text {
                text: "🌙 Lune OS"
                color: Style.primary
                font.bold: true
                font.pixelSize: 14
            }
            Text {
                text: "WS 1"
                color: Style.text
                font.pixelSize: 12
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Center Island (Clock)
        BarIsland {
            Layout.preferredWidth: 150
            Layout.preferredHeight: 32
            bgColor: Style.surface + "CC"
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: clockText
                color: Style.text
                font.pixelSize: 14
                font.weight: Font.Medium

                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Right Island
        BarIsland {
            Layout.preferredWidth: 250
            Layout.preferredHeight: 32
            bgColor: Style.surface + "CC"

            Text {
                text: "CPU: 12%"
                color: Style.secondary
                font.pixelSize: 12
            }
            Text {
                text: "RAM: 4.2GB"
                color: Style.secondary
                font.pixelSize: 12
            }
            Text {
                text: "🔋 85%"
                color: Style.text
                font.pixelSize: 12
            }
        }
    }
}

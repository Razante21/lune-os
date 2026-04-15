import QtQuick
import QtQuick.Layouts
import "components"
import "../style.qml" as Style

Item {
    id: root
    property bool opened: false
    width: 400
    height: screen.height
    visible: opened

    Behavior on opacity { NumberAnimation { duration: 200 } }
    opacity: opened ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: Style.surface + "EE"
        radius: 0 // Lateral colada na tela
        border.color: Style.primary + "44"
        border.width: 2
        anchors.right: parent.right // Se quiser na direita, ou left para esquerda

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text {
                text: "Lune Media Hub"
                color: Style.primary
                font.pixelSize: 24
                font.bold: true
            }

            // Navigation Menu
            RowLayout {
                spacing: 10
                Layout.preferredWidth: parent.width

                Repeater {
                    model: ["Manga", "Anime", "Novel"]
                    delegate: Rectangle {
                        width: 80; height: 32
                        radius: 8
                        color: modelData === "Manga" ? Style.primary : Style.background

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: modelData === "Manga" ? Style.background : Style.text
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }

            // Content Area
            Loader {
                id: contentLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: MangaReader {}
            }
        }
    }
}

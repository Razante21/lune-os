import QtQuick
import QtQuick.Layouts

Rectangle {
    property alias content: item.data
    property color bgColor: "#D01A1B26" // Default semi-transparent surface

    color: bgColor
    radius: 15
    border.color: "#30C8A8E9" // Soft lilac border
    border.width: 1

    RowLayout {
        id: item
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12
    }
}

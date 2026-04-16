import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    ListModel {
        id: mangaModel
    }

    function searchManga(query) {
        Process.run(["python", "scripts/media_fetcher.py", "manga", query], (output) => {
            try {
                const results = JSON.parse(output);
                mangaModel.clear();
                if (Array.isArray(results)) {
                    results.forEach(item => {
                        mangaModel.append({
                            "title": item.title,
                            "cover_url": item.cover_url,
                            "id": item.id
                        });
                    });
                } else {
                    console.error("Search error:", results.message);
                }
            } catch (e) {
                console.error("Failed to parse search results:", e);
            }
        });
    }

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
                id: searchInput
                anchors.fill: parent
                anchors.margins: 10
                text: "Search manga..."
                color: "#E0E0E0"
                verticalAlignment: Text.AlignVCenter
                onAccepted: searchManga(text)

                // Reset text on focus
                onActiveFocusChanged: {
                    if (activeFocus && text === "Search manga...") {
                        text = "";
                    }
                }
            }
        }

        // Manga Grid
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 100; cellHeight: 140
            clip: true

            model: mangaModel
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

                        Image {
                            width: 60; height: 80
                            source: model.cover_url
                            fillMode: Image.PreserveAspectCrop
                            radius: 4
                        }

                        Text {
                            text: model.title
                            color: "#E0E0E0"
                            font.pixelSize: 10
                            width: 80
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}

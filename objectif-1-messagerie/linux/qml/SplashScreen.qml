import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    color: Theme.brand

    Column {
        anchors.centerIn: parent
        spacing: 22

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "NGoma"
            color: "white"
            font.pixelSize: 48
            font.bold: true
        }
        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: true
            palette.dark: "white"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Chargement…"
            color: "#FFFFFFD9"
        }
    }
}

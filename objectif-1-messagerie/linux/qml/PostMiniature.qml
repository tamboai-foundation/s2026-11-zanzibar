import QtQuick
import QtQuick.Controls.Basic

// Vignette d'une publication (profils, liste de mes vidéos).
Rectangle {
    id: mini
    property var post
    readonly property var palette2: [["#F43F5E", "#FB923C"], ["#4F46E5", "#38BDF8"], ["#059669", "#A3E635"], ["#C026D3", "#F472B6"], ["#1E293B", "#64748B"]]
    width: 120
    height: 180
    radius: 16
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: mini.post ? mini.palette2[mini.post.id % 5][0] : "#999" }
        GradientStop { position: 1.0; color: mini.post ? mini.palette2[mini.post.id % 5][1] : "#666" }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        spacing: 2
        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            color: "white"
            font.pixelSize: 12
            font.bold: true
            text: mini.post && mini.post.caption ? mini.post.caption : "Vidéo"
        }
        Label { color: "white"; opacity: 0.85; font.pixelSize: 12; text: "❤️ " + (mini.post ? mini.post.likes.length : 0) }
    }
}

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

// Fil de vidéos façon TikTok (M1 SI, module 3) : défilement vertical page par page, publier, aimer, commenter,
// modifier et supprimer ses vidéos. La lecture vidéo n'est pas incluse : à ajouter avec Qt Multimedia sur `mediaPath` (les photos sont affichées).
Rectangle {
    id: videos
    color: "black"

    property bool mineOnly: false
    property int commentsFor: 0
    readonly property var gradients: [["#F43F5E", "#FB923C"], ["#4F46E5", "#38BDF8"], ["#059669", "#A3E635"], ["#C026D3", "#F472B6"], ["#1E293B", "#64748B"]]

    function isImage(path) {
        return /\.(jpe?g|png|gif|webp|bmp)$/i.test(path)
    }

    function fileName(path) {
        var i = Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\"))
        return path.substring(i + 1)
    }

    ListView {
        id: feed
        anchors.fill: parent
        orientation: ListView.Vertical
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: videos.mineOnly ? MockBridge.userPosts(MockBridge.me) : MockBridge.feed()

        delegate: Rectangle {
            id: page
            required property var modelData
            width: feed.width
            height: feed.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: videos.gradients[page.modelData.id % 5][0] }
                GradientStop { position: 1.0; color: videos.gradients[page.modelData.id % 5][1] }
            }

            Column {
                anchors.centerIn: parent
                width: parent.width - 200
                spacing: 8
                Image {
                    width: parent.width
                    height: visible ? Math.min(implicitHeight, 420) : 0
                    visible: page.modelData.mediaPath !== "" && videos.isImage(page.modelData.mediaPath)
                    source: visible ? page.modelData.mediaPath : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: page.modelData.mediaPath !== "" && !videos.isImage(page.modelData.mediaPath)
                    color: "white"
                    text: "🎬 " + videos.fileName(page.modelData.mediaPath)
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                    text: page.modelData.caption
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 90
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#99000000" }
                }
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    spacing: 8
                    Avatar { name: MockBridge.authorName(page.modelData.authorId); size: 32 }
                    Label { anchors.verticalCenter: parent.verticalCenter; color: "white"; font.bold: true; text: MockBridge.authorName(page.modelData.authorId) }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        opacity: 0.7
                        font.pixelSize: 12
                        text: MockBridge.timeAgo(page.modelData.time) + (page.modelData.edited ? " · modifié" : "")
                    }
                }
            }

            Column {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Column {
                    spacing: 2
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 30
                        text: page.modelData.likes.indexOf(MockBridge.me) >= 0 ? "❤️" : "🤍"
                        MouseArea { anchors.fill: parent; onClicked: MockBridge.toggleLike(page.modelData.id) }
                    }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; color: "white"; font.bold: true; font.pixelSize: 12; text: page.modelData.likes.length }
                }
                Column {
                    spacing: 2
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 30
                        text: "💬"
                        MouseArea { anchors.fill: parent; onClicked: videos.commentsFor = page.modelData.id }
                    }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; color: "white"; font.bold: true; font.pixelSize: 12; text: MockBridge.commentCount(page.modelData.id) }
                }
                Label {
                    visible: page.modelData.authorId === MockBridge.me
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.pixelSize: 30
                    text: "⋮"
                    MouseArea { anchors.fill: parent; onClicked: postMenu.popup() }
                    Menu {
                        id: postMenu
                        MenuItem { text: "Modifier la légende"; onTriggered: { editDialog.postId = page.modelData.id; editField.text = page.modelData.caption; editDialog.open() } }
                        MenuItem { text: "Supprimer la vidéo"; onTriggered: MockBridge.removePost(page.modelData.id) }
                    }
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: feed.count === 0
        color: "white"
        opacity: 0.8
        text: videos.mineOnly ? "Vous n'avez rien publié pour l'instant." : "Aucune publication pour le moment."
    }

    // Barre du haut : Pour vous / Mes vidéos / + Publier
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 52
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#80000000" }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Row {
            anchors.centerIn: parent
            spacing: 24
            Label { color: "white"; font.bold: true; opacity: videos.mineOnly ? 0.6 : 1; text: "Pour vous"; MouseArea { anchors.fill: parent; onClicked: videos.mineOnly = false } }
            Label { color: "white"; font.bold: true; opacity: videos.mineOnly ? 1 : 0.6; text: "Mes vidéos"; MouseArea { anchors.fill: parent; onClicked: videos.mineOnly = true } }
        }
        Button {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "+ Publier"
            palette.button: Theme.brand
            palette.buttonText: "white"
            onClicked: { publishCaption.text = ""; publishDialog.mediaPath = ""; publishDialog.open() }
        }
    }

    // Commentaires et réponses
    Rectangle {
        anchors.fill: parent
        visible: videos.commentsFor !== 0
        color: "#66000000"
        MouseArea { anchors.fill: parent; onClicked: videos.commentsFor = 0 }

        Rectangle {
            id: panel
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 420
            color: Theme.surface

            property int replyTo: 0
            property int editing: 0
            readonly property var all: videos.commentsFor !== 0 ? MockBridge.commentsOf(videos.commentsFor) : []
            function visibleOnes() {
                return all.filter(function (c) {
                    return !c.deleted || all.some(function (r) { return r.parentId === c.id && !r.deleted })
                })
            }
            function roots() { return visibleOnes().filter(function (c) { return c.parentId === 0 }) }
            function repliesOf(id) { return visibleOnes().filter(function (c) { return c.parentId === id }) }
            function submit() {
                var value = commentField.text.trim()
                if (value === "") return
                if (editing) MockBridge.editComment(editing, value)
                else {
                    var parent = 0
                    all.forEach(function (c) { if (c.id === replyTo) parent = c.parentId ? c.parentId : c.id })
                    MockBridge.addComment(videos.commentsFor, value, parent)
                }
                commentField.text = ""; replyTo = 0; editing = 0
            }

            MouseArea { anchors.fill: parent }   // les clics dans le panneau ne ferment pas

            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 12
                    Label { Layout.fillWidth: true; font.bold: true; text: "Commentaires (" + MockBridge.commentCount(videos.commentsFor) + ")" }
                    Button { flat: true; text: "✕"; onClicked: videos.commentsFor = 0 }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.hairline }
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 12
                    clip: true
                    spacing: 12
                    model: panel.roots()
                    delegate: Column {
                        id: thread
                        required property var modelData
                        width: ListView.view.width
                        spacing: 8
                        CommentLine { width: parent.width; comment: thread.modelData; panelRef: panel; input: commentField }
                        Repeater {
                            model: panel.repliesOf(thread.modelData.id)
                            delegate: CommentLine {
                                required property var modelData
                                x: 42
                                width: thread.width - 42
                                comment: modelData
                                panelRef: panel
                                input: commentField
                            }
                        }
                    }
                    Label { visible: parent.count === 0; text: "Aucun commentaire. Soyez le premier !"; color: Theme.secondary }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.hairline }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    visible: panel.replyTo !== 0 || panel.editing !== 0
                    color: Theme.brand50
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        Label {
                            Layout.fillWidth: true
                            font.pixelSize: 12
                            color: Theme.brandDark
                            text: panel.editing !== 0 ? "Modification du commentaire" : "Réponse en cours"
                        }
                        Button { flat: true; text: "Annuler"; onClicked: { panel.replyTo = 0; panel.editing = 0; commentField.text = "" } }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 12
                    TextField { id: commentField; Layout.fillWidth: true; placeholderText: "Ajouter un commentaire…"; onAccepted: panel.submit() }
                    Button { text: panel.editing !== 0 ? "✓" : "➤"; enabled: commentField.text.trim() !== ""; onClicked: panel.submit() }
                }
            }
        }
    }

    FileDialog {
        id: videoFile
        title: "Choisir une photo ou une vidéo"
        nameFilters: ["Photos et vidéos (*.jpg *.jpeg *.png *.gif *.webp *.bmp *.mp4 *.mov *.mkv *.webm *.avi)", "Tous les fichiers (*)"]
        onAccepted: publishDialog.mediaPath = selectedFile.toString()
    }

    Popup {
        id: publishDialog
        property string mediaPath: ""
        anchors.centerIn: parent
        width: 420
        modal: true
        padding: 20
        background: Rectangle { color: Theme.surface; radius: 20 }
        contentItem: ColumnLayout {
            spacing: 12
            Label { text: "Publier"; font.pixelSize: 20; font.bold: true }
            Button {
                Layout.fillWidth: true
                text: publishDialog.mediaPath !== "" ? "🎬 " + videos.fileName(publishDialog.mediaPath) : "Ajouter une photo ou une vidéo (facultatif)"
                onClicked: videoFile.open()
            }
            TextField { id: publishCaption; Layout.fillWidth: true; placeholderText: "Légende" }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button { flat: true; text: "Annuler"; onClicked: publishDialog.close() }
                Button {
                    text: "Publier"
                    enabled: publishDialog.mediaPath !== "" || publishCaption.text.trim() !== ""
                    onClicked: {
                        MockBridge.publish(publishCaption.text, publishDialog.mediaPath)
                        publishDialog.close()
                        videos.mineOnly = false
                        feed.positionViewAtBeginning()
                    }
                }
            }
        }
    }

    Popup {
        id: editDialog
        property int postId: 0
        anchors.centerIn: parent
        width: 420
        modal: true
        padding: 20
        background: Rectangle { color: Theme.surface; radius: 20 }
        contentItem: ColumnLayout {
            spacing: 12
            Label { text: "Modifier la légende"; font.pixelSize: 20; font.bold: true }
            TextField { id: editField; Layout.fillWidth: true }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button { flat: true; text: "Annuler"; onClicked: editDialog.close() }
                Button { text: "Enregistrer"; onClicked: { MockBridge.editPost(editDialog.postId, editField.text); editDialog.close() } }
            }
        }
    }
}

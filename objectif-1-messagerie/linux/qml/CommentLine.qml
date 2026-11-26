import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Une ligne de commentaire ou de réponse : aimer, répondre, modifier et supprimer les siens.
// `panelRef` : panneau de commentaires (propriétés replyTo / editing) ; `input` : champ de saisie du panneau.
Item {
    id: line
    property var comment
    property var panelRef
    property var input
    implicitHeight: content.implicitHeight

    RowLayout {
        id: content
        width: parent.width
        spacing: 10
        Avatar { Layout.alignment: Qt.AlignTop; name: MockBridge.authorName(line.comment.authorId); size: 32 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Label {
                Layout.fillWidth: true
                font.pixelSize: 13
                elide: Text.ElideRight
                text: MockBridge.authorName(line.comment.authorId) + "  ·  " + MockBridge.timeAgo(line.comment.time) + (line.comment.edited ? " · modifié" : "")
            }
            Label {
                Layout.fillWidth: true
                visible: line.comment.deleted
                color: Theme.secondary
                font.italic: true
                text: "Commentaire supprimé"
            }
            Label {
                Layout.fillWidth: true
                visible: !line.comment.deleted
                wrapMode: Text.WordWrap
                text: line.comment.text
            }
            Row {
                visible: !line.comment.deleted
                spacing: 14
                Label {
                    color: Theme.secondary
                    font.pixelSize: 12
                    text: (line.comment.likes.indexOf(MockBridge.me) >= 0 ? "❤️ " : "🤍 ") + line.comment.likes.length
                    MouseArea { anchors.fill: parent; onClicked: MockBridge.toggleCommentLike(line.comment.id) }
                }
                Label {
                    color: Theme.secondary
                    font.pixelSize: 12
                    text: "Répondre"
                    MouseArea { anchors.fill: parent; onClicked: { line.panelRef.replyTo = line.comment.id; line.panelRef.editing = 0; line.input.forceActiveFocus() } }
                }
                Label {
                    visible: line.comment.authorId === MockBridge.me
                    color: Theme.secondary
                    font.pixelSize: 12
                    text: "Modifier"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { line.panelRef.editing = line.comment.id; line.panelRef.replyTo = 0; line.input.text = line.comment.text; line.input.forceActiveFocus() }
                    }
                }
                Label {
                    visible: line.comment.authorId === MockBridge.me
                    color: Theme.negative
                    font.pixelSize: 12
                    text: "Supprimer"
                    MouseArea { anchors.fill: parent; onClicked: MockBridge.removeComment(line.comment.id) }
                }
            }
        }
    }
}

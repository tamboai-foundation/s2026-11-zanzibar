import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: view
    color: Theme.bg

    property int conversationId: 0
    property var editing: null
    property var replyTo: null
    readonly property var conv: {
        var list = MockBridge.conversations
        for (var i = 0; i < list.length; i++) if (list[i].id === conversationId) return list[i]
        return null
    }
    readonly property var messages: MockBridge.messages.filter(function (m) { return m.conversationId === conversationId })

    function hour(t) { return Qt.formatTime(new Date(t), "HH:mm") }
    function byId(id) {
        for (var i = 0; i < messages.length; i++) if (messages[i].id === id) return messages[i]
        return null
    }
    function submit() {
        var text = input.text.trim()
        if (!text.length) return
        if (editing) MockBridge.edit(editing.id, text)
        else MockBridge.send(conversationId, text, replyTo ? replyTo.id : 0)
        input.text = ""
        editing = null
        replyTo = null
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: Theme.surface
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12
                Avatar { name: view.conv ? view.conv.title : ""; size: 40 }
                Label { text: view.conv ? view.conv.title : ""; font.pixelSize: 17; font.bold: true; Layout.fillWidth: true }
                Button { flat: true; text: "⋮"; font.pixelSize: 20; onClicked: headerMenu.open()
                    Menu {
                        id: headerMenu
                        MenuItem { text: view.conv && view.conv.pinned ? "Désépingler" : "Épingler"; onTriggered: MockBridge.setPinned(view.conversationId, !view.conv.pinned) }
                        MenuItem { text: view.conv && view.conv.muted ? "Réactiver les notifications" : "Mettre en sourdine"; onTriggered: MockBridge.setMuted(view.conversationId, !view.conv.muted) }
                        MenuItem { text: view.conv && view.conv.archived ? "Désarchiver" : "Archiver"; onTriggered: MockBridge.setArchived(view.conversationId, !view.conv.archived) }
                    }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.hairline }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            clip: true
            spacing: 6
            model: view.messages
            onCountChanged: positionViewAtEnd()
            Component.onCompleted: positionViewAtEnd()

            delegate: Item {
                id: msg
                required property var modelData
                readonly property bool mine: modelData.authorId === MockBridge.me
                readonly property var quoted: modelData.replyToId ? view.byId(modelData.replyToId) : null
                width: ListView.view.width
                height: bubble.height + (reactions.visible ? reactions.height + 2 : 0)

                Rectangle {
                    id: bubble
                    anchors.right: msg.mine ? parent.right : undefined
                    anchors.left: msg.mine ? undefined : parent.left
                    width: Math.min(460, Math.max(content.implicitWidth, 80) + 24)
                    height: content.implicitHeight + 16
                    radius: 16
                    color: msg.mine ? Theme.brand : Theme.surface

                    Column {
                        id: content
                        x: 12; y: 8
                        width: bubble.width - 24
                        spacing: 2
                        Label {
                            visible: msg.quoted !== null
                            width: parent.width
                            text: msg.quoted ? (msg.quoted.text || "Message supprimé") : ""
                            font.pixelSize: 12
                            color: msg.mine ? "#FFFFFFBF" : Theme.secondary
                            elide: Text.ElideRight
                        }
                        Label {
                            width: parent.width
                            text: msg.modelData.deleted ? "Message supprimé" : msg.modelData.text
                            font.italic: msg.modelData.deleted === true
                            wrapMode: Text.Wrap
                            color: msg.mine ? "white" : Theme.ink
                        }
                        Label {
                            anchors.right: parent.right
                            text: view.hour(msg.modelData.time) + (msg.modelData.edited ? " · modifié" : "")
                            font.pixelSize: 11
                            color: msg.mine ? "#FFFFFFA6" : Theme.grey
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: !msg.modelData.deleted
                        onClicked: msgMenu.popup()
                    }
                    Menu {
                        id: msgMenu
                        Row {
                            padding: 4
                            Repeater {
                                model: ["👍", "❤️", "😂", "😮"]
                                delegate: ToolButton {
                                    required property string modelData
                                    text: modelData
                                    onClicked: { MockBridge.react(msg.modelData.id, modelData); msgMenu.close() }
                                }
                            }
                        }
                        MenuItem { text: "Répondre"; onTriggered: { view.editing = null; view.replyTo = msg.modelData } }
                        MenuItem { visible: msg.mine; height: visible ? implicitHeight : 0; text: "Modifier"; onTriggered: { view.replyTo = null; view.editing = msg.modelData; input.text = msg.modelData.text } }
                        MenuItem { visible: msg.mine; height: visible ? implicitHeight : 0; text: "Supprimer"; onTriggered: MockBridge.remove(msg.modelData.id) }
                    }
                }

                Label {
                    id: reactions
                    anchors.top: bubble.bottom
                    anchors.topMargin: 2
                    anchors.right: msg.mine ? parent.right : undefined
                    anchors.left: msg.mine ? undefined : parent.left
                    visible: Object.keys(msg.modelData.reactions).length > 0
                    font.pixelSize: 12
                    text: Object.keys(msg.modelData.reactions).map(function (e) { return e + " " + msg.modelData.reactions[e] }).join("  ")
                }
            }
        }

        Rectangle {
            visible: view.editing !== null || view.replyTo !== null
            Layout.fillWidth: true
            height: visible ? 30 : 0
            color: Theme.brand50
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 8
                Label {
                    Layout.fillWidth: true
                    color: Theme.brandDark
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    text: view.editing ? "Modification du message" : (view.replyTo ? "Réponse à : " + view.replyTo.text : "")
                }
                ToolButton { text: "✕"; onClicked: { view.editing = null; view.replyTo = null; input.text = "" } }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: Theme.surface
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                TextField {
                    id: input
                    Layout.fillWidth: true
                    placeholderText: "Message"
                    onAccepted: view.submit()
                }
                Button {
                    id: sendBtn
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    contentItem: Label { text: view.editing ? "✓" : "➤"; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { radius: 22; color: sendBtn.down ? Theme.brandDark : Theme.brand }
                    onClicked: view.submit()
                }
            }
        }
    }
}

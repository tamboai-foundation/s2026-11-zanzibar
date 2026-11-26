import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: home
    color: Theme.bg
    signal logout()

    property int selectedId: 0
    // « Écrire un message » depuis l'écran Personnes : ouvre la conversation de cette personne (la crée si besoin).
    property string openChatWith: ""
    signal chatOpened()
    onOpenChatWithChanged: {
        if (openChatWith === "") return
        var found = null
        for (var i = 0; i < MockBridge.conversations.length; i++)
            if (MockBridge.conversations[i].title === openChatWith) found = MockBridge.conversations[i]
        selectedId = found ? found.id : MockBridge.createConversation(openChatWith)
        chatOpened()
    }
    property string filter: "Toutes"
    property string query: ""
    readonly property var filters: ["Toutes", "Non lues", "Épinglées", "Archivées"]

    function shown() {
        var list = MockBridge.conversations.filter(function (c) {
            if (home.filter === "Archivées") return c.archived
            if (c.archived) return false
            if (home.filter === "Non lues") return c.unread > 0
            if (home.filter === "Épinglées") return c.pinned
            return true
        }).filter(function (c) {
            return c.title.toLowerCase().indexOf(home.query.toLowerCase()) >= 0
        })
        list.sort(function (a, b) { return (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0) })
        return list
    }

    function conversation(id) {
        for (var i = 0; i < MockBridge.conversations.length; i++)
            if (MockBridge.conversations[i].id === id) return MockBridge.conversations[i]
        return null
    }

    function hour(t) { return Qt.formatTime(new Date(t), "HH:mm") }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            color: Theme.surface

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    spacing: 10
                    Avatar { name: MockBridge.user ? MockBridge.user.name : "?"; size: 36 }
                    Label { text: "Messages"; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
                    Button { flat: true; text: "+ Nouveau"; palette.buttonText: Theme.brand; onClicked: newDialog.open() }
                    Button { flat: true; text: "Quitter"; onClicked: home.logout() }
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    placeholderText: "Rechercher"
                    onTextChanged: home.query = text
                }

                Row {
                    Layout.margins: 12
                    spacing: 8
                    Repeater {
                        model: home.filters
                        delegate: Rectangle {
                            required property string modelData
                            readonly property bool on: modelData === home.filter
                            height: 28
                            width: chipLabel.implicitWidth + 24
                            radius: 14
                            color: on ? Theme.brand : Theme.muted
                            Label { id: chipLabel; anchors.centerIn: parent; text: parent.modelData; font.pixelSize: 13; color: parent.on ? "white" : Theme.secondary }
                            MouseArea { anchors.fill: parent; onClicked: home.filter = parent.modelData }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.hairline }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: home.shown()
                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        width: ListView.view.width
                        height: 70
                        color: modelData.id === home.selectedId ? Theme.brand50 : "transparent"

                        readonly property var last: MockBridge.lastMessage(modelData.id)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            Avatar { name: row.modelData.title; size: 46 }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                RowLayout {
                                    Label {
                                        Layout.fillWidth: true
                                        text: (row.modelData.pinned ? "📌 " : "") + row.modelData.title
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                    Label { visible: row.last !== null; text: row.last ? home.hour(row.last.time) : ""; color: Theme.grey; font.pixelSize: 12 }
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: row.last ? row.last.text : "Aucun message"
                                    color: Theme.secondary
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                            }
                            Label { visible: row.modelData.muted; text: "🔕" }
                            Rectangle {
                                visible: row.modelData.unread > 0
                                width: 24; height: 22; radius: 11
                                color: Theme.brand
                                Label { anchors.centerIn: parent; text: row.modelData.unread; color: "white"; font.pixelSize: 12 }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.hairline }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { home.selectedId = row.modelData.id; MockBridge.markRead(row.modelData.id) }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                visible: home.conversation(home.selectedId) === null
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "NGoma"; color: Theme.brand; font.pixelSize: 28; font.bold: true }
                Label { text: "Sélectionnez une conversation"; color: Theme.secondary }
            }

            Loader {
                anchors.fill: parent
                active: home.conversation(home.selectedId) !== null
                sourceComponent: ConversationView {
                    conversationId: home.selectedId
                }
            }
        }
    }

    Dialog {
        id: newDialog
        title: "Nouvelle conversation"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        TextField { id: newTitle; placeholderText: "Nom"; width: 280 }
        onAccepted: {
            if (newTitle.text.trim().length) home.selectedId = MockBridge.createConversation(newTitle.text.trim())
            newTitle.text = ""
        }
    }
}

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Mon profil (M1 SI, module 1) : modifier mon nom et ma description, voir mes vidéos, me déconnecter, supprimer mon compte.
Rectangle {
    id: profile
    color: Theme.bg
    signal logout()

    property bool saved: false
    readonly property var me: MockBridge.user
    readonly property var myPosts: { MockBridge.posts; return MockBridge.userPosts(MockBridge.me) }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(parent.width - 32, 560)
            x: Math.max(16, (parent.width - width) / 2)
            spacing: 14

            Item { Layout.preferredHeight: 2 }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: card1.implicitHeight + 48
                radius: 20
                color: Theme.surface
                ColumnLayout {
                    id: card1
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 10
                    RowLayout {
                        spacing: 14
                        Avatar { name: profile.me ? profile.me.name : "?"; size: 72 }
                        ColumnLayout {
                            Label { font.pixelSize: 24; font.bold: true; text: profile.me ? profile.me.name : "" }
                            Label {
                                color: Theme.secondary
                                font.pixelSize: 13
                                text: profile.myPosts.length + " vidéo" + (profile.myPosts.length > 1 ? "s" : "") + " publiée" + (profile.myPosts.length > 1 ? "s" : "")
                            }
                        }
                    }
                    Label { text: "Nom"; font.bold: true }
                    TextField { id: nameField; Layout.fillWidth: true; text: profile.me ? profile.me.name : "" }
                    Label { text: "Description"; font.bold: true }
                    TextArea {
                        id: bioField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        wrapMode: TextEdit.Wrap
                        placeholderText: "Parlez de vous en quelques mots"
                        text: profile.me ? profile.me.bio : ""
                        background: Rectangle { radius: 6; border.color: Theme.hairline; color: "white" }
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        text: profile.saved ? "Enregistré ✓" : "Enregistrer"
                        palette.button: Theme.brand
                        palette.buttonText: "white"
                        onClicked: {
                            MockBridge.updateProfile(nameField.text, bioField.text)
                            profile.saved = true
                            savedTimer.restart()
                        }
                    }
                    Timer { id: savedTimer; interval: 1500; onTriggered: profile.saved = false }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: card2.implicitHeight + 48
                radius: 20
                color: Theme.surface
                ColumnLayout {
                    id: card2
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 10
                    Label { text: "Mes vidéos"; font.bold: true }
                    Label { visible: profile.myPosts.length === 0; color: Theme.secondary; text: "Vous n'avez rien publié pour l'instant." }
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: profile.myPosts.length ? 190 : 0
                        orientation: ListView.Horizontal
                        spacing: 12
                        clip: true
                        model: profile.myPosts
                        delegate: PostMiniature { required property var modelData; post: modelData }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: card3.implicitHeight + 48
                radius: 20
                color: Theme.surface
                ColumnLayout {
                    id: card3
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 10
                    Button { Layout.fillWidth: true; Layout.preferredHeight: 44; text: "Se déconnecter"; onClicked: profile.logout() }
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        text: "Supprimer mon compte"
                        palette.buttonText: Theme.negative
                        onClicked: confirmDelete.open()
                    }
                }
            }

            Item { Layout.preferredHeight: 16 }
        }
    }

    Dialog {
        id: confirmDelete
        title: "Supprimer le compte ?"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        Label { text: "Cette action est définitive." }
        onAccepted: { MockBridge.deleteAccount(); profile.logout() }
    }
}

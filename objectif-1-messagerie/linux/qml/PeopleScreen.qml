import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Gestion des utilisateurs (M1 SI, module 1) : voir les utilisateurs, rechercher, ouvrir un profil, écrire à quelqu'un.
Rectangle {
    id: people
    color: Theme.bg
    signal write(string name)

    property string query: ""
    property int selectedId: 0
    readonly property var selectedUser: { MockBridge.user; return MockBridge.userById(selectedId) }

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

                Label { text: "Personnes"; font.pixelSize: 20; font.bold: true; Layout.margins: 16 }
                TextField {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    placeholderText: "Rechercher un utilisateur"
                    onTextChanged: people.query = text
                }
                Label {
                    Layout.margins: 12
                    color: Theme.secondary
                    font.pixelSize: 12
                    text: list.count + " utilisateur" + (list.count > 1 ? "s" : "")
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.hairline }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: MockBridge.users(people.query)
                    delegate: Rectangle {
                        required property var modelData
                        width: list.width
                        height: 68
                        color: modelData.id === people.selectedId ? Theme.brand50 : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            Avatar { name: modelData.name; size: 44 }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.bold: true
                                    text: modelData.name + (modelData.id === MockBridge.me ? " (vous)" : "")
                                }
                                Label {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    color: Theme.secondary
                                    font.pixelSize: 13
                                    text: modelData.bio ? modelData.bio : "Pas de description"
                                }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.hairline }
                        MouseArea { anchors.fill: parent; onClicked: people.selectedId = modelData.id }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                anchors.centerIn: parent
                visible: !people.selectedUser
                color: Theme.secondary
                text: "Sélectionnez une personne"
            }

            ColumnLayout {
                anchors.fill: parent
                visible: !!people.selectedUser
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: detail.implicitHeight + 48
                    color: Theme.surface
                    ColumnLayout {
                        id: detail
                        anchors.centerIn: parent
                        spacing: 6
                        Avatar { Layout.alignment: Qt.AlignHCenter; name: people.selectedUser ? people.selectedUser.name : ""; size: 84 }
                        Label { Layout.alignment: Qt.AlignHCenter; font.pixelSize: 24; font.bold: true; text: people.selectedUser ? people.selectedUser.name : "" }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            color: Theme.secondary
                            text: people.selectedUser && people.selectedUser.bio ? people.selectedUser.bio : "Pas de description"
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            color: Theme.grey
                            font.pixelSize: 12
                            visible: !!people.selectedUser && people.selectedUser.joinedAt > 0
                            text: people.selectedUser ? "Membre depuis le " + Qt.formatDate(new Date(people.selectedUser.joinedAt), "dd/MM/yyyy") : ""
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            visible: !!people.selectedUser && people.selectedUser.id !== MockBridge.me
                            text: "Écrire un message"
                            palette.button: Theme.brand
                            palette.buttonText: "white"
                            onClicked: people.write(people.selectedUser.name)
                        }
                    }
                }

                Label {
                    Layout.margins: 16
                    font.bold: true
                    text: "Vidéos (" + posts.count + ")"
                }
                Label {
                    Layout.leftMargin: 16
                    visible: posts.count === 0
                    color: Theme.secondary
                    text: "Aucune vidéo publiée."
                }
                ListView {
                    id: posts
                    Layout.fillWidth: true
                    Layout.preferredHeight: 190
                    Layout.leftMargin: 16
                    orientation: ListView.Horizontal
                    spacing: 12
                    clip: true
                    model: people.selectedUser ? MockBridge.userPosts(people.selectedUser.id) : []
                    delegate: PostMiniature { required property var modelData; post: modelData }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}

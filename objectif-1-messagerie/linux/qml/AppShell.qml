import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Cadre de l'application : une barre d'onglets à gauche (Messages, Vidéos, Personnes, Profil) et l'écran actif.
Rectangle {
    id: shell
    color: Theme.bg
    signal logout()

    property int tabIndex: 0
    // Demande d'ouverture d'une conversation avec une personne (bouton « Écrire un message » de l'écran Personnes)
    property string chatWith: ""
    readonly property var tabs: [
        { label: "Messages", icon: "💬" },
        { label: "Vidéos", icon: "▶️" },
        { label: "Personnes", icon: "👥" },
        { label: "Profil", icon: "🙂" }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 84
            Layout.fillHeight: true
            color: Theme.surface

            Column {
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: shell.tabs
                    delegate: Rectangle {
                        required property int index
                        required property var modelData
                        readonly property bool on: index === shell.tabIndex
                        width: 72
                        height: 58
                        radius: 12
                        color: on ? Theme.brand50 : "transparent"
                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.modelData.icon; font.pixelSize: 22 }
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: parent.parent.modelData.label
                                font.pixelSize: 11
                                font.bold: true
                                color: parent.parent.on ? Theme.brand : Theme.secondary
                            }
                        }
                        MouseArea { anchors.fill: parent; onClicked: shell.tabIndex = parent.index }
                    }
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: shell.tabIndex

            HomeScreen {
                openChatWith: shell.chatWith
                onChatOpened: shell.chatWith = ""
                onLogout: shell.logout()
            }
            VideosScreen {}
            PeopleScreen {
                onWrite: function (name) {
                    shell.chatWith = name
                    shell.tabIndex = 0
                }
            }
            ProfileScreen { onLogout: shell.logout() }
        }
    }
}

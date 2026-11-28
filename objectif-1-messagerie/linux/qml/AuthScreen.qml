import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.bg
    signal done()

    property bool registering: false

    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: form.implicitHeight + 64
        radius: 20
        color: Theme.surface
        border.color: Theme.hairline

        ColumnLayout {
            id: form
            anchors.fill: parent
            anchors.margins: 32
            spacing: 14

            Label { text: "NGoma"; color: Theme.brand; font.pixelSize: 32; font.bold: true }
            Label { text: page.registering ? "Créer un compte" : "Connexion"; color: Theme.secondary }

            TextField { id: nameField; visible: page.registering; placeholderText: "Nom"; Layout.fillWidth: true }
            TextField { id: idField; placeholderText: "Téléphone ou e-mail"; Layout.fillWidth: true }
            TextField {
                id: pwdField
                placeholderText: "Mot de passe"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                onAccepted: submit.clicked()
            }

            Button {
                id: submit
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                text: page.registering ? "S'inscrire" : "Se connecter"
                contentItem: Label { text: submit.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { radius: 12; color: submit.down ? Theme.brandDark : Theme.brand }
                onClicked: {
                    if (page.registering) MockBridge.register(nameField.text, idField.text, pwdField.text)
                    else MockBridge.login(idField.text, pwdField.text)
                    page.done()
                }
            }
            Button {
                flat: true
                Layout.alignment: Qt.AlignHCenter
                text: page.registering ? "J'ai déjà un compte" : "Créer un compte"
                palette.buttonText: Theme.brand
                onClicked: page.registering = !page.registering
            }
            Label { text: "Mode démo : tout identifiant est accepté."; color: Theme.grey; font.pixelSize: 12 }
        }
    }
}

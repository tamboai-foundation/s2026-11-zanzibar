import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: avatar
    property string name: ""
    property int size: 44
    width: size
    height: size
    radius: size / 2
    color: Theme.brand100

    Label {
        anchors.centerIn: parent
        text: avatar.name.length ? avatar.name.charAt(0).toUpperCase() : "?"
        color: Theme.brandDark
        font.bold: true
        font.pixelSize: avatar.size / 2.4
    }
}

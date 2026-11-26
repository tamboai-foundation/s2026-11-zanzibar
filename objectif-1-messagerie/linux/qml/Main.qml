import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Window {
    id: root
    width: 1100
    height: 720
    visible: true
    title: "NGoma"
    color: Theme.bg

    property string phase: "splash"   // splash | auth | home

    Timer {
        interval: 900
        running: true
        onTriggered: root.phase = MockBridge.restoreSession() ? "home" : "auth"
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root.phase === "splash" ? splash : root.phase === "auth" ? auth : home
    }

    Component { id: splash; SplashScreen {} }
    Component { id: auth; AuthScreen { onDone: root.phase = "home" } }
    Component { id: home; AppShell { onLogout: { MockBridge.logout(); root.phase = "auth" } } }
}

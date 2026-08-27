import Quickshell
import Quickshell.Wayland
import QtQuick
import "../"

// Manual toggle for the Wayland idle-inhibit protocol (screen lock/blank
// suppression) - e.g. for watching a video without the compositor idling.
// Purely a click toggle; nothing else in the shell drives `inhibiting`.
Text {
    id: root

    property bool inhibiting: false

    text: inhibiting ? "\uf06e" : "\uf070"  // fa-eye / fa-eye-slash
    color: inhibiting ? Theme.tertiary : Theme.secondary
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }

    // `IdleInhibitor` here is Quickshell.Wayland's protocol object, not
    // this file's own type (same name, different thing). `QsWindow.window`
    // is an attached property that resolves to the PanelWindow this Text
    // lives in - the inhibitor needs a real wl_surface to attach to.
    IdleInhibitor {
        enabled: root.inhibiting
        window: QsWindow.window
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: root.inhibiting = !root.inhibiting
    }
}

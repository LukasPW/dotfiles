import Quickshell
import Quickshell.Wayland
import QtQuick

Text {
    id: root

    property bool inhibiting: false

    text: inhibiting ? "\uf06e" : "\uf070"  // fa-eye / fa-eye-slash
    color: inhibiting ? "#e0af68" : "#7aa2f7"
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }

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

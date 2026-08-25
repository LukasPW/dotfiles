import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland // Hyprland IPC accsess
import QtQuick
import QtQuick.Layouts // For RowLayout
import Quickshell.Io
import "../"

RowLayout {
    id: workspaces
    spacing: 4
    property int startWs: 1
    property int wScount: 10

    Repeater {
        model: wScount

        Text {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + startWs)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + startWs)

            text: index + startWs
            color: isActive ? Theme.primary : (ws ? Theme.secondary : Theme.outline)
            font {
                pixelSize: 14
                bold: true
                family: "Maple Mono NF CN"
            }
            // Click to switch workspaces
            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${index + startWs}})`)
            }
        }
    }
}

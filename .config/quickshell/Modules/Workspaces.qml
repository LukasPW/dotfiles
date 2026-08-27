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
    // Always renders workspaces startWs..startWs+wScount-1 regardless of
    // whether they actually exist yet, so the bar has a stable set of click
    // targets instead of workspace numbers appearing/disappearing as
    // windows are opened and closed.
    property int startWs: 1
    property int wScount: 10

    Repeater {
        model: wScount

        Text {
            // `ws` is undefined until at least one window has opened on
            // that workspace - used only to dim never-used workspaces.
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + startWs)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + startWs)

            text: index + startWs
            color: isActive ? Theme.primary : (ws ? Theme.secondary : Theme.outline)
            font {
                pixelSize: 14
                bold: true
                family: "Maple Mono NF CN"
            }
            // Click to switch workspaces. The dispatch string is Hyprland's
            // Lua-ish IPC call syntax, not QML - see `hyprctl dispatch`.
            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = ${index + startWs}})`)
            }
        }
    }
}

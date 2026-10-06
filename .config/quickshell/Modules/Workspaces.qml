import Quickshell
import QtQuick
import QtQuick.Layouts
import "../"

// Bar workspace switcher - compositor-agnostic front end.
//
// The supported compositors are rendered differently because of design differences
// in workspace handling:
//
//   - Hyprland: a fixed row of slots startWs..startWs+wScount-1, always
//     present as click targets (identical to the original Hyprland-only
//     module, kept as Modules/WorkspacesLegacy.qml). State and switching
//     come from Wm/HyprlandService.qml, which is an unchanged lift of the
//     legacy logic.
//
//   - Sway/swayfx: shares Hyprland's fixed slot row. Sway workspace
//     numbers are global (not per-monitor) like Hyprland's, and Sway only
//     lists a workspace while it has windows or is visible on an output,
//     which gives the same populated/empty signal the bar dims on.
//     State and switching come from Wm/SwayService.qml via Quickshell.I3;
//     clicking a slot runs `workspace number N`, which creates the
//     workspace on demand. Named-only workspaces (no leading number,
//     e.g. "web") report number -1 and don't map to any slot.
//
//   - niri: dynamic. niri has no fixed workspace count, so the bar renders
//     one entry per live workspace (from Wm/NiriService.qml, streamed off
//     $NIRI_SOCKET), appearing/disappearing as niri adds/removes them.
//
// Colouring is the same in all cases:
//   Theme.primary   focused   /   Theme.secondary populated   /   Theme.outline empty
//
// On an unrecognised compositor no backend loads and nothing renders.
RowLayout {
    id: workspaces
    spacing: 4

    // Hyprland and Sway - the fixed slot range. Ignored under niri.
    property int startWs: 1
    property int wScount: 10

    // Active backend instance (HyprlandService / NiriService / SwayService), or null.
    readonly property var svc: backendLoader.item

    // niri workspace indices are per-monitor, so the backend needs to know
    // which output this bar belongs to. Ignored by the Hyprland and Sway backends.
    readonly property string outputName: (QsWindow.window && QsWindow.window.screen) ? QsWindow.window.screen.name : ""

    Loader {
        id: backendLoader
        source: {
            if (Compositor.isHyprland)
                return "Wm/HyprlandService.qml";
            if (Compositor.isNiri)
                return "Wm/NiriService.qml";
            if (Compositor.isSway) {
                return "Wm/SwayService.qml";
            }
            return "";
        }
    }

    Binding {
        target: workspaces.svc
        property: "outputName"
        value: workspaces.outputName
        when: workspaces.svc !== null
    }

    // --- Fixed slot row: Hyprland and Sway ---
    // Both use global workspace numbers, one delegate serves both.
    Repeater {
        model: (Compositor.isHyprland || Compositor.isSway) ? workspaces.wScount : 0

        Text {
            readonly property int wsNum: index + workspaces.startWs
            readonly property bool isActive: workspaces.svc ? workspaces.svc.focusedNumber === wsNum : false
            readonly property bool populated: workspaces.svc ? workspaces.svc.populatedNumbers.indexOf(wsNum) >= 0 : false

            text: wsNum
            color: isActive ? Theme.primary : (populated ? Theme.secondary : Theme.outline)
            font {
                pixelSize: 14
                bold: true
                family: "Maple Mono NF CN"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: if (workspaces.svc)
                    workspaces.svc.activate(wsNum)
            }
        }
    }

    // --- niri: one entry per live workspace ---
    Repeater {
        model: (Compositor.isNiri && workspaces.svc) ? workspaces.svc.workspaces : []

        Text {
            required property var modelData

            text: modelData.label
            color: modelData.focused ? Theme.primary : (modelData.populated ? Theme.secondary : Theme.outline)
            font {
                pixelSize: 14
                bold: true
                family: "Maple Mono NF CN"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: if (workspaces.svc)
                    workspaces.svc.activate(modelData.idx)
            }
        }
    }
}

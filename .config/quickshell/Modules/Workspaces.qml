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
//   - Mango: tags, A fixed row of slots like Hyprland/Sway,
//     but tags are per-monitor and several can be selected at once, so the
//     backend exposes selectedNumbers (array) instead of a single
//     focusedNumber. State comes from `mmsg watch all-monitors` via
//     Wm/MangoService.qml, which also provides the current layout symbol,
//     shown after the slots.
//
// Colouring is the same in all cases:
//   Theme.primary   focused   /   Theme.secondary populated   /   Theme.outline empty
//
// On an unrecognised compositor no backend loads and nothing renders.
RowLayout {
    id: workspaces
    spacing: 4

    // Hyprland and Sway - the fixed slot range. Ignored under niri.
    // Mango uses its own tag count instead of wScount.
    property int startWs: 1
    property int wScount: 10

    // Active backend instance (HyprlandService / NiriService / SwayService / MangoService), or null.
    readonly property var svc: backendLoader.item

    // How many fixed slots to draw: Mango's tag count, wScount for Hyprland/Sway, none for niri.
    readonly property int slotCount: Compositor.isMango ? (svc ? svc.tagCount : 9) : ((Compositor.isHyprland || Compositor.isSway) ? wScount : 0)

    // niri workspace indices and Mango tags are per-monitor, so the backend
    // needs to know which output this bar belongs to. Ignored by the Hyprland
    // and Sway backends.
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
            if (Compositor.isMango)
                return "Wm/MangoService.qml";
            return "";
        }
    }

    Binding {
        target: workspaces.svc
        property: "outputName"
        value: workspaces.outputName
        when: workspaces.svc !== null
    }

    // --- Fixed slot row: Hyprland, Sway and Mango ---
    // One delegate serves all three. Backends that can have several active
    // slots (Mango) expose selectedNumbers; the others fall back to focusedNumber.
    Repeater {
        model: workspaces.slotCount

        Text {
            readonly property int wsNum: index + workspaces.startWs
            readonly property bool isActive: workspaces.svc ? (workspaces.svc.selectedNumbers ? workspaces.svc.selectedNumbers.indexOf(wsNum) >= 0 : workspaces.svc.focusedNumber === wsNum) : false
            readonly property bool populated: workspaces.svc ? workspaces.svc.populatedNumbers.indexOf(wsNum) >= 0 : false

            text: wsNum
            color: isActive ? Theme.primary : (populated ? Theme.secondary : Theme.outline)
            font {
                pixelSize: Theme.fontsizeSmall
                bold: true
                family: Theme.fontFamily
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

    // --- Mango: current layout symbol (T, S, DW, ...) ---
    Text {
        visible: Compositor.isMango && workspaces.svc !== null
        text: workspaces.svc ? workspaces.svc.layout : ""
        color: Theme.secondary
        font {
            pixelSize: 14
            bold: true
            family: "Maple Mono NF CN"
        }
    }
}

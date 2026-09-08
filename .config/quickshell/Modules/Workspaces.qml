import Quickshell
import QtQuick
import QtQuick.Layouts
import "../"

// Bar workspace switcher - compositor-agnostic front end.
//
// The two compositors are rendered differently on purpose:
//
//   - Hyprland: a fixed row of slots startWs..startWs+wScount-1, always
//     present as click targets (identical to the original Hyprland-only
//     module, kept as Modules/WorkspacesLegacy.qml). State and switching
//     come from Wm/HyprlandService.qml, which is an unchanged lift of the
//     legacy logic.
//
//   - niri: dynamic. niri has no fixed workspace count, so the bar renders
//     one entry per live workspace (from Wm/NiriService.qml, streamed off
//     $NIRI_SOCKET), appearing/disappearing as niri adds/removes them.
//
// Colouring is the same in both cases:
//   Theme.primary   focused   /   Theme.secondary populated   /   Theme.outline empty
//
// On an unrecognised compositor no backend loads and nothing renders.
RowLayout {
    id: workspaces
    spacing: 4

    // Hyprland only - the fixed slot range. Ignored under niri.
    property int startWs: 1
    property int wScount: 10

    // Active backend instance (HyprlandService / NiriService), or null.
    readonly property var svc: backendLoader.item

    // niri workspace indices are per-monitor, so the backend needs to know
    // which output this bar belongs to. Ignored by the Hyprland backend.
    readonly property string outputName: (QsWindow.window && QsWindow.window.screen) ? QsWindow.window.screen.name : ""

    Loader {
        id: backendLoader
        source: {
            if (Compositor.isHyprland)
                return "Wm/HyprlandService.qml";
            if (Compositor.isNiri)
                return "Wm/NiriService.qml";
            return "";
        }
    }

    Binding {
        target: workspaces.svc
        property: "outputName"
        value: workspaces.outputName
        when: workspaces.svc !== null
    }

    // --- Hyprland: fixed slot row (unchanged legacy behaviour) ---
    Repeater {
        model: Compositor.isHyprland ? workspaces.wScount : 0

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

import QtQuick
import Quickshell.Hyprland

// Hyprland workspace backend for Modules/Workspaces.qml.
//
// A straight lift of the reads and the dispatch string from the original
// Modules/WorkspacesLegacy.qml, so Hyprland behaviour is byte-for-byte
// unchanged:
//   - focusedNumber   <- Hyprland.focusedWorkspace.id
//   - populatedNumbers <- ids of every workspace Hyprland currently lists
//     (Hyprland only lists a workspace once it has a window or is focused,
//     which is exactly the "has this ever been used" signal the bar dims on)
//   - activate(n)      -> Hyprland.dispatch("hl.dsp.focus({workspace = n})")
//
// `outputName` is part of the shared backend interface but unused here:
// Hyprland workspace ids are global, not per-monitor.
QtObject {
    id: root

    property string outputName: ""

    readonly property int focusedNumber: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
    readonly property var populatedNumbers: Hyprland.workspaces.values.map(w => w.id)

    function activate(n) {
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${n}})`);
    }
}

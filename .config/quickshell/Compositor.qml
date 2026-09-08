pragma Singleton
import QtQuick
import Quickshell

// Which Wayland compositor the shell is running under. Detection is by the
// well-known environment variables each compositor exports for its
// clients, with XDG_CURRENT_DESKTOP as a last-resort fallback.
//
// Used by Modules/Workspaces.qml to pick a workspace backend; intended as
// the single home for compositor branching as more modules need it
// (power menu, screenshot launchers, ...).
QtObject {
    // "hyprland" | "niri" | "unknown"
    readonly property string id: {
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
            return "hyprland";
        if (Quickshell.env("NIRI_SOCKET"))
            return "niri";
        const xdg = (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase();
        if (xdg.includes("hyprland"))
            return "hyprland";
        if (xdg.includes("niri"))
            return "niri";
        return "unknown";
    }

    readonly property bool isHyprland: id === "hyprland"
    readonly property bool isNiri: id === "niri"
}

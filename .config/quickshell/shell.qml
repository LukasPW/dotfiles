import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland // Hyprland IPC accsess
import QtQuick
import QtQuick.Layouts // For RowLayout
import Quickshell.Io
import "."
import "Modules"
import "Modules/Lock"

ShellRoot {
    LockScreen {
        id: lockScreen
    }

    // Exposes `qs ipc call lock lock` on this instance's IPC socket.
    // hypridle.conf's lock_cmd/before_sleep_cmd and the SUPER+L bind in
    // hyprland.lua both call this instead of driving a separate swaylock
    // process, so the lock screen shares this shell's Theme/fonts.
    IpcHandler {
        target: "lock"

        function lock(): void {
            lockScreen.locked = true;
        }
    }

    // One PanelWindow bar per connected monitor - Variants re-instantiates
    // the delegate for each entry in `model` and rebuilds it if the screen
    // list changes (monitor plugged/unplugged).
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData

            color: Theme.background
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30
            // Left-aligned and right-aligned module groups. Add new modules
            // here (and to Modules/ + this import list) rather than
            // creating a new PanelWindow - there's exactly one bar per
            // screen, laid out as two independent RowLayouts.
            RowLayout {
                id: leftcontent
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Workspaces {}
                IdleInhibitor {}
                Brightness {}
            }
            RowLayout {
                id: rightcontent
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Network {}
                Battery {}
                Volume {}
                Clock {}
            }
        }
    }
}

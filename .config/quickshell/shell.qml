import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland // Hyprland IPC accsess
import QtQuick
import QtQuick.Layouts // For RowLayout
import Quickshell.Io
import "Modules"

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData

            color: "#0f1511"
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30
            RowLayout {
                id: leftcontent
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Workspaces {}
                IdleInhibitor {}
            }
            RowLayout {
                id: rightcontent
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                Battery {}
                Volume {}
                Clock {}
            }
        }
    }
}

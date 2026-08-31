import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../"

// StatusNotifierItem tray (Discord, Steam, syncthing, etc.). Left click
// activates, middle click secondary-activates, scroll forwards to the
// item, right click opens its DBusMenu.
//
// Left click prefers the menu over activate() for anything that isn't
// Category.ApplicationStatus (i.e. doesn't represent a real app window) -
// `onlyMenu` alone isn't enough to catch this: it mirrors the optional
// ItemIsMenu DBus property, which nm-applet's SNI (`busctl --user
// introspect ... /org/ayatana/NotificationItem/nm_applet`) never sets, and
// it also has no Activate method at all, so activate() was a silent no-op
// (Quickshell just logs a debug line and gives up, no fallback). Its
// Category is "SystemServices" though, which - per the SNI spec - is
// exactly the "indicator, not an app" signal ApplicationStatus is meant to
// be distinguished from, so that's the more reliable check here.
//
// The menu itself is drawn by TrayMenu.qml rather than the native
// QsMenuAnchor popup - see TrayMenu.qml for why (short version: native
// menus don't work at all without QApplication mode, and tend to render
// transparent under Hyprland even when they do).
Item {
    id: root

    // Nothing to show on a session with no tray-registering apps running.
    visible: SystemTray.items.values.length > 0
    implicitWidth: visible ? row.implicitWidth : 0
    implicitHeight: visible ? row.implicitHeight : 0

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: SystemTray.items.values

            Item {
                id: trayIcon
                required property var modelData

                implicitWidth: 16
                implicitHeight: 16
                Layout.alignment: Qt.AlignVCenter

                IconImage {
                    id: icon
                    anchors.fill: parent
                    asynchronous: true
                    visible: status !== Image.Error
                    // SystemTray's `icon` is already a resolved `image://icon/...`
                    // URL (or empty if the item has none) - it must be used as-is,
                    // not re-run through Quickshell.iconPath(), which would treat
                    // that whole URL as a theme icon *name* and wrap it a second
                    // time into an unresolvable nested image://icon/image://icon/...
                    // URL.
                    source: trayIcon.modelData.icon || Quickshell.iconPath("image-missing")
                }

                // Shown when the icon name doesn't resolve in the icon theme
                // at all (fallback "image-missing" included) - happens with
                // some apps' SNI icon names, e.g. nm-applet's connection-
                // strength icons on themes that don't ship them.
                Text {
                    anchors.fill: parent
                    visible: icon.status === Image.Error
                    text: "\uf059"  // fa-question-circle
                    color: Theme.secondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        family: "Maple Mono NF CN"
                        pixelSize: 15
                        weight: 400
                    }
                }

                TrayMenu {
                    id: trayMenu
                    anchorItem: trayIcon
                    menu: trayIcon.modelData.menu
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            const item = trayIcon.modelData
                            const preferMenu = item.hasMenu
                                && (item.onlyMenu || item.category !== Category.ApplicationStatus)
                            if (preferMenu) {
                                trayMenu.open()
                            } else {
                                item.activate()
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayIcon.modelData.secondaryActivate()
                        } else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                            trayMenu.open()
                        }
                    }
                    onWheel: (wheel) => {
                        trayIcon.modelData.scroll(wheel.angleDelta.y, false)
                    }
                }
            }
        }
    }
}

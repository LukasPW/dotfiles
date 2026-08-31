pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import "../"

// Self-drawn replacement for QsMenuAnchor's native DBusMenu popup.
// QsMenuAnchor.open() renders via the Qt platform's native menu, which
// requires quickshell to run in QApplication mode (`//@ pragma
// UseQApplication` in shell.qml) - without it, open() just logs "quickshell
// was not started in QApplication mode" and shows nothing. Even with that
// pragma, native menus pull their palette from the platform theme (gtk3
// here, forced on in hyprland.lua so tray icons resolve), which tends to
// render translucent on Hyprland since GTK expects the compositor to draw a
// blurred backdrop behind it. Drawing the menu ourselves in a PopupWindow
// with an opaque color sidesteps both problems.
//
// Recursive: an entry with children reopens this same component anchored
// to itself, closeAll is threaded down so a leaf click anywhere in the
// chain collapses the whole tree, not just the innermost submenu.
PopupWindow {
    id: root

    property Item anchorItem
    property var menu
    property bool isRoot: true
    property var closeAll: function () { root.visible = false; }

    color: Theme.surfaceContainer
    visible: false
    grabFocus: root.isRoot

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.Left
        gravity: Edges.Bottom
    }

    implicitWidth: 240
    implicitHeight: column.implicitHeight + 12

    onVisibleChanged: if (!visible) submenuLoader.active = false

    function open() { root.visible = true; }
    function close() { root.visible = false; }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 6
        }
        spacing: 1

        Repeater {
            model: opener.children

            Item {
                id: entryRoot
                required property var modelData
                readonly property var entry: modelData

                width: column.width
                height: entry.isSeparator ? 9 : 26

                Rectangle {
                    visible: entryRoot.entry.isSeparator
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: 1
                    color: Theme.outline
                }

                Rectangle {
                    visible: !entryRoot.entry.isSeparator
                    anchors.fill: parent
                    radius: 6
                    color: Theme.primary
                    opacity: itemMouse.containsMouse && entryRoot.entry.enabled ? 0.18 : 0
                }

                RowLayout {
                    visible: !entryRoot.entry.isSeparator
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 6

                    Text {
                        Layout.preferredWidth: 14
                        text: {
                            const bt = entryRoot.entry.buttonType;
                            const checked = entryRoot.entry.checkState === Qt.Checked;
                            if (bt === QsMenuButtonType.CheckBox) return checked ? "" : "";
                            if (bt === QsMenuButtonType.RadioButton) return checked ? "" : "";
                            return "";
                        }
                        color: Theme.secondary
                        font { family: "Maple Mono NF CN"; pixelSize: 12 }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: entryRoot.entry.text
                        elide: Text.ElideRight
                        color: entryRoot.entry.enabled ? Theme.secondary : Theme.outline
                        font { family: "Maple Mono NF CN"; pixelSize: Theme.fontSizeSmall }
                    }

                    Text {
                        visible: entryRoot.entry.hasChildren
                        text: "" // fa-chevron-right
                        color: Theme.secondary
                        font { family: "Maple Mono NF CN"; pixelSize: 12 }
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !entryRoot.entry.isSeparator && entryRoot.entry.enabled
                    onClicked: {
                        if (entryRoot.entry.hasChildren) {
                            submenuLoader.pendingAnchorItem = entryRoot;
                            submenuLoader.pendingMenu = entryRoot.entry;
                            submenuLoader.active = true;
                        } else {
                            entryRoot.entry.triggered();
                            root.closeAll();
                        }
                    }
                }
            }
        }
    }

    // Loaded by URL rather than as an inline `TrayMenu { ... }` component -
    // Quickshell rejects a component that instantiates itself recursively
    // by type name ("TrayMenu is instantiated recursively"). Loading the
    // same file by path sidesteps that check, and since the item isn't
    // required, we can just set its properties after it loads instead of
    // passing them in as an inline declaration.
    Loader {
        id: submenuLoader
        active: false
        source: "TrayMenu.qml"

        property var pendingAnchorItem: null
        property var pendingMenu: null

        onLoaded: {
            item.anchorItem = submenuLoader.pendingAnchorItem;
            item.menu = submenuLoader.pendingMenu;
            item.isRoot = false;
            item.closeAll = root.closeAll;
            item.anchor.edges = Edges.Top | Edges.Right;
            item.anchor.gravity = Edges.Right;
            item.visible = true;
        }
    }
}

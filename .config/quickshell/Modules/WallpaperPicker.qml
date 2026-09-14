import ".."
import Quickshell
import QtQuick
import Quickshell.Io
import Qt.labs.folderlistmodel

PanelWindow {
    id: root
    property bool active: false
    visible: active
    focusable: active

    anchors.top: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitWidth: 880
    implicitHeight: 230
    margins.top: 40

    FolderListModel {
        id: wallpapers
        folder: "file:///home/aswdxtbyyn/Pictures/wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
    }

    // Themed backdrop card. This is what makes the picker visibly match
    // the rest of the shell - previously Theme was only used for a thin
    // 3px border, which is easy to miss entirely.
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainer
        border.width: 1
        border.color: Theme.outline
    }

    PathView {
        id: carousel
        anchors.fill: parent
        model: wallpapers
        focus: root.active
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange

        // Distance between each item's anchor point along the path.
        // Keep this a bit larger than the delegate's width (below) so
        // neighboring thumbnails don't overlap the centered one - but
        // not so much larger that there's a big visible gap.
        readonly property int itemSpacing: 70

        path: Path {
            startX: carousel.width / 2 - (carousel.itemSpacing * wallpapers.count) / 2
            startY: carousel.height / 2
            PathLine {
                x: carousel.width / 2 + (carousel.itemSpacing * wallpapers.count) / 2
                y: carousel.height / 2
            }
        }

        Keys.onLeftPressed: carousel.decrementCurrentIndex()
        Keys.onRightPressed: carousel.incrementCurrentIndex()
        Keys.onReturnPressed: runSelected()
        Keys.onEscapePressed: root.active = false

        delegate: Rectangle {
            required property string filePath
            width: 300
            height: 180
            color: "transparent"
            border.width: 3
            border.color: PathView.isCurrentItem ? Theme.primary : "transparent"
            scale: PathView.isCurrentItem ? 1.15 : 0.8
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                }
            }

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: "file://" + filePath
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 240
            }
        }

        function runSelected() {
            const item = carousel.currentItem;
            proc.command = ["bash", "-c", `awww img "${item.filePath}" && matugen image "${item.filePath}" --source-color-index 0 --mode dark && hyprctl reload`];
            proc.running = true;
            root.active = false;
        }

        Process {
            id: proc
        }
    }

    IpcHandler {
        target: "wallpicker"
        function toggle(): void {
            root.active = !root.active;
        }
        function open(): void {
            root.active = true;
        }
        function close(): void {
            root.active = false;
        }
    }
}

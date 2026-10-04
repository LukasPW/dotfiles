import ".."
import Quickshell
import QtQuick
import QtCore
import Quickshell.Io
import Qt.labs.folderlistmodel

PanelWindow {
    id: root
    property bool active: false
    visible: active
    focusable: active

    // Two-step flow: pick a wallpaper, then - if matugen finds more than
    // one candidate source color - pick which one drives the scheme.
    // If there's only one candidate (or the probe fails, e.g. an older
    // matugen without --show-source-colors), it falls straight through to
    // index 0, which is exactly the old behaviour.
    property bool pickingColor: false
    property bool probing: false
    property string pendingPath: ""
    property var sourceColors: []
    property int colorIndex: 0

    // matugen's --source-color-index is range-checked to 0-3.
    readonly property int maxSourceColors: 4

    readonly property int carouselHeight: 230
    readonly property int swatchBarHeight: 64

    anchors.top: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitWidth: 880
    implicitHeight: carouselHeight + (pickingColor ? swatchBarHeight : 0)
    margins.top: 40

    onActiveChanged: {
        if (!active)
            resetFlow();
    }

    function resetFlow() {
        pickingColor = false;
        probing = false;
        pendingPath = "";
        sourceColors = [];
        colorIndex = 0;
    }

    function backToWallpapers() {
        pickingColor = false;
        sourceColors = [];
        colorIndex = 0;
    }

    FolderListModel {
        id: wallpapers
        // StandardPaths asks Qt's platform integration for the user's
        // Pictures dir (reads $HOME / XDG user-dirs, not a fixed path), so
        // this is correct for any user on this machine and identical across
        // FHS-style distros and NixOS - Qt never assumes a /usr-style
        // filesystem layout here, just $HOME and the XDG dirs file.
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/wallpapers"
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
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.carouselHeight
        model: wallpapers
        focus: root.active
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange

        // PathView spreads pathItemCount items evenly over the whole path,
        // so the real gap between items is (path length / pathItemCount).
        // Sizing the path as itemSpacing * visibleCount makes that gap
        // exactly itemSpacing, no matter how many wallpapers are in the
        // folder. visibleCount is capped by the model count because
        // PathView can't fill more slots than it has items.
        readonly property int visibleCount: Math.max(1, Math.min(5, wallpapers.count))
        pathItemCount: visibleCount

        readonly property int delegateWidth: 300
        readonly property int delegateHeight: 180
        readonly property real currentScale: 1.15
        readonly property real otherScale: 0.8

        // Center-to-center distance: half the scaled-up current item plus
        // half a scaled-down neighbour plus a small gap, so they never
        // overlap.
        readonly property real itemSpacing: delegateWidth * currentScale / 2 + delegateWidth * otherScale / 2 + 24

        path: Path {
            startX: carousel.width / 2 - (carousel.itemSpacing * carousel.visibleCount) / 2
            startY: carousel.height / 2
            PathLine {
                x: carousel.width / 2 + (carousel.itemSpacing * carousel.visibleCount) / 2
                y: carousel.height / 2
            }
        }

        Keys.onLeftPressed: {
            if (root.pickingColor)
                root.colorIndex = Math.max(0, root.colorIndex - 1);
            else if (!root.probing)
                carousel.decrementCurrentIndex();
        }
        Keys.onRightPressed: {
            if (root.pickingColor)
                root.colorIndex = Math.min(root.sourceColors.length - 1, root.colorIndex + 1);
            else if (!root.probing)
                carousel.incrementCurrentIndex();
        }
        Keys.onReturnPressed: {
            if (root.pickingColor)
                root.applyWallpaper(root.pendingPath, root.colorIndex);
            else if (!root.probing)
                runSelected();
        }
        Keys.onEscapePressed: {
            if (root.pickingColor)
                root.backToWallpapers();
            else
                root.active = false;
        }
        // Number keys 1-4 jump straight to a swatch while picking a color.
        Keys.onPressed: event => {
            if (!root.pickingColor)
                return;
            const n = event.key - Qt.Key_1;
            if (n >= 0 && n < root.sourceColors.length) {
                root.colorIndex = n;
                event.accepted = true;
            }
        }

        delegate: Rectangle {
            required property string filePath
            width: carousel.delegateWidth
            height: carousel.delegateHeight
            color: "transparent"
            border.width: 3
            border.color: PathView.isCurrentItem ? Theme.primary : "transparent"
            scale: PathView.isCurrentItem ? carousel.currentScale : carousel.otherScale
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
                // Decode at the largest size it's ever drawn (current item,
                // scaled up) so the selected thumbnail isn't upscaled.
                sourceSize.width: Math.ceil(carousel.delegateWidth * carousel.currentScale)
            }
        }

        function runSelected() {
            const item = carousel.currentItem;
            if (!item)
                return;
            // Ask matugen which source colors it would extract, without
            // applying anything. Passed as a plain argv list, so no shell
            // is involved and the path needs no quoting at all.
            root.pendingPath = item.filePath;
            root.probing = true;
            probe.command = ["matugen", "image", item.filePath, "--show-source-colors"];
            probe.running = true;
        }
    }

    // Color step: one swatch per candidate, square to match the rest of
    // the shell. Left/Right or 1-4 to choose, Enter to apply, Esc to go
    // back to the wallpapers.
    Row {
        visible: root.pickingColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        spacing: 10

        Repeater {
            model: root.sourceColors
            delegate: Rectangle {
                required property string modelData
                required property int index
                readonly property bool selected: index === root.colorIndex
                width: 36
                height: 36
                color: "transparent"
                border.width: selected ? 3 : 1
                border.color: selected ? Theme.primary : Theme.outline

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    color: modelData
                }
            }
        }
    }

    function handleProbeOutput(text) {
        probing = false;
        // Picker was closed (Esc) while the probe was running.
        if (!active || pendingPath === "")
            return;

        // --show-source-colors prints one hex per line, most dominant first,
        // in the same order --source-color-index uses. Anything that isn't
        // a hex line (log output, errors) is ignored.
        const colors = (text || "").split("\n").map(l => l.trim()).filter(l => /^#[0-9a-fA-F]{6}$/.test(l)).slice(0, maxSourceColors);

        if (colors.length < 2) {
            applyWallpaper(pendingPath, 0);
            return;
        }
        sourceColors = colors;
        colorIndex = 0;
        pickingColor = true;
    }

    function applyWallpaper(path, index) {
        // awww sets the wallpaper, matugen regenerates the color scheme
        // from it - then the compositor needs to re-read its config to
        // pick up matugen's new colors. That reload step is the one
        // compositor-specific part of this chain, so it's the only bit
        // gated on Compositor.qml; on an unrecognised compositor it's
        // just skipped rather than guessed at.
        let reload = "";
        if (Compositor.isHyprland)
            reload = " && hyprctl reload";
        else if (Compositor.isNiri)
            reload = " && niri msg action load-config-file";

        // The path and index go in as positional arguments ($1, $2) rather
        // than being spliced into the script, so quotes, $ or backticks in
        // a filename can't break the command. "wallpicker" fills $0.
        proc.command = ["bash", "-c", 'awww img "$1" && matugen image "$1" --source-color-index "$2" --mode dark' + reload, "wallpicker", path, String(index)];
        proc.running = true;
        root.active = false;
    }

    Process {
        id: probe
        stdout: StdioCollector {
            onStreamFinished: root.handleProbeOutput(this.text)
        }
    }

    Process {
        id: proc
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

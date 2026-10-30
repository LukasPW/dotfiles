import ".."
import Quickshell
import QtQuick
import QtCore
import Quickshell.Io
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: root
    property bool active: false
    visible: active

    // Fullscreen overlay. Overlay layer so it also covers your bar.
    // The namespace lets you target it with compositor layer rules.
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpicker"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"

    // ---- colour-pick flow (unchanged behaviour) ----------------------------
    // Two-step flow: pick a wallpaper, then - if matugen finds more than
    // one candidate source color - pick which one drives the scheme.
    // If there's only one candidate (or the probe fails, e.g. an older
    // matugen without --show-source-colors), it falls straight through to
    // index 0.
    property bool pickingColor: false
    property bool probing: false
    property string pendingPath: ""
    property var sourceColors: []
    property int colorIndex: 0

    // matugen's --source-color-index is range-checked to 0-3.
    readonly property int maxSourceColors: 4

    // ---- live preview (off by default) -------------------------------------
    // When true, `awww img` runs (no transition) as you move through the
    // list, and the original wallpaper is restored on Esc. matugen still
    // only runs on Enter. Restore relies on parsing `awww query`; check its
    // output on your machine before enabling.
    property bool previewEnabled: false
    property string originalPath: ""
    property string previewPath: ""
    property bool applied: false

    // ---- look --------------------------------------------------------------
    // Swap for a font from your Theme if it has one.
    readonly property string labelFont: Theme.fontFamily
    // Selected wallpaper: a plain 16:9 rectangle.
    readonly property real selW: Math.min(width * 0.42, height * 0.55 * 16 / 9)
    readonly property real selH: selW * 9 / 16
    // Everything else: slanted cards.
    readonly property real cardW: selW * 0.26
    readonly property real cardH: selH * 0.86
    readonly property real skew: 0.22   // horizontal shear per unit of height
    readonly property real gap: 12      // horizontal gap between parallel edges
    readonly property int animMs: 140
    // How far neighbours get pushed away so the rectangle has room.
    readonly property real extra: (selW - cardW) / 2 + skew * cardH / 2

    onActiveChanged: {
        if (active) {
            carousel.forceActiveFocus();
            if (previewEnabled)
                queryProc.running = true;
        } else {
            restoreIfPreviewed();
            resetFlow();
        }
    }

    function resetFlow() {
        pickingColor = false;
        probing = false;
        pendingPath = "";
        sourceColors = [];
        colorIndex = 0;
        previewPath = "";
        originalPath = "";
        applied = false;
    }

    function backToWallpapers() {
        pickingColor = false;
        sourceColors = [];
        colorIndex = 0;
    }

    // Wraps around at both ends, like the old PathView did.
    function step(dir) {
        const n = wallpapers.count;
        if (n < 1)
            return;
        carousel.currentIndex = (carousel.currentIndex + dir + n) % n;
    }

    function runSelected() {
        const item = carousel.currentItem;
        if (!item)
            return;
        // Ask matugen which source colors it would extract, without
        // applying anything. Plain argv list: no shell, no quoting needed.
        pendingPath = item.filePath;
        probing = true;
        probe.command = ["matugen", "image", item.filePath, "--show-source-colors"];
        probe.running = true;
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
        applied = true;
        // awww sets the wallpaper, matugen regenerates the color scheme
        // from it - then the compositor may need to re-read its config to
        // pick up matugen's new colors. That reload step is the one
        // compositor-specific part of this chain. Add a branch for mango
        // here if your Compositor.qml has one.
        let reload = "";
        if (Compositor.isHyprland)
            reload = " && hyprctl reload";
        else if (Compositor.isNiri)
            reload = " && niri msg action load-config-file";

        // Path and index go in as positional arguments ($1, $2) rather
        // than being spliced into the script, so quotes, $ or backticks in
        // a filename can't break the command. "wallpicker" fills $0.
        proc.command = ["bash", "-c", 'awww img "$1" && matugen image "$1" --source-color-index "$2" --mode dark' + reload, "wallpicker", path, String(index)];
        proc.running = true;
    }

    // ---- live preview plumbing ---------------------------------------------
    function preview() {
        if (!previewEnabled || !active || pickingColor || probing || originalPath === "")
            return;
        const item = carousel.currentItem;
        if (!item || item.filePath === previewPath || previewProc.running)
            return; // if one is running, onExited calls us again to catch up
        previewPath = item.filePath;
        previewProc.command = ["awww", "img", "--transition-type", "none", item.filePath];
        previewProc.running = true;
    }

    function restoreIfPreviewed() {
        if (applied || previewPath === "" || originalPath === "")
            return;
        restoreProc.command = ["awww", "img", "--transition-type", "none", originalPath];
        restoreProc.running = true;
    }

    FolderListModel {
        id: wallpapers
        // StandardPaths asks Qt's platform integration for the user's
        // Pictures dir (reads $HOME / XDG user-dirs, not a fixed path).
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
    }

    // Scrim. Clicking empty space closes the picker. Declared first so the
    // cards' own MouseAreas sit above it.
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.surfaceContainer, 0.72)

        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }

    ListView {
        id: carousel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -root.height * 0.06
        height: root.selH + 40 // room for the hard shadow
        orientation: ListView.Horizontal
        interactive: false
        model: wallpapers
        focus: root.active

        // Keep the current item pinned to the middle of the screen. The
        // range is one slot wide, centred.
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - (root.cardW + root.gap) / 2
        preferredHighlightEnd: width / 2 + (root.cardW + root.gap) / 2
        highlightMoveDuration: root.animMs
        highlightMoveVelocity: -1

        onCurrentIndexChanged: {
            if (root.previewEnabled && root.active)
                previewTimer.restart();
        }

        Keys.onLeftPressed: {
            if (root.pickingColor)
                root.colorIndex = Math.max(0, root.colorIndex - 1);
            else if (!root.probing)
                root.step(-1);
        }
        Keys.onRightPressed: {
            if (root.pickingColor)
                root.colorIndex = Math.min(root.sourceColors.length - 1, root.colorIndex + 1);
            else if (!root.probing)
                root.step(1);
        }
        Keys.onReturnPressed: {
            if (root.pickingColor)
                root.applyWallpaper(root.pendingPath, root.colorIndex);
            else if (!root.probing)
                root.runSelected();
        }
        Keys.onEnterPressed: {
            if (root.pickingColor)
                root.applyWallpaper(root.pendingPath, root.colorIndex);
            else if (!root.probing)
                root.runSelected();
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

        WheelHandler {
            onWheel: event => {
                if (!root.pickingColor && !root.probing)
                    root.step(event.angleDelta.y > 0 ? -1 : 1);
            }
        }

        delegate: Item {
            id: slot
            required property int index
            required property string filePath
            required property string fileName
            required property url fileUrl

            readonly property bool isCur: ListView.isCurrentItem
            // 0 = slanted card, 1 = plain rectangle. Everything below
            // (size, shear, position) is derived from this one number.
            property real t: isCur ? 1 : 0
            // Neighbours sit slightly further out so the rectangle fits.
            property real dirOffset: isCur ? 0 : (index < carousel.currentIndex ? -root.extra : root.extra)

            width: root.cardW + root.gap
            height: carousel.height
            z: isCur ? 2 : 1

            Behavior on t {
                NumberAnimation {
                    duration: root.animMs
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on dirOffset {
                NumberAnimation {
                    duration: root.animMs
                    easing.type: Easing.OutQuad
                }
            }

            Item {
                id: card
                readonly property real shear: root.skew * (1 - slot.t)
                width: root.cardW + (root.selW - root.cardW) * slot.t
                height: root.cardH + (root.selH - root.cardH) * slot.t
                x: (slot.width - width) / 2 + slot.dirOffset
                y: (slot.height - height) / 2

                // Shear about the card's centre. Row-major: x' = x - shear*y + shear*h/2.
                transform: Matrix4x4 {
                    matrix: Qt.matrix4x4(1, -card.shear, 0, card.shear * card.height / 2, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                }

                // Hard offset shadow, selected card only. No blur.
                Rectangle {
                    x: 10
                    y: 10
                    width: parent.width
                    height: parent.height
                    color: Theme.outline
                    opacity: slot.t
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surfaceContainer

                    Image {
                        id: img
                        anchors.fill: parent
                        anchors.margins: 3
                        source: slot.fileUrl
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        // PreserveAspectCrop paints outside the item
                        // unless clipped - this is what let wallpapers
                        // spill over the border before.
                        clip: true
                        // Decode at the largest size it's ever drawn.
                        sourceSize.width: Math.ceil(root.selW)
                    }

                    // Flat dim on non-selected cards (no blur, no fade-in-out).
                    Rectangle {
                        anchors.fill: img
                        color: Qt.alpha(Theme.surfaceContainer, 0.55)
                        opacity: 1 - slot.t
                    }
                }

                // Border drawn last so nothing can paint over it.
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: slot.isCur ? 3 : 1
                    border.color: slot.isCur ? Theme.primary : Theme.outline
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.pickingColor || root.probing)
                            return;
                        if (slot.isCur)
                            root.runSelected();
                        else
                            carousel.currentIndex = slot.index;
                    }
                }
            }
        }
    }

    // Under the carousel: name plate, then (colour step only) the swatches.
    Column {
        anchors.top: carousel.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 18

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: nameText.width + 24
            height: nameText.implicitHeight + 10
            color: Theme.primary

            Text {
                id: nameText
                anchors.centerIn: parent
                width: Math.min(implicitWidth, root.selW - 24)
                elide: Text.ElideMiddle
                color: Theme.surfaceContainer
                font.family: root.labelFont
                font.pixelSize: 14
                font.letterSpacing: 1
                font.capitalization: Font.AllUppercase
                text: wallpapers.count < 1 ? "No wallpapers found" : (carousel.currentItem ? carousel.currentItem.fileName : "") + "  /  " + String(carousel.currentIndex + 1).padStart(2, "0") + "-" + String(wallpapers.count).padStart(2, "0")
            }
        }

        // Color step: one swatch per candidate, square to match the shell.
        Row {
            visible: root.pickingColor
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Repeater {
                model: root.sourceColors
                delegate: Rectangle {
                    required property string modelData
                    required property int index
                    readonly property bool selected: index === root.colorIndex
                    width: 44
                    height: 44
                    color: Theme.surfaceContainer
                    border.width: selected ? 3 : 1
                    border.color: selected ? Theme.primary : Theme.outline

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        color: modelData
                    }
                }
            }
        }
    }

    // Key hints.
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.primary
        font.family: root.labelFont
        font.pixelSize: 13
        font.letterSpacing: 1
        font.capitalization: Font.AllUppercase
        text: root.probing ? "Reading colours..." : root.pickingColor ? "← →  or  1-4  choose     enter  apply     esc  back" : "← →  select     enter  apply     esc  close"
    }

    Timer {
        id: previewTimer
        interval: 90
        onTriggered: root.preview()
    }

    Process {
        id: probe
        stdout: StdioCollector {
            onStreamFinished: root.handleProbeOutput(this.text)
        }
    }
    Process {
        id: proc
        onExited: (exitCode, exitStatus) => {
            console.log("wallpicker exited:", exitCode);
            root.active = false;
        }
    }
    Process {
        id: queryProc
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = /image: (.+)/.exec(this.text || "");
                root.originalPath = m ? m[1].trim() : "";
            }
        }
    }
    Process {
        id: previewProc
        onExited: root.preview()
    }
    Process {
        id: restoreProc
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

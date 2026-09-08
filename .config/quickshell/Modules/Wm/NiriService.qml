import QtQuick
import Quickshell
import Quickshell.Io

// niri workspace backend for Modules/Workspaces.qml.
//
// Unlike the Hyprland backend, niri has no fixed workspace count - the set
// is dynamic (niri always keeps one empty trailing workspace and drops
// empties above it), so this exposes the live list and the bar renders one
// entry per workspace rather than a fixed row.
//
// State is streamed from niri's JSON IPC on $NIRI_SOCKET: writing the bare
// request `"EventStream"` makes niri reply with an initial WorkspacesChanged
// (the full list) followed by incremental events. We track three:
//   - WorkspacesChanged           -> replace the whole list
//   - WorkspaceActivated          -> which workspace is active/focused
//   - WorkspaceActiveWindowChanged -> a workspace gained/lost its window
//
// Each niri workspace carries { id, idx, name, output, is_urgent,
// is_active, is_focused, active_window_id, ... }. `idx` is the per-output
// 1-based position (used as the switch reference and the fallback label);
// `id` is a stable global handle used only to correlate incremental events.
//
// Switching shells out to `niri msg` (same execDetached pattern as
// Modules/Network.qml) because the event-stream socket is read-only once
// the stream has started.
Item {
    id: root

    // Connector name of the monitor this bar is on ("eDP-1", ...), so we
    // only surface workspaces belonging to it. Empty = don't filter.
    property string outputName: ""

    // Live, sorted list for this output. Each entry:
    //   { idx, name, label, focused, urgent, populated }
    property var workspaces: []

    // Last known raw workspace list (array of niri's JSON objects).
    property var _workspaces: []

    onOutputNameChanged: root._rebuild()

    function activate(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    function _rebuild() {
        const all = root._workspaces || [];
        const rel = root.outputName ? all.filter(w => w.output === root.outputName) : all;
        const sorted = rel.slice().sort((a, b) => a.idx - b.idx);
        root.workspaces = sorted.map(w => ({
            idx: w.idx,
            name: w.name,
            label: (w.name && String(w.name).length) ? String(w.name) : String(w.idx),
            focused: !!w.is_focused,
            urgent: !!w.is_urgent,
            populated: w.active_window_id !== null && w.active_window_id !== undefined
        }));
    }

    Socket {
        id: sock
        path: Quickshell.env("NIRI_SOCKET") || ""
        connected: true

        parser: SplitParser {
            onRead: line => {
                let msg;
                try {
                    msg = JSON.parse(line);
                } catch (e) {
                    return;
                }

                if (msg.WorkspacesChanged) {
                    root._workspaces = msg.WorkspacesChanged.workspaces;
                    root._rebuild();
                } else if (msg.WorkspaceActivated) {
                    const ev = msg.WorkspaceActivated;
                    const target = (root._workspaces || []).find(w => w.id === ev.id);
                    root._workspaces = (root._workspaces || []).map(w => {
                        const nw = Object.assign({}, w);
                        if (nw.id === ev.id) {
                            nw.is_active = true;
                            if (ev.focused)
                                nw.is_focused = true;
                        } else {
                            if (ev.focused)
                                nw.is_focused = false;
                            if (target && nw.output === target.output)
                                nw.is_active = false;
                        }
                        return nw;
                    });
                    root._rebuild();
                } else if (msg.WorkspaceActiveWindowChanged) {
                    const ev = msg.WorkspaceActiveWindowChanged;
                    root._workspaces = (root._workspaces || []).map(w => {
                        if (w.id !== ev.workspace_id)
                            return w;
                        const nw = Object.assign({}, w);
                        nw.active_window_id = ev.active_window_id;
                        return nw;
                    });
                    root._rebuild();
                }
            }
        }

        onConnectionStateChanged: {
            if (connected) {
                write('"EventStream"\n');
                flush();
            } else {
                reconnect.restart();
            }
        }
        onError: err => reconnect.restart()
    }

    // niri restart / socket drop - retry the connection.
    Timer {
        id: reconnect
        interval: 2000
        repeat: false
        onTriggered: if (!sock.connected)
            sock.connected = true
    }
}

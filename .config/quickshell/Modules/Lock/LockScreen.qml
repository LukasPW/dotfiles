import Quickshell.Wayland
import QtQuick
import "../../"

// WlSessionLock is the actual Wayland session-lock protocol object - while
// `locked` is true, the compositor guarantees no input reaches anything
// but this surface (real lock, not just a fullscreen window on top).
// `surface` is a template: one LockSurface instance gets created per
// connected output automatically.
WlSessionLock {
    id: root

    surface: Component {
        LockSurface {
            onUnlockRequested: root.locked = false
        }
    }
}

import Quickshell
import QtQuick
import "../"

// Bar clock. Not to be confused with Modules/Lock/LockClock.qml, the
// larger clock shown on the lock screen - they're separate, unstyled-alike
// on purpose since the lock screen has more room to work with.
Text {
    color: Theme.secondary
    text: Qt.formatDateTime(clock.date, "ddd-MM/dd-HH:mm")
    font {
        family: "Maple Mono NF CN"
        letterSpacing: -1
        pixelSize: 15
        weight: 400
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}

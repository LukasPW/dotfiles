import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../"

ColumnLayout {
    id: root
    spacing: 4

    // Seconds precision here (vs. Minutes in the bar's Clock.qml) even
    // though seconds aren't displayed - SystemClock still needs to tick to
    // catch date rollover promptly since this is a big, staring-at-it
    // lock screen clock rather than a glanced-at bar clock.
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.primary
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeLarge * 2
            weight: 500
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
        color: Theme.secondary
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeLarge
            weight: 400
        }
    }
}

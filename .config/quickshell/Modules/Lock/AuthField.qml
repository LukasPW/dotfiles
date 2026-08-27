import Quickshell
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Layouts
import "../../"

ColumnLayout {
    id: root

    signal unlocked()

    property string buffer: ""
    // Caps the row of dots so a very long password doesn't visibly reveal
    // its length or overflow the field.
    readonly property int maxDots: 8

    spacing: 12

    function retry() {
        input.text = "";
        shake.restart();
        retryTimer.restart();
    }

    // Reuses swaylock's PAM service file (/etc/pam.d/swaylock) rather than
    // defining a new one, so this needs no separate PAM config on the
    // system - it authenticates exactly like swaylock would.
    PamContext {
        id: pam
        config: "swaylock"

        onCompleted: result => {
            if (result === PamResult.Success)
                root.unlocked();
            else
                root.retry();
        }

        onError: () => root.retry()
    }

    // PAM needs a moment to reset after a failed attempt before it'll
    // accept a new PamContext.start() - firing it immediately in onError
    // can throw, hence the short debounce instead of restarting inline.
    Timer {
        id: retryTimer
        interval: 400
        onTriggered: pam.start()
    }

    Component.onCompleted: pam.start()

    Rectangle {
        id: field
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 220
        implicitHeight: 48
        radius: Theme.radius
        color: Theme.surfaceContainer
        border.color: input.activeFocus ? Theme.primary : Theme.outline
        border.width: 1

        transform: Translate {
            id: shakeTransform
            x: 0
        }

        SequentialAnimation {
            id: shake
            loops: 1
            NumberAnimation { target: shakeTransform; property: "x"; to: -8; duration: 40 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 8; duration: 40 }
            NumberAnimation { target: shakeTransform; property: "x"; to: -6; duration: 40 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 6; duration: 40 }
            NumberAnimation { target: shakeTransform; property: "x"; to: 0; duration: 40 }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: Math.min(root.buffer.length, root.maxDots)
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.primary
                }
            }
        }

        TextInput {
            id: input
            anchors.fill: parent
            opacity: 0
            focus: true
            echoMode: TextInput.Password
            onTextChanged: root.buffer = text
            onAccepted: {
                if (pam.responseRequired)
                    pam.respond(text);
                text = "";
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: input.forceActiveFocus()
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: pam.message
        color: pam.messageIsError ? Theme.error : Theme.secondary
        font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeSmall
        }
    }
}

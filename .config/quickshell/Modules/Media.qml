import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../"

Text {
    id: root

    // Prefer a player that's actually playing; otherwise fall back to the first one.
    // .find() reads each player's isPlaying, so this binding re-evaluates when any of them change.
    readonly property MprisPlayer player:
        Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    visible: player !== null
    color: Theme.secondary
    font {
        family: "Maple Mono NF CN"
        pixelSize: 15
        weight: 400
    }
    text: player ? (player.isPlaying ? "\uf04b " : "\uf04c  ") + player.trackTitle : ""

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible = !popup.visible
    }

    // Small reusable button type, only visible inside this file.
    component ControlButton: Text {
        signal clicked()
        color: Theme.secondary
        opacity: enabled ? 1 : 0.4
        font {
            family: "Maple Mono NF CN"
            pixelSize: 20
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    PopupWindow {
        id: popup
        visible: false
        color: "transparent"
        implicitWidth: card.implicitWidth
        implicitHeight: card.implicitHeight

        // Position relative to the bar widget: centered under it, 8px below.
        anchor.item: root
        anchor.rect.x: root.width / 2 - popup.implicitWidth / 2
        anchor.rect.y: root.height + 8

        Rectangle {
            id: card
            implicitWidth: 240
            implicitHeight: content.implicitHeight + 32
            color: Theme.background

            Column {
                id: content
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 8

                Image {
                    width: parent.width
                    height: width
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    // Collapse the space entirely when there's no art.
                    visible: status === Image.Ready
                }

                Text {
                    width: parent.width
                    text: root.player?.trackTitle ?? ""
                    color: Theme.secondary
                    elide: Text.ElideRight
                    font {
                        family: "Maple Mono NF CN"
                        pixelSize: 14
                        bold: true
                    }
                }

                Text {
                    width: parent.width
                    text: root.player?.trackArtist ?? ""
                    color: Theme.tertiary
                    elide: Text.ElideRight
                    font {
                        family: "Maple Mono NF CN"
                        pixelSize: 13
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 28

                    ControlButton {
                        text: "\uf048"
                        enabled: root.player?.canGoPrevious ?? false
                        onClicked: root.player.previous()
                    }
                    ControlButton {
                        text: root.player?.isPlaying ? "\uf04c" : "\uf04b"
                        enabled: root.player?.canControl ?? false
                        onClicked: root.player.togglePlaying()
                    }
                    ControlButton {
                        text: "\uf051"
                        enabled: root.player?.canGoNext ?? false
                        onClicked: root.player.next()
                    }
                }
            }
        }
    }
}

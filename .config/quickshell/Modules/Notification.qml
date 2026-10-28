import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../"


Scope {
  id: root
  ListModel { id: history}
  property bool centerOpen: false
  NotificationServer {
    id: server
    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: n => {
      history.insert(0, {
      summary: n.summary,
      body: n.body,
      appName: n.appName,
      urgency: n.urgency,
      time: Qt.formatDateTime(new Date(), "HH:mm")
      })
      n.tracked = true
    }
  }

  IpcHandler {
    target: "notifications"
    function toggle(): void { root.centerOpen = !root.centerOpen }
    function show(): void { root.centerOpen = true }
    function hide(): void { root.centerOpen = false}
  }

  PanelWindow {
    visible: server.trackedNotifications.values.length > 0 // no graphics when no notifications
    anchors { top: true; right:true }
    margins { top: 14; right: 14 }
    
    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: Theme.background
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
      id: column
      width: parent.width
      spacing: 10

      Repeater {
        model: server.trackedNotifications
        delegate: Rectangle {
          id: card
          required property var modelData

          Timer{
            running: card.modelData.urgency !== NotificationUrgency.Critical
            interval: 5000
            onTriggered: card.modelData.dismiss()
          }
          
          Layout.fillWidth: true
          Layout.preferredHeight: layout.implicitHeight + 20
          radius: Theme.radius
          color: Theme.background
          border.width: 2
          border.color : modelData.urgency === NotificationUrgency.Critical ? Theme.error : Theme.primary
          
          RowLayout{
            id: layout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            Image {
              Layout.preferredHeight: 36
              Layout.preferredWidth: 36
              Layout.alignment: Qt.AlignTop
              fillMode: Image.PreserveAspectFit
              visible: source.toString() !== ""
              source: card.modelData.image || card.modelData.appIcon || ""
            } 
            
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 5 //Controlls the indentation of the text
              

              Text {
                Layout.fillWidth: true
                text: card.modelData.summary
                color: Theme.secondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                elide: Text.ElideRight
              }

              Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.modelData.body
                color: Theme.tertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
              }
            }
          }
          MouseArea{
           anchors.fill: parent
            onClicked: card.modelData.dismiss()
          }
        }
      }
    }
  }

  // Notification center
  PanelWindow {
    visible: root.centerOpen
    anchors { top: true; right:true }
    margins { top: 14; right: 14}

    implicitWidth: 380
    implicitHeight: centerCol.implicitHeight + 24
    color: Theme.background
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      radius: Theme.radius
      color: Theme.background
      border.width: 2
      border.color: Theme.primary

      ColumnLayout {
        id: centerCol
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        
        RowLayout {
          Layout.fillWidth: true
          
          Text{
            Layout.fillWidth: true
            text: "Notifications"
            color: Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
          }

          Text {
            text: "Clear All"
            visible: history.count > 0
            color: Theme.error
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            MouseArea{
            anchors.fill: parent
            onClicked: history.clear()
            }
          }
        }

        Repeater {
          model: history
          delegate: Rectangle {
            id: histCards
            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: cardCol.implicitHeight + 20
            radius: Theme.radius
            color: Theme.background
            border.width: 2
            border.color : modelData.urgency === NotificationUrgency.Critical ? Theme.error : Theme.primary
            
            ColumnLayout{
              id: cardCol
              anchors.fill: parent
              anchors.margins: 10
              spacing: 10
              
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 5 //Controlls the indentation of the text
                
                RowLayout {

                  Text {
                    Layout.fillWidth: true
                    text: histCards.modelData.summary
                    color: Theme.secondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    elide: Text.ElideRight
                  }

                  Text {
                    visible: model.appName !== ""
                    text: histCards.modelData.appName
                    color: Theme.secondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                  }

                  Text {
                    text: histCards.modelData.time
                    color: Theme.tertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                  }

                  Text {
                    text: "X"
                    color: Theme.error
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    MouseArea {
                      anchors.fill: parent
                      onPressed: console.log("X pressed, index =", index)
                      onClicked: history.remove(histCards.index)
                      Rectangle { anchors.fill: parent; color: "red"; opacity: 0.4 }
                    }
                  }
                }
                Text {
                  Layout.fillWidth: true
                  visible: text !== ""
                  text: histCards.modelData.body
                  color: Theme.tertiary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSizeSmall
                  wrapMode: Text.WordWrap
                }
              }
            }
          }
        }
      }
    }
  }
}

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.frankekn.lid"
  ipcTarget: "io.github.frankekn.lid"

  property bool awake: false

  function poll() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function setMode(on) {
    if (toggleProcess.running) return
    toggleProcess.command = ["omarchy-lid-stay-awake", on ? "on" : "off"]
    toggleProcess.running = true
  }

  Component.onCompleted: poll()

  Process {
    id: statusProcess
    running: false
    command: ["omarchy-lid-stay-awake", "status"]
    onExited: function(exitCode) {
      root.awake = exitCode === 0
    }
  }

  Process {
    id: toggleProcess
    running: false
    command: []
    onExited: repollTimer.restart()
  }

  Timer {
    id: repollTimer
    interval: 700
    repeat: false
    onTriggered: root.poll()
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.poll()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰌢"
    slotSize: Style.bar.statusSlot
    active: root.awake
    dimmed: !root.awake
    tooltipText: root.awake ? "Lid stay-awake: ON" : "Lid stay-awake: OFF"
    onPressed: function(b) {
      if (b === Qt.LeftButton) root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(400))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.setMode(!root.awake)
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: panelColumn
        width: parent.width
        spacing: Style.space(14)

        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            text: "󰌢"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "Lid Stay Awake"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: root.awake ? "ON" : "OFF"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }
        }

        Toggle {
          width: parent.width
          label: "Keep running on lid close"
          description: root.awake
            ? "Closing the lid turns the screen off; the system keeps running."
            : "Closing the lid locks the session and suspends."
          checked: root.awake
          foreground: root.bar.barForeground
          fontFamily: root.bar.fontFamily
          onClicked: root.setMode(!root.awake)
        }
      }
    }
  }
}

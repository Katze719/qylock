import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    property real unit: 1
    property color foreground: "#f4e8d4"
    property color accent: "#d8b77e"
    property bool primary: false
    property bool motionEnabled: true

    implicitWidth: contentItem.implicitWidth + 28 * unit
    implicitHeight: 38 * unit
    padding: 10 * unit
    activeFocusOnTab: true
    hoverEnabled: true
    opacity: enabled ? 1 : 0.45
    scale: !motionEnabled ? 1 : down ? 0.98 : hovered ? 1.015 : 1
    Behavior on scale {
        enabled: control.motionEnabled
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    font.pixelSize: 12 * unit
    font.letterSpacing: 0.5 * unit

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.primary ? "#241926" : (control.hovered ? control.accent : control.foreground)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 2 * control.unit
        color: control.primary
               ? (control.down ? "#b69260" : control.hovered ? "#e9cd9b" : control.accent)
               : (control.down ? "#503d2b43" : control.hovered ? "#703d2b43" : "#40201728")
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? control.foreground
                      : (control.primary ? "transparent" : "#60d8b77e")
        Behavior on color {
            enabled: control.motionEnabled
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}

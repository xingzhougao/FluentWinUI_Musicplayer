import QtQuick
import QtQuick.Window

Window{
    id: root
    width: 800
    height: 100

    visible: false
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8

        radius: 16
        color: mouseArea.containsMouse ? "#660E141D" : "transparent"
        Behavior on color {
            ColorAnimation{
                duration: 150
            }
        }

        Text {
            anchors.centerIn: parent
            width: parent.width-40
            text: player.currentLyric
            color: "#F5F7FB"
            font.pixelSize: 28
            font.bold: true
            style: Text.Outline
            styleColor: "#80000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onPressed: {
                root.startSystemMove()
            }
        }
    }
}

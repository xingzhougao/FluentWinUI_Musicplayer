import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle{
    id: root

    required property string numberText
    required property string title
    required property string artist
    required property string album
    required property string durationText

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"

    implicitHeight: 60
    radius: 14
    color: rowArea.containMouse ? "#141e2a" : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        Text {
            Layout.preferredWidth: 24
            text: root.numberText
            color: "#5e6c7e"
            font.pixelSize: 11
        }

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 11

            gradient: Gradient{
                GradientStop { position: 0.0; color: "#2d496c" }
                GradientStop { position: 1.0; color: "#684f7d" }
            }

            Text {
                anchors.centerIn: parent
                text: "♪"
                color: "white"
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 240
            spacing: 1

            Text {
                text: root.title
                color: root.textPrimaryColor
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Text {
                text: root.artist
                color: root.textSecondaryColor
                font.pixelSize: 10
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.album
            color: "#758295"
            font.pixelSize: 11
        }

        Text {
            text: root.durationText
            color: "#758295"
            font.pixelSize: 11
        }

        Button {
            id: rowMenu
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            background: null

            contentItem: Text{
                text: "•••"
                color: rowMenu.hovered ? "#d9e4f3" : "#718095"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id:  rowArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}

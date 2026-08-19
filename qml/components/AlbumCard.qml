import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string title: "Album"
    property string artist: "Artist"
    property string accent1: "#7d5cff"
    property string accent2: "#3a8cff"
    property string coverSource: ""

    implicitWidth: 220
    implicitHeight: 170

    radius: 22

    color: hovered ? "#18212d" : "#121923"
    border.color: hovered ? "#2f4055" : "#1e2936"
    border.width: 1

    property bool hovered: cardArea.containsMouse

    Behavior on color{
        ColorAnimation { duration: 140}
    }

    Behavior on scale{
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    scale: hovered ? 1.015 : 1.0

    Column{
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle{
            id: coverArea

            width: parent.width
            height: root.height - 75
            radius: 18
            clip: true

            //没有设置图片时 暂时继续显示原来的渐变色
            gradient: Gradient{
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;color: root.accent1}
                GradientStop { position: 1.0;color: root.accent2}
            }

            //真实主题图片
            Image {
                id: coverImage
                anchors.fill: parent
                source: root.coverSource
                fillMode: Image.PreserveAspectCrop      //保持原图比例填满 多出来的部分裁剪
                visible: root.coverSource !== ""
                smooth: true
            }

            //Hover时给图片轻轻加一层暗色
            Rectangle {
                anchors.fill: parent
                color: "#18000000"
                opacity: root.hovered ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }

            Rectangle {
                id: playBadge
                width: 46
                height: 46
                radius: 23
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 12
                color: "#f4f8ff"
                opacity: root.hovered ? 1.0 : 0.0
                scale: root.hovered? 1.0 : 0.8

                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 120 } }

                Text{
                    anchors.centerIn: parent
                    text: "▶"
                    color: "#111827"
                    font.pixelSize: 17
                }
            }
        }

        Text {
            width: parent.width
            text: root.title
            color: "#f4f7fb"
            font.pixelSize: 15
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text{
            width: parent.width
            text: root.artist
            color: "#8290a3"
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}

import QtQuick
import QtQuick.Controls

Button {
    id: root

    property url iconSource
    property bool selected: false

    implicitHeight: 46

    background: Rectangle{
        radius: 12
        color: root.selected ? "#1f2a3a" : ( root.hovered ? "#151c26" : "transparent" )
        Rectangle{                              //选中画一条小竖线
            visible: root.selected
            width: 3
            height: 22
            radius: 2
            color: "#6ea8ff"
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
        }

        Behavior on color {
            ColorAnimation { duration: 120}     //当控件color发生变化时 以120ms平滑过渡
        }
    }

    contentItem: Row{
        x: 14
        spacing: 12

        Image {
           width: 24
           height: 24

           source: root.iconSource
           sourceSize.width: 20
           sourceSize.height: 20
           fillMode: Image.PreserveAspectFit
           anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            color: root.selected ? "#f5f8fc" : "#bdc7d5"
            font.pixelSize: 14
            font.weight: root.selected ? Font.DemiBold : Font.Normal    //DemiBold 稍微粗一点的字体 Nomal 正常粗细
            anchors.verticalCenter: parent.verticalCenter
        }

    }
}

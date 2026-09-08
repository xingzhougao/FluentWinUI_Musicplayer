import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle{
    id: root
    implicitHeight: 74
    border.color: root.borderColor
    border.width: 1

    property color borderColor: "#1f2b3a"           //蓝黑
    property color textPrimaryColor: "#f5f7fb"      //灰白
    property color textSecondaryColor: "#8c99aa"    //蓝灰

    //歌词模式标记与返回信号
    property bool isLyricMode: false
    signal backRequested()

    //歌词模式下与歌词页背景无缝融合
    color: root.isLyricMode ? "#0c131e" : "#0e141d"

    RowLayout{
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        spacing: 18

        //歌词界面返回按钮
        Button {
            id: backButton
            visible: root.isLyricMode
            Layout.preferredWidth: 92
            Layout.preferredHeight: 38

            background: Rectangle {
                radius: 19
                color: backButton.hovered ? "#24354c" : "#162232"
                border.color: backButton.hovered ? "#415f8a" : "#263952"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            contentItem: RowLayout {
                spacing: 6
                anchors.centerIn: parent

                Text {
                    text: "˅"
                    color: root.textPrimaryColor
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "返回"
                    color: root.textPrimaryColor
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            ToolTip.visible: hovered
            ToolTip.text: "收起歌词并返回主界面"
            ToolTip.delay: 400

            onClicked: {
                root.backRequested()
            }
        }

        Rectangle{
            width: 38
            height: 38
            color:root.color
            Image{
                anchors.centerIn: parent
                source: "../icons/menu_bar.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                fillMode: Image.PreserveAspectFit
            }
        }

        Row{
            Layout.preferredWidth: 214
            spacing: 10

            Rectangle{
                width: 38
                height: 38
                radius: 12

                gradient: Gradient{     //默认从上到下的颜色
                    GradientStop { position: 0.0;color: "#7e69ff"}
                    GradientStop { position: 1.0;color: "#55b5ff"}
                }

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }
            }

            Column{
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text{
                    text: "Fluent Music"
                    color: root.textPrimaryColor
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Text{
                    text: "Your daily sound"
                    color: root.textSecondaryColor
                    font.pixelSize: 10
                }
            }
        }

        Item{
            Layout.fillWidth: true
        }

        Rectangle{
            visible: !root.isLyricMode
            Layout.preferredWidth: 460
            Layout.preferredHeight: 42
            radius: 19
            color: searchField.activeFocus ? "#182332" : "#141c27"      //蓝黑 深黑
            border.color: searchField.activeFocus ? "#486b9a" : "#243143" //蓝 蓝黑

            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 8

                Text{
                    text: "°"
                    color: "#91a0b4"
                    font.pixelSize: 20
                }

                TextField{
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "搜索歌曲、歌手、专辑"
                    placeholderTextColor: "#657286"
                    color: "#e7edf5"
                    font.pixelSize: 13
                    background: null
                    selectByMouse: true         //是否允许用户用鼠标来拖动选中文本
                }

                Rectangle{
                    width: 30
                    height: 24
                    radius: 8
                    color: "#202c3b"

                    Text{
                        anchors.centerIn: parent
                        text: "⌘K"
                        color: "#7f8ea2"
                        font.pixelSize: 10
                    }
                }
            }
        }

        Item{ Layout.fillWidth: true}
        Button{
            id: premiumButton
            text: "升级Premium"
            Layout.preferredHeight: 36
            Layout.preferredWidth: 116

            background: Rectangle{                  //自定义按钮背景
                radius: 18
                color: premiumButton.hovered ? "#263750" : "#1b293b"  //判断鼠标是否在按钮上悬停
                border.color: "#314968"
            }

            contentItem: Text{                      //自定义按钮文字
                text: premiumButton.text
                color: "#cfe0ff"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter  //水平对齐:水平居中对齐
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{
            width: 38
            height: 38
            radius: 19
            color: "#27364a"
            border.color: "#3a4d66"

            Text{
                anchors.centerIn: parent
                text: "G"
                color: "#ffffff"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }

        Button{
            id: settingButton
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38

            background: Rectangle{
                radius: 12
                color: settingButton.hovered ? "#1c2734" : "transparent"
            }

            contentItem: Image{
               source: "../icons/setting_button.svg"
               sourceSize.width: 18
               sourceSize.height: 18
               fillMode: Image.PreserveAspectFit        //保持长度适应宽比
            }
        }
    }
}

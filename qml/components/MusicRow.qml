import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string numberText: "01"
    property string title: "未知歌曲"
    property string artist: "未知歌手"
    property string album: ""
    property string durationText: "03:45"
    property bool favorite: false
    property bool isCurrent: false
    property bool isPlaying: false

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"

    signal playRequested()
    signal favoriteToggled()

    implicitHeight: 60
    radius: 14
    color: isCurrent ? "#18273d" : (rowArea.containsMouse ? "#141e2a" : "transparent")
    border.color: isCurrent ? "#243c5e" : (rowArea.containsMouse ? "#1c2b3d" : "transparent")
    border.width: 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        Text {
            Layout.preferredWidth: 26
            text: root.numberText
            color: root.isCurrent ? root.accentColor : "#5e6c7e"
            font.pixelSize: 12
            font.weight: root.isCurrent ? Font.Bold : Font.Medium
        }

        // 封面盒子
        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 11
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.isCurrent ? "#325c94" : (rowArea.containsMouse ? "#2f486d" : "#253b59") }
                GradientStop { position: 1.0; color: root.isCurrent ? "#684398" : (rowArea.containsMouse ? "#5f3d79" : "#4e3363") }
            }

            Text {
                anchors.centerIn: parent
                text: root.isPlaying ? "❚❚" : (rowArea.containsMouse ? "▶" : "♪")
                color: "white"
                font.pixelSize: root.isPlaying ? 11 : (rowArea.containsMouse ? 12 : 13)
                font.bold: true
            }
        }

        // 歌名 / 歌手 (自适应填充剩余空间)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.isCurrent ? root.accentColor : root.textPrimaryColor
                font.pixelSize: 13
                font.weight: root.isCurrent ? Font.Bold : Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.artist
                color: root.textSecondaryColor
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        // 红心喜欢按钮 (固定列对齐)
        Button {
            id: heartBtn
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            background: null

            contentItem: Item {
                Image {
                    anchors.centerIn: parent
                    source: root.favorite ? "../icons/like.svg" : "../icons/cancel_like_blue.svg"
                    sourceSize.width: 18
                    sourceSize.height: 18
                    fillMode: Image.PreserveAspectFit
                    opacity: root.favorite ? 1.0 : (heartBtn.hovered ? 1.0 : 0.65)
                    scale: heartBtn.pressed ? 0.85 : (heartBtn.hovered ? 1.15 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
            }

            onClicked: {
                root.favoriteToggled();
            }
        }

        // 专辑名称 (固定宽度列对齐)
        Text {
            Layout.preferredWidth: 220
            text: root.album.length > 0 ? root.album : (root.title + " (单曲)")
            color: "#758295"
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        // 时长 (固定宽度右对齐)
        Text {
            Layout.preferredWidth: 56
            horizontalAlignment: Text.AlignRight
            text: root.durationText
            color: root.isCurrent ? root.accentColor : "#758295"
            font.pixelSize: 12
            font.weight: root.isCurrent ? Font.Medium : Font.Normal
        }

        // 更多操作按钮 (固定列对齐)
        Button {
            id: rowMenu
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            background: null

            contentItem: Text {
                text: "•••"
                color: rowMenu.hovered ? "#d9e4f3" : "#718095"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: rowArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: -1

        onClicked: {
            root.playRequested();
        }
    }
}


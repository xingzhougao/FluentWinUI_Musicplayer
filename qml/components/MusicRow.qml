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
    property string coverUrl: ""
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
            id: coverBox
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 6
            clip: true
            color: "#162335"

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.isCurrent ? "#325c94" : (rowArea.containsMouse ? "#2f486d" : "#253b59") }
                GradientStop { position: 1.0; color: root.isCurrent ? "#684398" : (rowArea.containsMouse ? "#5f3d79" : "#4e3363") }
            }

            // 真实封面
            Image {
                id: rowCoverImg
                anchors.fill: parent
                source: root.coverUrl || ""
                visible: root.coverUrl !== "" && status === Image.Ready
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            // 无封面时：显示“暂无封面”
            Column {
                anchors.centerIn: parent
                spacing: 1
                visible: !rowCoverImg.visible && !rowArea.containsMouse && !root.isPlaying
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "♪"
                    color: root.isCurrent ? root.accentColor : "#5b6d82"
                    font.pixelSize: 11
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "暂无封面"
                    color: root.isCurrent ? root.accentColor : "#5b6d82"
                    font.pixelSize: 7
                }
            }

            // 悬浮或正在播放时的播放控制图标
            Rectangle {
                anchors.fill: parent
                color: rowCoverImg.visible ? "#80000000" : "transparent"
                visible: rowArea.containsMouse || root.isPlaying

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "❚❚" : "▶"
                    color: "white"
                    font.pixelSize: root.isPlaying ? 10 : 12
                }
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


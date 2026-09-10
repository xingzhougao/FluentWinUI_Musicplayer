import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var playerController: typeof player !== "undefined" ? player : null
    property var musicModel: typeof musicLibrary !== "undefined" ? musicLibrary : null

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"
    property color borderColor: "#1f2b3a"

    //1 背景层 暗色 WinUI 风格渐变
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f1724"}
            GradientStop { position: 0.4; color: "#0c131d"}
            GradientStop { position: 1.0; color: "#090e15"}
        }

        //右上角环境光晕装饰
        Rectangle {
            width: 460
            height: 460
            radius: 230
            x: parent.width - 280
            y: -200
            color: "#1d3a63"
            opacity: 0.20
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 24
        anchors.bottomMargin: 16
        spacing: 14

        //顶部信息与控制栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            ColumnLayout {
                spacing: 3

                RowLayout {
                    spacing: 10

                    Text {
                        text: "本地音乐"
                        color: root.textPrimaryColor
                        font.pixelSize: 26
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        radius: 10
                        color: "#18283d"
                        border.color: "#284468"
                        border.width: 1
                        Layout.preferredHeight: 22
                        Layout.preferredWidth: countText.implicitWidth + 16

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: (root.musicModel ? root.musicModel.count : 0) + " 首歌曲"
                            color: root.accentColor
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }

                Text {
                    text: "珍藏于此 随时聆听"
                    color: root.textSecondaryColor
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true}
            //播放全部按钮
            Button {
                id: playAllBtn
                Layout.preferredHeight: 36
                Layout.preferredWidth: 116

                background: Rectangle {
                    radius: 18
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: playAllBtn.hovered ? "#386ec0" : "#2858a0"}
                        GradientStop { position: 1.0; color: playAllBtn.hovered ? "#6a45a6" : "#533388"}
                    }
                    scale: playAllBtn.pressed ? 0.95 : (playAllBtn.hovered ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation {duration: 100 } }
                }

                contentItem: RowLayout {
                    spacing: 6
                    anchors.centerIn: parent
                    Text {
                        text: "▶"
                        color: "white"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "播放全部"
                        color: "white"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }

                onClicked: {
                    if(root.playerController && root.musicModel && root.musicModel.count > 0)
                    {
                        root.playerController.playFromModel(root.musicModel,0);
                    }
                }
            }

            //刷新歌单按钮
            Button {
                id: refreshBtn
                Layout.preferredHeight: 36
                Layout.preferredWidth: 108

                background: Rectangle {
                    radius: 18
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: refreshBtn.hovered ? "#386ec0" : "#2858a0"}
                        GradientStop { position: 1.0; color: refreshBtn.hovered ? "#6a45a6" : "#533388"}
                    }

                    scale:refreshBtn.pressed ? 0.95 : (refreshBtn.hovered ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation {duration: 100 } }
                }

                contentItem: RowLayout {
                    spacing: 6
                    anchors.centerIn: parent
                    Text {
                        text: "⟳"
                        color: "white"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "刷新歌单"
                        color: "white"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }

                onClicked: {
                    if (root.musicModel) {
                        var dir = (typeof appConfig !== "undefined" && appConfig.localMusicDir) ? appConfig.localMusicDir : "";
                        if (dir !== "") {
                            root.musicModel.scanDirectory(dir);
                        }
                    }
                }
            }
        }

        //表头 参考QQ音乐布局
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    Layout.preferredWidth: 46
                    text: "序号"
                    color: "#6b7c91"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    Layout.fillWidth: true
                    text: "歌名 / 歌手"
                    color: "#6b7c91"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Item {
                    Layout.preferredWidth: 36
                }

                Text {
                    Layout.preferredWidth: 220
                    text: "专辑"
                    color: "#6b7c91"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    Layout.preferredWidth: 70
                    horizontalAlignment: Text.AlignRight
                    text: "时长"
                    color: "#6b7c91"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#182638"
            }
        }

        //歌曲列表
        ListView {
            id: songListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.musicModel

            ScrollBar.vertical: ScrollBar {
                id: vBar
                policy: ScrollBar.AsNeeded
                width: 8
                active: songListView.moving || hovered

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Rectangle {
                    radius: 4
                    color: vBar.pressed ? "#4b6c96" : (vBar.hovered ? "#364e6d" : "#223145")
                    opacity: vBar.active ? 0.9 : 0.35
                    Behavior on opacity { NumberAnimation {duration: 150 } }
                }
            }

            delegate: Rectangle {
                id: rowRect
                width: songListView.width
                height: 56
                radius: 8

                readonly property bool isCurrent: root.playerController && root.playerController.currentLibrary === root.musicModel && root.playerController.currentIndex === index
                readonly property bool isPlaying: isCurrent && root.playerController.playing

                color: isCurrent ? "#162438" : (rowMouse.containsMouse ? "#111a26" : "transparent")
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    // 封面缩略图与序号
                    Item {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 40

                        Rectangle {
                            id: coverBox
                            width: 38
                            height: 38
                            radius: 7
                            anchors.centerIn: parent
                            clip: true

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: isCurrent ? "#2a4b7c" : (rowMouse.containsMouse ? "#1f385c" : "#17263b") }
                                GradientStop { position: 1.0; color: isCurrent ? "#55387a" : (rowMouse.containsMouse ? "#392454" : "#271a39") }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !rowMouse.containsMouse && !isPlaying
                                text: (index + 1 < 10 ? "0" : "") + (index + 1)
                                color: isCurrent ? root.accentColor : "#5b6d82"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: rowMouse.containsMouse || isPlaying
                                text: isPlaying ? "❚❚" : "▶"
                                color: "white"
                                font.pixelSize: isPlaying ? 10 : 12
                            }
                        }
                    }

                    // 歌名 / 歌手
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: model.title || "未知歌曲"
                            color: isCurrent ? root.accentColor : root.textPrimaryColor
                            font.pixelSize: 13
                            font.weight: isCurrent ? Font.Bold : Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: model.artist || "未知歌手"
                            color: root.textSecondaryColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    // 是否点赞的红心图标
                    Button {
                        id: heartBtn
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        background: null

                        contentItem: Item {
                            Image {
                                anchors.centerIn: parent
                                source: model.favorite ? "../icons/like.svg" : "../icons/cancel_like_blue.svg"
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                                opacity: model.favorite ? 1.0 : (heartBtn.hovered ? 1.0 : 0.85)
                                scale: heartBtn.pressed ? 0.85 : (heartBtn.hovered ? 1.15 : 1.0)
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                            }
                        }

                        onClicked: {
                            if (root.musicModel) {
                                root.musicModel.toggleFavorite(index);
                            }
                        }
                    }

                    // 专辑
                    Text {
                        Layout.preferredWidth: 220
                        text: model.album || (model.title + " (单曲)")
                        color: "#728398"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    // 时长
                    Text {
                        Layout.preferredWidth: 70
                        horizontalAlignment: Text.AlignRight
                        text: root.playerController ? root.playerController.formatTime(model.duration) : "03:45"
                        color: isCurrent ? root.accentColor : "#728398"
                        font.pixelSize: 12
                        font.weight: isCurrent ? Font.Medium : Font.Normal
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1

                    onClicked: {
                        if (root.playerController)
                            root.playerController.playFromModel(root.musicModel,index);
                    }
                }
            }
        }
    }
}

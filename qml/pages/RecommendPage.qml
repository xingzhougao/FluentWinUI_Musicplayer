import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var playerController: typeof player !== "undefined" ? player : null
    property var recommendModel: typeof recommendLibrary !== "undefined" ? recommendLibrary : null

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"
    property color borderColor: "#1f2b3a"

    //背景层 暗色WinUI风格渐变
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f1724" }
            GradientStop { position: 0.4; color: "#0c131d" }
            GradientStop { position: 1.0; color: "#090e15" }
        }

        //右上角环境光晕装饰
        Rectangle {
            width: 480
            height: 480
            radius: 240
            x: parent.width - 260
            y: -190
            color: "#283b68"
            opacity: 0.22
        }

        //左下角紫粉色环境光晕装饰
        Rectangle {
            width: 380
            height: 380
            radius: 190
            x: -120
            y: parent.height - 240
            color: "#4a2468"
            opacity: 0.15
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 20
        anchors.bottomMargin: 16
        spacing: 14

        //顶部Banner图片与文案占位卡片
        Rectangle {
            id: bannerCard
            Layout.fillWidth: true
            Layout.preferredHeight: 175
            radius: 16
            clip: true
            color: "#121b29"
            border.color: "#22354c"
            border.width: 1

            //背景图片
            Image {
                id: bannerImg
                anchors.fill: parent
                source: "../image_resource/banner.png"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.38
            }

            //渐变
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#f00c1422"}
                    GradientStop { position: 0.55; color: "#c8141f32"}
                    GradientStop { position: 1.0; color: "#90281b40"}
                }
            }

            //装饰性光斑
            Rectangle {
                width: 240
                height: 240
                radius: 120
                x: parent.width - 180
                y: -60
                color: "#6c4299"
                opacity: 0.28
            }

            //Banner 内容
            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    //小标签
                    Rectangle {
                        Layout.preferredWidth: badgeText.implicitWidth + 16
                        Layout.preferredHeight: 22
                        radius: 11
                        color: "#304f8cff"
                        border.color: "#506ea8ff"
                        border.width: 1

                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: "DAILT RECOMMEND . 每日推荐"
                            color: "#b0d0ff"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.0
                        }
                    }

                    //主标题
                    Text {
                        text: "为您精挑细选的42首歌曲"
                        color: "white"
                        font.pixelSize: 26
                        font.weight: Font.Bold
                    }

                    //副标题
                    Text {
                        text: "心动旋律 . 每次打开焕然一新"
                        color: "#9db0c8"
                        font.pixelSize: 12
                    }

                    Item {
                        Layout.preferredHeight: 4
                    }

                    RowLayout {
                        spacing: 12

                        Button {
                            id: playAllBtn
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 120

                            background: Rectangle {
                                radius: 18
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position:0.0; color: playAllBtn.hovered? "#386ec0" : "#2858a0"}
                                    GradientStop { position:1.0; color: playAllBtn.hovered? "#6a45a6" : "#533388"}
                                }
                                scale: playAllBtn.pressed ? 0.95 : (playAllBtn.hovered ? 1.02 : 1.0)
                                Behavior on scale { NumberAnimation { duration: 100 } }
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
                                if(root.playerController && root.recommendModel && root.recommednModel.count > 0)
                                {
                                    root.playerController.playFromModel(root.recommendModel,0);
                                }
                            }
                        }

                        Rectangle {
                            radius: 14
                            color: "#182436"
                            border.color: "#283b54"
                            border.width: 1
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: songCountText.implicitWidth + 18

                            Text {
                                id: songCountText
                                anchors.centerIn: parent
                                text: (root.recommendModel ? root.recommendModel.count : 42) + "首精选歌曲"
                                color: root.accentColor
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }

        //表头
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
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
            model: root.recommendModel

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

                readonly property bool isCurrent: root.playerController && root.playerController.currentLibrary === root.recommendModel && root.playerController.currentIndex === index
                readonly property bool isPlaying: isCurrent && root.playerController.playing
                color: isCurrent ? "#162438" : (rowMouse.containsMouse ? "#111a26" : "transparent")
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    //封面缩略图与序号
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
                                GradientStop { position: 0.0; color: isCurrent ? "#2a4b7c" : (rowMouse.containsMouse ? "#1f385c" : "#17263b" ) }
                                GradientStop { position: 1.0; color: isCurrent ? "#55387a" : (rowMouse.containsMouse ? "#392454" : "#271a39" ) }
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

                    //歌手 歌名
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: model.title || "未知歌曲"
                            color: isCurrent ? root.accentColor: root.textPrimaryColor
                            font.pixelSize: 13
                            font.weight: isCurrent ? Font.Bold: Font.DemiBold
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

                    //是否点赞的红心图标
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
                            if(root.recommendModel)
                            {
                                root.recommendModel.toggleFavorite(index);
                            }
                        }
                    }

                    //专辑
                    Text {
                        Layout.preferredWidth: 220
                        text: model.album || (model.title + " (单曲)")
                        color: "#728398"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    //时长
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
                        if(root.playerController && root.recommendModel)
                            root.playerController.playFromModel(root.recommendModel,index);
                    }
                }
            }
        }
    }
}

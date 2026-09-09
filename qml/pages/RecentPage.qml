import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var playerController: typeof player !== "undefined" ? player : null
    property var recentModel: typeof recentLibrary !== "undefined" ? recentLibrary : null
    property var recentMgr: typeof recentManager !== "undefined" ? recentManager : null

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"
    property color borderColor: "#1f2b3a"

    // 1. 背景层 暗色 WinUI 风格渐变
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f1724" }
            GradientStop { position: 0.4; color: "#0c131d" }
            GradientStop { position: 1.0; color: "#090e15" }
        }

        // 右上角环境光晕装饰
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

        // 顶部信息与控制栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            ColumnLayout {
                spacing: 3

                RowLayout {
                    spacing: 10

                    Text {
                        text: "最近播放"
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
                            text: (root.recentModel ? root.recentModel.count : 0) + " 首歌曲"
                            color: root.accentColor
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }

                Text {
                    text: "记录您的音乐足迹 最多保留100首"
                    color: root.textSecondaryColor
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            // 播放全部按钮
            Button {
                id: playAllBtn
                Layout.preferredHeight: 36
                Layout.preferredWidth: 116
                visible: root.recentModel && root.recentModel.count > 0

                background: Rectangle {
                    radius: 18
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: playAllBtn.hovered ? "#386ec0" : "#2858a0" }
                        GradientStop { position: 1.0; color: playAllBtn.hovered ? "#6a45a6" : "#533388" }
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
                    if (root.playerController && root.recentModel && root.recentModel.count > 0) {
                        root.playerController.playFromModel(root.recentModel, 0);
                    }
                }
            }

            // 清空记录按钮
            Button {
                id: clearBtn
                Layout.preferredHeight: 36
                Layout.preferredWidth: 108
                visible: root.recentModel && root.recentModel.count > 0

                background: Rectangle {
                    radius: 18
                    color: clearBtn.hovered ? "#321d28" : "#1e1722"
                    border.color: clearBtn.hovered ? "#592b3c" : "#382330"
                    border.width: 1

                    scale: clearBtn.pressed ? 0.95 : (clearBtn.hovered ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                contentItem: RowLayout {
                    spacing: 6
                    anchors.centerIn: parent
                    Text {
                        text: "🗑"
                        color: "#ff7082"
                        font.pixelSize: 13
                    }
                    Text {
                        text: "清空历史"
                        color: "#ff8c9c"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }

                onClicked: {
                    if (root.recentMgr) {
                        root.recentMgr.clearHistory();
                    }
                }
            }
        }

        // 表头
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

        // 空状态提示
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.recentModel || root.recentModel.count === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 14

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 72
                    height: 72
                    radius: 36
                    color: "#131d2b"
                    border.color: "#1e2e42"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "♫"
                        color: root.accentColor
                        font.pixelSize: 30
                        opacity: 0.6
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "暂无最近播放记录，快去听听歌吧！"
                    color: root.textSecondaryColor
                    font.pixelSize: 14
                }
            }
        }

        // 歌曲列表
        ListView {
            id: songListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.recentModel
            visible: root.recentModel && root.recentModel.count > 0

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
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }

            delegate: Rectangle {
                id: rowRect
                width: songListView.width
                height: 48
                radius: 6

                readonly property bool isCurrent: root.playerController &&
                                                 root.playerController.currentLibrary === root.recentModel &&
                                                 root.playerController.currentIndex === index
                readonly property bool isPlaying: isCurrent && root.playerController.playing

                color: {
                    if (isCurrent) return "#1e3352";
                    if (rowMouseArea.containsMouse) return "#162334";
                    return index % 2 === 0 ? "transparent" : "#080d14";
                }

                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    // 序号或正在播放指示
                    Item {
                        Layout.preferredWidth: 46
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            visible: !rowRect.isCurrent
                            text: (index + 1) < 10 ? "0" + (index + 1) : (index + 1)
                            color: "#4d6075"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        // 正在播放动效音波柱
                        Row {
                            anchors.centerIn: parent
                            spacing: 2
                            visible: rowRect.isCurrent

                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 3
                                    height: rowRect.isPlaying ? (index === 1 ? 14 : 9) : 4
                                    radius: 1.5
                                    color: root.accentColor
                                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                    Behavior on height { NumberAnimation { duration: 200 } }
                                }
                            }
                        }
                    }

                    // 歌名和歌手
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: model.title || "未知曲目"
                            color: rowRect.isCurrent ? root.accentColor : root.textPrimaryColor
                            font.pixelSize: 13
                            font.weight: rowRect.isCurrent ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.artist || "未知歌手"
                            color: rowRect.isCurrent ? Qt.lighter(root.accentColor, 1.2) : root.textSecondaryColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // 喜欢心形按钮
                    Rectangle {
                        id: heartBox
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 14
                        color: heartMouse.containsMouse ? "#203045" : "transparent"

                        Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: model.favorite ? "../icons/like.svg" : "../icons/cancel_like_blue.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        MouseArea {
                            id: heartMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.recentModel) {
                                    root.recentModel.toggleFavorite(index);
                                }
                            }
                        }
                    }

                    // 专辑名
                    Text {
                        Layout.preferredWidth: 220
                        text: model.album || "未知专辑"
                        color: "#6b7c91"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    // 歌曲时长
                    Text {
                        Layout.preferredWidth: 70
                        horizontalAlignment: Text.AlignRight
                        text: root.playerController ? root.playerController.formatTime(model.duration) : "03:45"
                        color: rowRect.isCurrent ? root.accentColor : "#4d6075"
                        font.pixelSize: 12
                    }
                }

                // 整行点击触发播放
                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1

                    onClicked: {
                        if (root.playerController && root.recentModel) {
                            root.playerController.playFromModel(root.recentModel, index);
                        }
                    }
                }
            }
        }
    }
}

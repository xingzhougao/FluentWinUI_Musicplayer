import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var playerController
    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"

    signal backRequested()

    // 标记用户当前是否正在手动滚动浏览歌词
    property bool userScrolling: false

    // 1. 沉浸式暗色渐变背景与微光晕
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0c131e" }
            GradientStop { position: 0.45; color: "#111b2b" }
            GradientStop { position: 0.85; color: "#151829" }
            GradientStop { position: 1.0; color: "#0d131f" }
        }

        // 左侧环境光晕（根据封面主色烘托）
        Rectangle {
            width: 520
            height: 520
            radius: 260
            x: 60
            y: root.height * 0.2
            color: "#1d3a63"
            opacity: 0.18
        }

        // 右上角环境光晕
        Rectangle {
            width: 480
            height: 480
            radius: 240
            x: root.width - 320
            y: -100
            color: "#301d4a"
            opacity: 0.15
        }
    }

    // 2. 顶部左侧返回收起按钮 (⌵)
    Button {
        id: backBtn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
        width: 36
        height: 36
        z: 10

        background: Rectangle {
            radius: 18
            color: backBtn.hovered ? "#22334a" : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        contentItem: Text {
            text: "⌵"
            color: backBtn.hovered ? "#ffffff" : "#8c9fb5"
            font.pixelSize: 22
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
        }

        onClicked: {
            root.backRequested()
        }

        ToolTip.visible: backBtn.hovered
        ToolTip.text: "收起歌词界面"
        ToolTip.delay: 300
    }

    // 3. 主内容区域：左右 50% / 50% 经典分栏
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        anchors.topMargin: 50
        anchors.bottomMargin: 20
        spacing: 30

        // ================= 左半部分：大号专辑封面 / 暂无封面 =================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            implicitWidth: 340
            implicitHeight: 340

            // 封面主体卡片
            Rectangle {
                id: coverCard
                width: Math.min(340, Math.max(220, Math.floor(root.height * 0.45)))
                height: width
                anchors.centerIn: parent
                radius: 14
                clip: true
                color: "#162335"
                border.color: "#22354e"
                border.width: 1

                // 外层环境阴影与柔光
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 16
                    height: parent.height + 16
                    radius: 18
                    color: "#162842"
                    opacity: 0.35
                    z: -1
                }

                    // 真实封面图
                    Image {
                        id: mainCoverImage
                        anchors.fill: parent
                        source: (root.playerController && root.playerController.coverUrl) ? root.playerController.coverUrl : ""
                        visible: source !== "" && status === Image.Ready
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    // 无封面时的设计（黑胶光盘质感卡片 + "本歌曲暂无封面"）
                    Rectangle {
                        anchors.fill: parent
                        visible: !mainCoverImage.visible
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#1b293d" }
                            GradientStop { position: 0.5; color: "#141e2d" }
                            GradientStop { position: 1.0; color: "#0e1520" }
                        }

                        // 黑胶同心环纹理
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.76
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.color: "#243750"
                            border.width: 1
                            opacity: 0.6
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.52
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.color: "#283e5a"
                            border.width: 1
                            opacity: 0.5
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            // 音乐图标
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 64
                                height: 64
                                radius: 32
                                color: "#1b2b40"
                                border.color: "#2d4464"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "♪"
                                    color: root.accentColor
                                    font.pixelSize: 28
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "本歌曲暂无封面"
                                color: "#8a9eb8"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }

        // ================= 右半部分：歌曲信息 + 滚动歌词 =================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            spacing: 12

            // 顶部歌曲信息（歌名、VIP标识、歌手与专辑）
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: (root.playerController && root.playerController.title !== "") ? root.playerController.title : "未选择歌曲"
                    color: root.textPrimaryColor
                    font.pixelSize: 26
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: {
                        var artist = (root.playerController && root.playerController.artist !== "") ? root.playerController.artist : "未知歌手";
                        var album = (root.playerController && root.playerController.album !== "") ? root.playerController.album : "";
                        return album !== "" ? (artist + "  -  " + album) : artist;
                    }
                    color: root.textSecondaryColor
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // 歌词滚动区域
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 暂无歌词状态提示
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: !root.playerController.lyricList || root.playerController.lyricList.length === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.playerController.currentLyric === "暂无歌词" ? "暂无歌词" : "纯音乐，请欣赏"
                        color: root.textSecondaryColor
                        font.pixelSize: 18
                    }
                }

                // 歌词滚动列表
                ListView {
                    id: lyricListView
                    anchors.fill: parent
                    clip: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.playerController.lyricList

                    // 上下空白缓冲，使当前行能平滑滚动至正中间
                    header: Item {
                        width: lyricListView.width
                        height: lyricListView.height * 0.42
                    }

                    footer: Item {
                        width: lyricListView.width
                        height: lyricListView.height * 0.42
                    }

                    // 垂直滚动条
                    ScrollBar.vertical: ScrollBar {
                        id: vbar
                        policy: ScrollBar.AsNeeded
                        active: lyricListView.moving || lyricListView.flicking
                        contentItem: Rectangle {
                            implicitWidth: 5
                            radius: 2.5
                            color: vbar.pressed ? "#6ea8ff" : (vbar.hovered ? "#4a6890" : "#243750")
                        }
                    }

                    // 捕获用户手动滚动
                    onMovementStarted: {
                        root.userScrolling = true
                        userScrollTimer.stop()
                    }

                    onMovementEnded: {
                        userScrollTimer.restart()
                    }

                    onFlickStarted: {
                        root.userScrolling = true
                        userScrollTimer.stop()
                    }

                    onFlickEnded: {
                        userScrollTimer.restart()
                    }

                    delegate: Item {
                        id: lyricDelegate
                        required property int index
                        required property var modelData

                        width: lyricListView.width
                        height: lyricText.implicitHeight + 24

                        readonly property bool isCurrent: index === root.playerController.currentLyricIndex
                        readonly property bool isHovered: delegateMouseArea.containsMouse

                        Text {
                            id: lyricText
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.min(parent.width - 20, 520)
                            text: lyricDelegate.modelData.text
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.Wrap
                            font.pixelSize: lyricDelegate.isCurrent ? 22 : 15
                            font.weight: lyricDelegate.isCurrent ? Font.Bold : (lyricDelegate.isHovered ? Font.Medium : Font.Normal)
                            color: lyricDelegate.isCurrent ? "#ffffff" : (lyricDelegate.isHovered ? "#dce7f5" : "#6c7d91")
                            opacity: lyricDelegate.isCurrent ? 1.0 : (lyricDelegate.isHovered ? 0.9 : 0.6)

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 180 }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 180 }
                            }
                        }

                        MouseArea {
                            id: delegateMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.userScrolling = false
                                userScrollTimer.stop()
                                root.playerController.seekToLyric(lyricDelegate.index)
                                lyricListView.positionViewAtIndex(lyricDelegate.index, ListView.Center)
                            }
                        }
                    }
                }
            }
        }
    }

    // 用户手动滚动后的自动居中恢复定时器
    Timer {
        id: userScrollTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.userScrolling = false
            root.centerCurrentLyric()
        }
    }

    // 居中当前歌词函数
    function centerCurrentLyric() {
        if (lyricListView.count > 0 && root.playerController.currentLyricIndex >= 0 && root.playerController.currentLyricIndex < lyricListView.count) {
            lyricListView.positionViewAtIndex(root.playerController.currentLyricIndex, ListView.Center)
        }
    }

    // 监听播放器当前歌词索引变化
    Connections {
        target: root.playerController
        function onCurrentLyricIndexChanged() {
            if (!root.userScrolling && lyricListView.count > 0) {
                root.centerCurrentLyric()
            }
        }
        function onLyricListChanged() {
            root.userScrolling = false
            userScrollTimer.stop()
            if (lyricListView.count > 0) {
                lyricListView.positionViewAtBeginning()
            }
        }
    }

    // 页面显示时自动居中
    onVisibleChanged: {
        if (visible) {
            root.userScrolling = false
            userScrollTimer.stop()
            Qt.callLater(function() {
                root.centerCurrentLyric()
            })
        }
    }
}

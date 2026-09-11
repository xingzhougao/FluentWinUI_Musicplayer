import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: root

    property var playerController: typeof player !== "undefined" ? player : null
    property var localLibrary: typeof musicLibrary !== "undefined" ? musicLibrary : null
    property var playlistMgr: typeof playlistManager !== "undefined" ? playlistManager : null

    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"
    property color borderColor: "#1f2b3a"

    // 当前选中的歌单 ID，为空字符串时展示歌单列表，不为空时展示该歌单详情
    property string currentPlaylistId: ""
    property string currentPlaylistName: ""
    property string currentPlaylistCover: ""
    property var currentPlaylistModel: null

    // 监听歌单管理器变化刷新
    Connections {
        target: root.playlistMgr
        function onPlaylistsChanged() {
            playlistsRepeater.model = root.playlistMgr ? root.playlistMgr.playlists : []
            if (root.currentPlaylistId !== "" && root.playlistMgr) {
                root.currentPlaylistName = root.playlistMgr.getPlaylistName(root.currentPlaylistId)
                root.currentPlaylistCover = root.playlistMgr.getPlaylistCover(root.currentPlaylistId)
                root.currentPlaylistModel = root.playlistMgr.getPlaylistModel(root.currentPlaylistId)
            }
        }
    }

    // 安全删除歌单：处理正在播放与正在浏览的状态，避免崩溃并确保删除成功
    function safeDeletePlaylist(id) {
        if (!root.playlistMgr)
            return;
        try {
            var targetModel = root.playlistMgr.getPlaylistModel(id);
            // 如果播放器当前正在播放被删除的歌单，安全停止播放并切回本地音乐库以避免悬空播放
            if (root.playerController && targetModel && root.playerController.currentLibrary === targetModel) {
                root.playerController.stop();
                if (root.localLibrary) {
                    root.playerController.setLibrary(root.localLibrary);
                } else {
                    root.playerController.setLibrary(null);
                }
            }
            if (root.currentPlaylistId === id) {
                root.currentPlaylistId = "";
                root.currentPlaylistModel = null;
            }
        } catch (e) {
            console.error("safeDeletePlaylist error:", e);
        }
        root.playlistMgr.deletePlaylist(id);
    }

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
            width: 480
            height: 480
            radius: 240
            x: parent.width - 260
            y: -180
            color: "#283b68"
            opacity: 0.20
        }

        // 左下角微光装饰
        Rectangle {
            width: 380
            height: 380
            radius: 190
            x: -120
            y: parent.height - 240
            color: "#4a2468"
            opacity: 0.14
        }
    }

    // ==========================================
    // 视图 1：歌单总览页面 (currentPlaylistId === "")
    // ==========================================
    Item {
        id: overviewView
        anchors.fill: parent
        visible: root.currentPlaylistId === ""

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 24
            anchors.bottomMargin: 16
            spacing: 16

            // 顶部操作栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    spacing: 3

                    RowLayout {
                        spacing: 10

                        Text {
                            text: "我的歌单"
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
                            Layout.preferredWidth: playlistCountText.implicitWidth + 16

                            Text {
                                id: playlistCountText
                                anchors.centerIn: parent
                                text: (root.playlistMgr ? root.playlistMgr.playlistCount : 0) + " 个歌单"
                                color: root.accentColor
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Text {
                        text: "珍藏心动旋律 · 定制你的专属音乐世界"
                        color: root.textSecondaryColor
                        font.pixelSize: 12
                    }
                }

                Item { Layout.fillWidth: true }

                // + 新建歌单按钮
                Button {
                    id: createBtn
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: 116

                    background: Rectangle {
                        radius: 18
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: createBtn.hovered ? "#386ec0" : "#2858a0" }
                            GradientStop { position: 1.0; color: createBtn.hovered ? "#6a45a6" : "#533388" }
                        }
                        scale: createBtn.pressed ? 0.95 : (createBtn.hovered ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }

                    contentItem: RowLayout {
                        spacing: 6
                        anchors.centerIn: parent
                        Text {
                            text: "+"
                            color: "white"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "新建歌单"
                            color: "white"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }

                    onClicked: {
                        createDialog.openDialog()
                    }
                }
            }

            // 分割线
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#182638"
            }

            // 内容区域：无歌单时显示空提示，有歌单时展示网格卡片
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 空状态提示：严格按照用户要求提示
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: !root.playlistMgr || root.playlistMgr.playlistCount === 0

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 96
                        height: 96
                        radius: 48
                        color: "#142032"
                        border.color: "#22354c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "♫"
                            color: root.accentColor
                            font.pixelSize: 42
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "您目前没有歌单哦 请添加一个吧。"
                        color: root.textPrimaryColor
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "创建属于你的个性化歌单，随心收录喜爱的音乐"
                        color: root.textSecondaryColor
                        font.pixelSize: 12
                    }

                    Item { Layout.preferredHeight: 6 }

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 136

                        background: Rectangle {
                            radius: 19
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#386ec0" }
                                GradientStop { position: 1.0; color: "#6a45a6" }
                            }
                        }

                        contentItem: Text {
                            text: "+ 立即创建歌单"
                            color: "white"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            createDialog.openDialog()
                        }
                    }
                }

                // 歌单卡片流式滚动排列
                ScrollView {
                    anchors.fill: parent
                    clip: true
                    visible: root.playlistMgr && root.playlistMgr.playlistCount > 0
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Flow {
                        id: playlistFlow
                        width: parent.width
                        spacing: 20
                        padding: 4

                        Repeater {
                            id: playlistsRepeater
                            model: root.playlistMgr ? root.playlistMgr.playlists : []

                            delegate: Rectangle {
                                id: cardRoot
                                width: 220
                                height: 216
                                radius: 18
                                color: cardMouse.containsMouse ? "#182332" : "#121923"
                                border.color: cardMouse.containsMouse ? "#2a3d54" : "#1e2936"
                                border.width: 1

                                scale: cardMouse.containsMouse ? 1.015 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    // 封面图片区
                                    Rectangle {
                                        id: coverBox
                                        width: parent.width
                                        height: 136
                                        radius: 14
                                        clip: true
                                        color: "#182435"

                                        // 默认渐变背景
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "#2d446a" }
                                            GradientStop { position: 1.0; color: "#503075" }
                                        }

                                        // 用户自定义封面图
                                        Image {
                                            anchors.fill: parent
                                            source: modelData.coverUrl || ""
                                            fillMode: Image.PreserveAspectCrop
                                            visible: modelData.coverUrl && modelData.coverUrl !== ""
                                            smooth: true
                                        }

                                        // 没有封面时的音符图案
                                        Text {
                                            anchors.centerIn: parent
                                            visible: !modelData.coverUrl || modelData.coverUrl === ""
                                            text: "♫"
                                            color: "#ffffff"
                                            opacity: 0.35
                                            font.pixelSize: 48
                                        }

                                        // 悬浮时显示的半透明遮罩
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "#1a000000"
                                            opacity: cardMouse.containsMouse ? 1.0 : 0.0
                                            Behavior on opacity { NumberAnimation { duration: 100 } }
                                        }

                                        // 浮标播放全部按钮
                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: 20
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 10
                                            color: "#ffffff"
                                            opacity: cardMouse.containsMouse ? 1.0 : 0.0
                                            scale: cardMouse.containsMouse ? 1.0 : 0.8
                                            Behavior on opacity { NumberAnimation { duration: 120 } }
                                            Behavior on scale { NumberAnimation { duration: 120 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "▶"
                                                color: "#111827"
                                                font.pixelSize: 14
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var model = root.playlistMgr.getPlaylistModel(modelData.id)
                                                    if (root.playerController && model && model.count > 0) {
                                                        root.playerController.playFromModel(model, 0)
                                                    }
                                                }
                                            }
                                        }

                                        // 快捷删除歌单按钮 (使用 playlist_delete.svg)
                                        Item {
                                            id: deleteCardBadge
                                            width: 30
                                            height: 30
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.margins: 8
                                            z: 10

                                            opacity: deleteCardBtn.containsMouse ? 1.0 : (cardMouse.containsMouse ? 0.95 : 0.0)
                                            scale: deleteCardBtn.containsMouse ? 1.12 : (cardMouse.containsMouse ? 1.0 : 0.85)
                                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                            Behavior on opacity { NumberAnimation { duration: 120 } }

                                            Image {
                                                anchors.fill: parent
                                                source: "../icons/playlist_delete.svg"
                                                sourceSize.width: 30
                                                sourceSize.height: 30
                                                smooth: true
                                                mipmap: true
                                            }

                                            MouseArea {
                                                id: deleteCardBtn
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                preventStealing: true
                                                onClicked: function(mouse) {
                                                    mouse.accepted = true;
                                                    root.safeDeletePlaylist(modelData.id);
                                                }
                                            }

                                            ToolTip.visible: deleteCardBtn.containsMouse
                                            ToolTip.text: "删除此歌单"
                                            ToolTip.delay: 200
                                        }
                                    }

                                    // 歌单标题
                                    Text {
                                        width: parent.width
                                        text: modelData.name || "未命名歌单"
                                        color: "#f4f7fb"
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    // 歌曲数量
                                    Text {
                                        width: parent.width
                                        text: (modelData.count || 0) + " 首歌曲"
                                        color: "#8290a3"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: cardMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    z: -1

                                    onClicked: {
                                        root.currentPlaylistId = modelData.id
                                        root.currentPlaylistName = modelData.name
                                        root.currentPlaylistCover = modelData.coverUrl
                                        root.currentPlaylistModel = root.playlistMgr.getPlaylistModel(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 视图 2：歌单详情页面 (currentPlaylistId !== "")
    // ==========================================
    Item {
        id: detailView
        anchors.fill: parent
        visible: root.currentPlaylistId !== ""

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            spacing: 12

            // 顶部返回栏
            Button {
                id: backBtn
                Layout.preferredHeight: 32
                Layout.preferredWidth: 120

                background: Rectangle {
                    radius: 16
                    color: backBtn.hovered ? "#203046" : "#141e2b"
                    border.color: "#22354c"
                    border.width: 1
                }

                contentItem: RowLayout {
                    spacing: 6
                    anchors.centerIn: parent
                    Text {
                        text: "←"
                        color: root.accentColor
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }
                    Text {
                        text: "返回歌单列表"
                        color: root.textPrimaryColor
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                }

                onClicked: {
                    root.currentPlaylistId = ""
                    root.currentPlaylistModel = null
                }
            }

            // 歌单详情 Banner 卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                radius: 16
                color: "#121b29"
                border.color: "#22354c"
                border.width: 1
                clip: true

                // 背景光晕
                Rectangle {
                    width: 260
                    height: 260
                    radius: 130
                    x: parent.width - 200
                    y: -80
                    color: "#4a2468"
                    opacity: 0.22
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // 歌单大封面图
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 120
                        radius: 12
                        clip: true
                        color: "#182435"

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#2d446a" }
                            GradientStop { position: 1.0; color: "#503075" }
                        }

                        Image {
                            anchors.fill: parent
                            source: root.currentPlaylistCover || ""
                            fillMode: Image.PreserveAspectCrop
                            visible: root.currentPlaylistCover && root.currentPlaylistCover !== ""
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !root.currentPlaylistCover || root.currentPlaylistCover === ""
                            text: "♫"
                            color: "#ffffff"
                            opacity: 0.35
                            font.pixelSize: 42
                        }
                    }

                    // 歌单信息与操作按钮
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 8

                        // 标签
                        Rectangle {
                            Layout.preferredWidth: playlistTagText.implicitWidth + 14
                            Layout.preferredHeight: 20
                            radius: 10
                            color: "#304f8cff"
                            border.color: "#506ea8ff"
                            border.width: 1

                            Text {
                                id: playlistTagText
                                anchors.centerIn: parent
                                text: "PLAYLIST · 歌单"
                                color: "#b0d0ff"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }

                        // 歌单大标题
                        Text {
                            text: root.currentPlaylistName || "歌单详情"
                            color: "white"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        // 歌曲数量
                        Text {
                            text: "共 " + (root.currentPlaylistModel ? root.currentPlaylistModel.count : 0) + " 首歌曲"
                            color: "#9db0c8"
                            font.pixelSize: 12
                        }

                        Item { Layout.preferredHeight: 2 }

                        // 操作按钮行：播放全部、添加歌曲、删除歌单
                        RowLayout {
                            spacing: 10

                            // 播放全部
                            Button {
                                id: playDetailBtn
                                Layout.preferredHeight: 34
                                Layout.preferredWidth: 110

                                background: Rectangle {
                                    radius: 17
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: playDetailBtn.hovered ? "#386ec0" : "#2858a0" }
                                        GradientStop { position: 1.0; color: playDetailBtn.hovered ? "#6a45a6" : "#533388" }
                                    }
                                }

                                contentItem: RowLayout {
                                    spacing: 6
                                    anchors.centerIn: parent
                                    Text { text: "▶"; color: "white"; font.pixelSize: 11 }
                                    Text { text: "播放全部"; color: "white"; font.pixelSize: 12; font.weight: Font.DemiBold }
                                }

                                onClicked: {
                                    if (root.playerController && root.currentPlaylistModel && root.currentPlaylistModel.count > 0) {
                                        root.playerController.playFromModel(root.currentPlaylistModel, 0)
                                    }
                                }
                            }

                            // 添加歌曲按钮
                            Button {
                                id: addSongsBtn
                                Layout.preferredHeight: 34
                                Layout.preferredWidth: 110

                                background: Rectangle {
                                    radius: 17
                                    color: addSongsBtn.hovered ? "#22354c" : "#182638"
                                    border.color: "#304d70"
                                    border.width: 1
                                }

                                contentItem: RowLayout {
                                    spacing: 6
                                    anchors.centerIn: parent
                                    Text { text: "+"; color: root.accentColor; font.pixelSize: 14; font.weight: Font.Bold }
                                    Text { text: "添加歌曲"; color: root.textPrimaryColor; font.pixelSize: 12; font.weight: Font.Medium }
                                }

                                onClicked: {
                                    addSongDialog.openDialog()
                                }
                            }
                        }
                    }
                }
            }

            // 表头
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text { Layout.preferredWidth: 46; text: "封面"; color: "#6b7c91"; font.pixelSize: 12; font.weight: Font.Medium }
                    Text { Layout.fillWidth: true; text: "歌名 / 歌手"; color: "#6b7c91"; font.pixelSize: 12; font.weight: Font.Medium }
                    Item { Layout.preferredWidth: 36 }
                    Text { Layout.preferredWidth: 200; text: "专辑"; color: "#6b7c91"; font.pixelSize: 12; font.weight: Font.Medium }
                    Text { Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight; text: "时长"; color: "#6b7c91"; font.pixelSize: 12; font.weight: Font.Medium }
                    Text { Layout.preferredWidth: 108; horizontalAlignment: Text.AlignHCenter; text: "操作"; color: "#6b7c91"; font.pixelSize: 12; font.weight: Font.Medium }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#182638"
                }
            }

            // 歌曲列表区域
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 歌单内无歌曲时的提示
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: !root.currentPlaylistModel || root.currentPlaylistModel.count === 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "歌单内暂无歌曲，点击「+ 添加歌曲」从本地音乐挑选吧！"
                        color: root.textSecondaryColor
                        font.pixelSize: 14
                    }

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 110

                        background: Rectangle {
                            radius: 16
                            color: "#1d2e44"
                            border.color: "#304d70"
                        }

                        contentItem: Text {
                            text: "+ 添加歌曲"
                            color: root.accentColor
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            addSongDialog.openDialog()
                        }
                    }
                }

                // 歌曲 ListView
                ListView {
                    id: detailSongListView
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.currentPlaylistModel
                    visible: root.currentPlaylistModel && root.currentPlaylistModel.count > 0

                    ScrollBar.vertical: ScrollBar {
                        id: detailVBar
                        policy: ScrollBar.AsNeeded
                        width: 8
                        active: detailSongListView.moving || hovered

                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle {
                            radius: 4
                            color: detailVBar.pressed ? "#4b6c96" : (detailVBar.hovered ? "#364e6d" : "#223145")
                            opacity: detailVBar.active ? 0.9 : 0.35
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    delegate: Rectangle {
                        id: songRowRect
                        width: detailSongListView.width
                        height: 56
                        radius: 8

                        readonly property bool isCurrent: root.playerController && root.playerController.currentLibrary === root.currentPlaylistModel && root.playerController.currentIndex === index
                        readonly property bool isPlaying: isCurrent && root.playerController.playing

                        color: isCurrent ? "#162438" : (songRowMouse.containsMouse ? "#111a26" : "transparent")
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12

                            // 封面缩略图
                            Item {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 44

                                Rectangle {
                                    id: coverBox
                                    width: 42
                                    height: 42
                                    radius: 6
                                    anchors.centerIn: parent
                                    clip: true
                                    color: "#162335"

                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: isCurrent ? "#2a4b7c" : (songRowMouse.containsMouse ? "#1f385c" : "#17263b") }
                                        GradientStop { position: 1.0; color: isCurrent ? "#55387a" : (songRowMouse.containsMouse ? "#392454" : "#271a39") }
                                    }

                                    // 真实封面
                                    Image {
                                        id: rowCoverImg
                                        anchors.fill: parent
                                        source: (typeof model.coverUrl !== "undefined" && model.coverUrl) ? model.coverUrl : ""
                                        visible: source !== "" && status === Image.Ready
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                    }

                                    // 无封面时：显示“暂无封面”
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 1
                                        visible: !rowCoverImg.visible && !songRowMouse.containsMouse && !isPlaying
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "♪"
                                            color: isCurrent ? root.accentColor : "#5b6d82"
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "暂无封面"
                                            color: isCurrent ? root.accentColor : "#5b6d82"
                                            font.pixelSize: 7
                                        }
                                    }

                                    // 悬浮或正在播放时的播放控制图标
                                    Rectangle {
                                        anchors.fill: parent
                                        color: rowCoverImg.visible ? "#80000000" : "transparent"
                                        visible: songRowMouse.containsMouse || isPlaying

                                        Text {
                                            anchors.centerIn: parent
                                            text: isPlaying ? "❚❚" : "▶"
                                            color: "white"
                                            font.pixelSize: isPlaying ? 10 : 12
                                        }
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

                            // 爱心
                            Button {
                                id: heartDetailBtn
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
                                        opacity: model.favorite ? 1.0 : (heartDetailBtn.hovered ? 1.0 : 0.85)
                                        scale: heartDetailBtn.pressed ? 0.85 : (heartDetailBtn.hovered ? 1.15 : 1.0)
                                        Behavior on scale { NumberAnimation { duration: 100 } }
                                        Behavior on opacity { NumberAnimation { duration: 100 } }
                                    }
                                }

                                onClicked: {
                                    if (root.currentPlaylistModel) {
                                        root.currentPlaylistModel.toggleFavorite(index)
                                    }
                                }
                            }

                            // 专辑
                            Text {
                                Layout.preferredWidth: 200
                                text: model.album || (model.title + " (单曲)")
                                color: "#728398"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            // 时长
                            Text {
                                Layout.preferredWidth: 60
                                horizontalAlignment: Text.AlignRight
                                text: root.playerController ? root.playerController.formatTime(model.duration) : "03:45"
                                color: isCurrent ? root.accentColor : "#728398"
                                font.pixelSize: 12
                            }

                            // 歌曲操作区：上移、下移、删除
                            RowLayout {
                                Layout.preferredWidth: 108
                                Layout.preferredHeight: 32
                                spacing: 4

                                // 上移按钮
                                Button {
                                    id: moveUpBtn
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 28
                                    enabled: index > 0
                                    opacity: enabled ? 1.0 : 0.25

                                    background: Rectangle {
                                        radius: 6
                                        color: moveUpBtn.hovered && moveUpBtn.enabled ? "#22354c" : "transparent"
                                    }

                                    contentItem: Text {
                                        text: "▲"
                                        color: moveUpBtn.hovered && moveUpBtn.enabled ? root.accentColor : "#8fa3bf"
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    ToolTip.visible: hovered
                                    ToolTip.text: "上移一位"
                                    ToolTip.delay: 300

                                    onClicked: {
                                        if (index > 0) {
                                            root.playlistMgr.moveTrackInPlaylist(root.currentPlaylistId, index, index - 1)
                                        }
                                    }
                                }

                                // 下移按钮
                                Button {
                                    id: moveDownBtn
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 28
                                    enabled: root.currentPlaylistModel ? (index < root.currentPlaylistModel.count - 1) : false
                                    opacity: enabled ? 1.0 : 0.25

                                    background: Rectangle {
                                        radius: 6
                                        color: moveDownBtn.hovered && moveDownBtn.enabled ? "#22354c" : "transparent"
                                    }

                                    contentItem: Text {
                                        text: "▼"
                                        color: moveDownBtn.hovered && moveDownBtn.enabled ? root.accentColor : "#8fa3bf"
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    ToolTip.visible: hovered
                                    ToolTip.text: "下移一位"
                                    ToolTip.delay: 300

                                    onClicked: {
                                        if (root.currentPlaylistModel && index < root.currentPlaylistModel.count - 1) {
                                            root.playlistMgr.moveTrackInPlaylist(root.currentPlaylistId, index, index + 1)
                                        }
                                    }
                                }

                                // 从歌单删除歌曲按钮 (直接在页面内操作删除)
                                Button {
                                    id: removeSongBtn
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 28
                                    background: Rectangle {
                                        radius: 6
                                        color: removeSongBtn.hovered ? "#35151e" : "transparent"
                                    }

                                    contentItem: Text {
                                        text: "✕"
                                        color: removeSongBtn.hovered ? "#ff6e7f" : "#6b7c91"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    ToolTip.visible: hovered
                                    ToolTip.text: "从歌单移除"
                                    ToolTip.delay: 300

                                    onClicked: {
                                        root.playlistMgr.removeTrackFromPlaylist(root.currentPlaylistId, index)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: songRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1

                            onClicked: {
                                if (root.playerController && root.currentPlaylistModel) {
                                    root.playerController.playFromModel(root.currentPlaylistModel, index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 弹窗 1：新建歌单弹窗
    // ==========================================
    Rectangle {
        id: createDialog
        anchors.fill: parent
        color: "#90000000"
        visible: false
        z: 100

        property string selectedCover: ""

        function openDialog() {
            nameInput.text = ""
            selectedCover = ""
            visible = true
            nameInput.forceActiveFocus()
        }

        function closeDialog() {
            visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {} // 拦截穿透
        }

        Rectangle {
            anchors.centerIn: parent
            width: 420
            height: 360
            radius: 16
            color: "#131c28"
            border.color: "#283e58"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Text {
                    text: "新建歌单"
                    color: root.textPrimaryColor
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                // 封面选择区
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 120
                    height: 120
                    radius: 14
                    clip: true
                    color: "#1a2738"
                    border.color: "#2f4560"
                    border.width: 1

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#2d446a" }
                        GradientStop { position: 1.0; color: "#503075" }
                    }

                    Image {
                        anchors.fill: parent
                        source: createDialog.selectedCover || ""
                        fillMode: Image.PreserveAspectCrop
                        visible: createDialog.selectedCover !== ""
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: createDialog.selectedCover === ""
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "+"
                            color: root.accentColor
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "选择封面图片\n(可选)"
                            color: "#9db0c8"
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            fileDialog.open()
                        }
                    }
                }

                // 名称输入框
                TextField {
                    id: nameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: "请输入歌单名称..."
                    placeholderTextColor: "#6b7c91"
                    color: "white"
                    font.pixelSize: 13
                    verticalAlignment: TextInput.AlignVCenter

                    background: Rectangle {
                        radius: 8
                        color: "#182536"
                        border.color: nameInput.activeFocus ? root.accentColor : "#25374c"
                        border.width: 1
                    }
                }

                Item { Layout.fillHeight: true }

                // 按钮行
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: "取消"

                        background: Rectangle {
                            radius: 8
                            color: "#1e2c3e"
                            border.color: "#2c4058"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: "取消"
                            color: root.textSecondaryColor
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: createDialog.closeDialog()
                    }

                    Button {
                        id: confirmCreateBtn
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38

                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#386ec0" }
                                GradientStop { position: 1.0; color: "#6a45a6" }
                            }
                        }

                        contentItem: Text {
                            text: "确认创建"
                            color: "white"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var plName = nameInput.text.trim()
                            if (plName === "")
                                plName = "我的歌单"
                            root.playlistMgr.createPlaylist(plName, createDialog.selectedCover)
                            createDialog.closeDialog()
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 弹窗 2：从本地音乐添加歌曲弹窗
    // ==========================================
    Rectangle {
        id: addSongDialog
        anchors.fill: parent
        color: "#90000000"
        visible: false
        z: 100

        function openDialog() {
            visible = true
        }

        function closeDialog() {
            visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {} // 拦截穿透
        }

        Rectangle {
            anchors.centerIn: parent
            width: 580
            height: 480
            radius: 16
            color: "#131c28"
            border.color: "#283e58"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "从本地音乐添加歌曲"
                        color: root.textPrimaryColor
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "点击添加加入当前歌单"
                        color: root.textSecondaryColor
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#1f2e42"
                }

                // 本地歌曲列表
                ListView {
                    id: localSongList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.localLibrary

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 6
                    }

                    delegate: Rectangle {
                        width: localSongList.width
                        height: 48
                        radius: 6
                        color: addRowMouse.containsMouse ? "#192638" : "transparent"

                        readonly property bool alreadyAdded: root.playlistMgr ? root.playlistMgr.playlistContainsTrack(root.currentPlaylistId, model.filePath) : false

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Text {
                                text: (index + 1 < 10 ? "0" : "") + (index + 1)
                                color: "#5b6d82"
                                font.pixelSize: 11
                                Layout.preferredWidth: 26
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: model.title || "未知歌曲"
                                    color: root.textPrimaryColor
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
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

                            // 添加状态按钮
                            Button {
                                id: addItemBtn
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 28
                                enabled: !alreadyAdded

                                background: Rectangle {
                                    radius: 14
                                    color: alreadyAdded ? "#1b2a3c" : (addItemBtn.hovered ? "#386ec0" : "#284e88")
                                    border.color: alreadyAdded ? "#293e58" : "transparent"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: alreadyAdded ? "✓ 已添加" : "+ 添加"
                                    color: alreadyAdded ? "#6ea8ff" : "white"
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    if (root.playlistMgr && root.localLibrary) {
                                        root.playlistMgr.addTrackToPlaylist(root.currentPlaylistId, root.localLibrary, index)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: addRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1
                        }
                    }
                }

                // 底部完成按钮
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38

                    background: Rectangle {
                        radius: 8
                        color: "#1e2c3e"
                        border.color: "#2c4058"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: "完成"
                        color: root.textPrimaryColor
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: addSongDialog.closeDialog()
                }
            }
        }
    }

    // ==========================================
    // 文件选择器：选择本地图片作为歌单封面
    // ==========================================
    FileDialog {
        id: fileDialog
        title: "选择歌单封面图片"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.webp *.bmp)"]
        onAccepted: {
            createDialog.selectedCover = selectedFile.toString()
        }
    }
}

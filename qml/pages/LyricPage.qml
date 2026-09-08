import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var playerController
    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"

    signal backRequested()

    //标记用户当前是否正在使用鼠标滚轮切换歌词 以及拖拽浏览歌词
    property bool userScrolling: false

    //沉浸式渐变背景
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0c131e"}
            GradientStop { position: 0.45; color: "#111b2b"}
            GradientStop { position: 0.85; color: "#16172d"}
            GradientStop { position: 1.0; color: "#0d1420"}
        }

        //柔和环境光量
        Rectangle {
            width: 560
            height: 560
            radius: 280
            x: root.width - 340
            y: -160
            color: "#1d3e6e"
            opacity: 0.16
        }

        Rectangle {
            width: 480
            height: 480
            radius: 240
            x: -100
            y: root.height - 320
            color: "#3d2258"
            opacity: 0.14
        }
    }

    //顶部歌曲信息(歌名 + 歌手)
    Column {
        id: songHeader
        anchors.top: parent.top
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 120,600)
        spacing: 6
        z: 5

        Text {
            width: parent.width
            text: root.playerController.title !== "" ? root.playerController : "未选择歌曲"
            color: root.textPrimaryColor
            font.pixelSize: 22
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.playerController.artist !== "" ? root.playerController.artist : "未知歌手"
            color:  root.textSecondaryColor
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    //暂无歌词状态提示
    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: !root.playerController.lyricList || root.playerController.lyricList.length === 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.playerController.currentLyric === "暂无歌词" ? "暂无歌词" : "纯音乐,请欣赏"
            color: root.textSecondaryColor
            font.pixelSize: 18
        }
    }

    //用户手动滚动后的自动居中回复定时器
    Timer {
        id: userScrollTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.userScrolling = false
            root.centerCurrentLyric()
        }
    }

    //歌词滚动列表
    ListView {
        id: lyricListView
        anchors.top: songHeader.bottom
        anchors.topMargin: 16
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds

        model: root.playerController.lyricList
        //首尾空距 确保第一行和最后一行都能滚到视野垂直中心
        header: Item {
            width: lyricListView.width
            height: lyricListView.height * 0.45
        }

        footer: Item {
            width: lyricListView.width
            height: lyricListView.height * 0.45
        }

        //垂直滚动条
        ScrollBar.vertical: ScrollBar {
            id: vbar
            policy: ScrollBar.AsNeeded
            active: lyricListView.moving || lyricListView.flicking
            contentItem:  Rectangle {
                implicitWidth: 6
                radius: 3
                color: vbar.pressed ? "#6ea8ff" : (vbar.hovered ? "#4a6890" : "#244248")
            }
        }

        //捕获用户手动滚动
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

        delegate: Item{
            id: lyricDelegate
            required property int index
            required property var modelData

            width: lyricListView.width
            height: lyricText.implicitHeight + 30

            readonly property bool isCurrent: index === root.playerController.currentLyricIndex
            readonly property bool isHovered: delegateMouseArea.containsMouse

            Text {
                id: lyricText
                anchors.centerIn: parent
                width: Math.min(parent.width - 60,720)
                text: lyricDelegate.modelData.text
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.wrap
                font.pixelSize: lyricDelegate.isCurrent ? 24 : 16
                font.weight: lyricDelegate.isCurrent ? Font.Bold : (lyricDelegate.isHovered ? Font.Medium : Font.Normal)
                color: lyricDelegate.isCurrent ? "#ffffff" : (lyricDelegate.isHovered ? "#dce7f5" : "#7d8b9d")
                opacity: lyricDelegate.isCurrent ? 1.0 : (lyricDelegate.isHovered ? 0.9 : 0.65)

                Behavior on font.pixelSize {
                    NumberAnimation { duration: 250;easing.type: Easing.OutQuad}
                }
                Behavior on color {
                    ColorAnimation { duration: 200}
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200}
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
                    //音乐跳转到选中的歌词时间
                    root.playerController.seekToLyric(lyricDelegate.index)
                    //选中的歌词平滑移动到最中间
                    lyricListView.positionViewAtIndex(lyricDelegate.index,ListView.Center)
                }
            }
        }
    }

    //居中当前歌词函数
    function centerCurrentLyric() {
        if(lyricListView.count > 0 && root.playerController.currentLyricIndex >= 0 && root.playerController.currentLyricIndex < lyricListView.count)
        {
            lyricListView.positionViewAtIndex(root.playerController.currentLyricIndex,ListView.Center)
        }
    }

    //监听播放器当前歌词索引变化
    Connections {
        target: root.playerController
        function onCurrentLyricIndexChanged() {
            if(!root.userScrolling && lyricListView.count > 0)
            {
                root.centerCurrentLyric()
            }
        }
        function onLyricListChanged() {
            root.userScrolling = false
            userScrollTimer.stop()
            if(lyricListView.count > 0){
                lyricListView.positionViewAtBeginning()
            }
        }
    }

    //页面显示时自动居中
    onVisibleChanged: {
        if(visible) {
            root.userScrolling = false
            userScrollTimer.stop()
            Qt.callLater(function(){
                root.centerCurrentLyric()
            })
        }
    }
}

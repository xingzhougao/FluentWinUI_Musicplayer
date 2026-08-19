import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    implicitHeight: 96
    color: "#0e151e"

    border.color: root.borderColor
    border.width: 1

    required property var playerController

    property color borderColor: "#1f2b3a"
    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"

    //播放控制图标 上一首 下一首 开始暂停重新播放
    property url previousIcon: "../icons/previous.svg"
    property url nextIcon: "../icons/next.svg"
    property url playIcon: "../icons/play.svg"
    property url pauseIcon: "../icons/pause.svg"
    property url restartIcon: "../icons/restart.svg"

    //音量图标
    property url volumeIcon: "../icons/volume.svg"
    property url muteIcon: "../icons/mute.svg"

    //播放模式图标
    property url sequenceIcon: "../icons/sequence.svg"   //顺序播放
    property url randomIcon: "../icons/random.svg"     //随机播放
    property url repeatIcon: "../icons/repeat.svg"     //重复播放

    //喜欢按钮
    property url favoriteIcon: "../icons/like.svg"
    property url favoriteFilledIcon: "../icons/cancel_like.svg"

    //音量加按钮 音量减按钮
    property url addvolumeIcon: "../icons/addvolume.svg"
    property url recvolumeIcon: "../icons/recvolume.svg"

    //点击歌词按钮时向外发送
    signal lyricRequested()

    //播放模式改变后向外发送
    signal playModeRequested(int mode)


    //返回当前播放模式图标
    function currentModeIcon() {
        if(root.playerController.playMode === 0)
            return sequenceIcon
        if(root.playerController.playMode === 1)
            return randomIcon
        return repeatIcon
    }

    //返回当前播放模式文字
    function currentModeText() {
        if(root.playerController.playMode === 0)
            return "顺序播放"
        if(root.playerController.playMode === 1)
            return "随机播放"
        return "重复播放"
    }

    //设置播放模式
    function setPlayMode(mode) {
        root.playerController.playMode = mode
        playModeRequested(mode)
        modePopup.close()
    }

    //静音 / 取消静音  静音: playerController.volume = 0 取消静音 直接读取volumeSlider.value
    function toggleMute() {
        root.playerController.muted = !root.playerController.muted
    }

    //PlayBar 整体布局
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 18

        //左侧 当前歌曲信息
        RowLayout {
            Layout.preferredWidth: 300
            spacing: 12

            //歌曲封面
            Rectangle {
                Layout.preferredWidth: 58
                Layout.preferredHeight: 58
                radius: 15

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#6d60d8" }
                    GradientStop { position: 1.0; color: "#3979a8"}
                }

                Text {
                    anchors.centerIn: parent
                    text: "♪"
                    color: "white"
                    font.pixelSize: 24
                }
            }

            //歌名+歌手
            ColumnLayout {
                spacing: 2

                Text {
                    text: root.playerController.title
                    color: root.textPrimaryColor
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.maximumWidth: 170
                }

                Text {
                    text: root.playerController.artist
                    color: root.textSecondaryColor
                    font.pixelSize: 10
                }
            }

            //弹簧
            Item {
                Layout.fillWidth: true
            }

            //喜欢按钮
            Button {
                id: likeButton
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                background: Rectangle {
                    radius: 8
                    color: likeButton.hovered ? "#192532" : "transparent"
                }

                contentItem: Item {
                    Image{
                        anchors.centerIn: parent
                        source: root.playerController.favorite ? root.favoriteFilledIcon : root.favoriteIcon
                        sourceSize.width: 25
                        sourceSize.height: 25
                        fillMode: Image.PreserveAspectFit
                    }
                }

                ToolTip.visible: hovered
                ToolTip.text: root.playerController.favorite ? "取消喜欢" : "喜欢"
                ToolTip.delay: 500

                onClicked: {
                    root.playerController.toggleFavorite()
                }
            }
        }

        //中间区域 播放控制+歌曲进度条
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            //播放控制按钮
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 14

                //上一曲
                Button {
                    id: prevButton

                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38

                    background: Rectangle {
                        radius: 8
                        color: prevButton.hovered ? "#192532" : "transparent"
                    }

                    contentItem: Image {
                        source: root.previousIcon
                        sourceSize.width: 18
                        sourceSize.height: 18
                        fillMode: Image.PreserveAspectFit
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "上一曲"
                    ToolTip.delay: 500

                    onClicked: {
                        root.playerController.previous()
                    }
                }

                //播放/暂停
                Button {
                    id: playButton

                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46

                    background: Rectangle {
                        radius: 23
                        color: playButton.hovered ? "#ffffff" : "#edf4ff"
                    }

                    contentItem: Image {
                        //playing = true 显示暂停图片 playing = flase 显示播放图片
                        source: root.playerController.playing ? root.pauseIcon : root.playIcon
                        sourceSize.width: 20
                        sourceSize.height: 20
                        fillMode: Image.PreserveAspectFit
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: root.playerController.playing ? "暂停" : "播放"
                    ToolTip.delay: 500

                    onClicked: {
                        root.playerController.togglePlay()
                    }
                }

                //下一曲
                Button {
                    id: nextButton
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38

                    background: Rectangle {
                        radius: 8
                        color: nextButton.hovered ? "#192532" : "transparent"
                    }

                    contentItem: Image {
                        source: root.nextIcon
                        sourceSize.width: 18
                        sourceSize.height: 18
                        fillMode: Image.PreserveAspectFit
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "下一曲"
                    ToolTip.delay: 500

                    onClicked: {
                        root.playerController.next()
                    }
                }

                //重新播放
                Button {
                    id: restartButton
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34

                    background: Rectangle {
                        radius: 8
                        color: restartButton.hovered ? "#192532" : "transparent"
                    }

                    contentItem: Image {
                        source: root.restartIcon
                        sourceSize.width: 18
                        sourceSize.height: 18
                        fillMode: Image.PreserveAspectFit
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "重新播放"
                    ToolTip.delay: 500

                    onClicked: {
                        root.playerController.restart()
                    }
                }
            }

            //歌曲播放进度
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: root.playerController.formatTime(
                              root.playerController.progress
                              * root.playerController.duration
                          )
                    color: "#6f7d90"
                    font.pixelSize: 10
                }

                Slider {
                    id: progressSlider
                    Layout.fillWidth: true

                    from: 0
                    to: 1

                    value: root.playerController.progress

                    onMoved: {
                        root.playerController.progress = value
                    }

                    background: Rectangle {
                        x: progressSlider.leftPadding
                        y: progressSlider.topPadding
                           + progressSlider.availableHeight / 2
                           - height / 2

                        width: progressSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#243142"

                        Rectangle {
                            width: progressSlider.visualPosition * parent.width     //visualPosition = value / 1
                            height: parent.height
                            radius: 2
                            color: "#7eb0ff"
                        }
                    }

                    handle: Rectangle {
                        x: progressSlider.leftPadding
                           + progressSlider.visualPosition
                           * (progressSlider.availableWidth - width)

                        y: progressSlider.topPadding
                           + progressSlider.availableHeight / 2
                           - height / 2

                        width: progressSlider.pressed ? 14 : 10
                        height: width
                        radius: width / 2

                        color: "#f5f8ff"
                        border.color: "#6fa7f6"

                        Behavior on width {
                            NumberAnimation {
                                duration: 90
                            }
                        }
                    }
                }

                Text {
                    text: root.playerController.formatTime(root.playerController.duration)
                    color: "#6f7d90"
                    font.pixelSize: 10
                }
            }
        }

        //右侧区域 歌词 音量按钮 音量Slider 播放模式 固定较小宽度
        RowLayout {
            Layout.preferredWidth: 300
            Layout.maximumWidth: 320
            spacing: 8

            //歌曲
            Button {
                id: lyricButton
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34

                background: Rectangle {
                    radius: 10
                    color: lyricButton.hovered ? "#192532" : "transparent"
                }

                contentItem: Text {
                    text: "词"
                    color: lyricButton.hovered ? "#d7e3f1" : "#8c9aae"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                ToolTip.visible: hovered
                ToolTip.text: "显示歌词"
                ToolTip.delay: 500

                onClicked: {
                    root.lyricRequested()
                }
            }

            //音量 静音按钮
            Button {
                id: volumeButton
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                background: Rectangle {
                    radius: 8
                    color: volumeButton.hovered ? "#192532" : "transparent"
                }

                contentItem: Image {
                    source: root.playerController.muted ? root.muteIcon : root.volumeIcon
                    sourceSize.width: 18
                    sourceSize.height: 18
                    fillMode: Image.PreserveAspectFit
                }

                ToolTip.visible: hovered
                ToolTip.text: root.playerController.muted ? "取消静音" : "静音"
                ToolTip.delay: 500

                onClicked: {
                    root.toggleMute()
                }
            }

            //音量Slider
            Slider {
                id: volumeSlider

                Layout.preferredWidth: 130
                Layout.maximumWidth: 130

                from: 0
                to: 1

                value: root.playerController.volume

                onMoved: {
                    root.playerController.volume = value
                }

                background: Rectangle {
                    x: volumeSlider.leftPadding

                    y: volumeSlider.topPadding
                       + volumeSlider.availableHeight / 2
                       - height / 2

                    width: volumeSlider.availableWidth
                    height: 4
                    radius: 2
                    color: "#253344"

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: "#7aa9ee"
                    }
                }

                handle: Rectangle {
                    x: volumeSlider.leftPadding
                       + volumeSlider.visualPosition
                       * (volumeSlider.availableWidth - width)

                    y: volumeSlider.topPadding
                       + volumeSlider.availableHeight / 2
                       - height / 2

                    width: 10
                    height: 10
                    radius: 5
                    color: "#eef4ff"
                }
            }

            Button {
                id:addvolume
                Layout.preferredWidth: 25
                Layout.preferredHeight: 36

                padding: 0

                background: Rectangle {
                    radius: 8
                    color: addvolume.hovered ? "192532" : "transparent"
                }

                contentItem: Image {
                    source: root.addvolumeIcon
                    width: 20
                    height: 20
                    sourceSize.width: 20
                    sourceSize.height: 20
                    fillMode: Image.PreserveAspectFit
                }

                ToolTip.visible: hovered
                ToolTip.text: "音量加"
                ToolTip.delay: 500

                onClicked: {
                    Math.min(1.0,root.playerController.volume += 0.05 )
                }
            }

            Button {
                id:recvolume
                Layout.preferredWidth: 25
                Layout.preferredHeight: 36

                padding: 0

                background: Rectangle {
                    radius: 8
                    color: recvolume.hovered ? "192532" : "transparent"
                }

                contentItem: Image {
                    source: root.recvolumeIcon
                    width: 20
                    height: 20
                    sourceSize.width: 20
                    sourceSize.height: 20
                    fillMode: Image.PreserveAspectFit
                }

                ToolTip.visible: hovered
                ToolTip.text: "音量减"
                ToolTip.delay: 500

                onClicked: {
                    Math.max(0.0,root.playerController.volume -= 0.05)
                }
            }


            //播放模式按钮 默认只显示当前模式图片 点击后向上展开Popup
            Button {
                id: modeButton

                Layout.preferredWidth: 30
                Layout.preferredHeight: 36

                background: Rectangle {
                    radius: 8
                    color: modeButton.hovered ? "#192532" : "transparent"
                }

                contentItem: Image {
                    source: root.currentModeIcon()
                    sourceSize.width: 20
                    sourceSize.height: 20
                    fillMode: Image.PreserveAspectFit
                }

                ToolTip.visible: hovered
                ToolTip.text: root.currentModeText()
                ToolTip.delay: 500

                onClicked: {
                    if(modePopup.opened) {
                        modePopup.close()
                    } else {
                        modePopup.open()
                    }
                }

                Popup {
                    id: modePopup

                    width: 54
                    height: 142

                    x: (modeButton.width - width) / 2
                    y: -height - 8

                    padding: 6

                    closePolicy:
                        Popup.CloseOnEscape
                        | Popup.CloseOnPressOutside

                    background: Rectangle {
                        radius: 10
                        color: "#151e29"
                        border.color: "#263648"
                        border.width: 1
                    }

                    contentItem: ColumnLayout {
                        spacing: 4

                        //顺序播放
                        Button {
                            id: sequenceButton

                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignHCenter   //控件在被ROWLayout ColumnLayout GridLayout 这类Layout管理时 让它在水平方向居中

                            background: Rectangle {
                                radius: 7
                                color:
                                    root.playerController.playMode === 0
                                    ? "#223149"
                                    : (sequenceButton.hovered
                                       ? "#1b2735"
                                       : "transparent")
                            }

                            contentItem: Image {
                                source: root.sequenceIcon
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: "顺序播放"
                            ToolTip.delay: 300

                            onClicked: {
                                root.setPlayMode(0)
                            }
                        }

                        //随机播放
                        Button {
                            id: randomButton

                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignHCenter

                            background: Rectangle {
                                radius: 7
                                color:
                                    root.playerController.playMode === 1
                                    ? "#223149"
                                    : (randomButton.hovered
                                       ? "#1b2735"
                                       : "transparent")
                            }

                            contentItem: Image {
                                source: root.randomIcon
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: "随机播放"
                            ToolTip.delay: 300

                            onClicked: {
                                root.setPlayMode(1)
                            }
                        }

                        //重复播放
                        Button {
                            id: repeatModeButton

                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignHCenter

                            background: Rectangle {
                                radius: 7
                                color:
                                    root.playerController.playMode === 2
                                    ? "#223149"
                                    : (repeatModeButton.hovered
                                       ? "#1b2735"
                                       : "transparent")
                            }

                            contentItem: Image {
                                source: root.repeatIcon
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: "重复播放"
                            ToolTip.delay: 300

                            onClicked: {
                                root.setPlayMode(2)
                            }
                        }
                    }
                }
            }
        }
    }
}
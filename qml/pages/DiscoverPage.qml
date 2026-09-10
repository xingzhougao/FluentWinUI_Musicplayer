import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property var playerController
    property var recentModel: typeof recentLibrary !== "undefined" ? recentLibrary : null
    property var favoriteMgr: typeof favoriteManager !== "undefined" ? favoriteManager : null
    property color textPrimaryColor: "#f5f7fb"
    property color textSecondaryColor: "#8c99aa"
    property color accentColor: "#6ea8ff"
    property url bannerSource: "../image_resource/banner.png"

    signal playRecommendRequested()
    signal viewAllRecentRequested()

    ScrollView {
        id: contentScroll
        anchors.fill: parent
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: availableWidth

        Column {
            id: contentColumn
            x: 26
            y: 26
            width: Math.max(0,contentScroll.availableWidth - 52)
            spacing: 28

            Rectangle {
                width: parent.width
                height: 252
                radius: 28
                clip: true
                border.color: "#30435c"
                border.width: 1

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#182d52"}
                    GradientStop { position: 0.5; color: "#203b71"}
                    GradientStop { position: 1.0; color: "#63446c"}
                }

                Image {
                    id: bannerImage
                    anchors.fill: parent
                    source: root.bannerSource
                    fillMode: Image.PreserveAspectCrop
                    visible: root.bannerSource !== ""
                    smooth: true
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#40000000"
                    visible: bannerImage.visible
                }

                Rectangle {
                    width: 330
                    height: 330
                    radius: 165
                    x: parent.width - 240
                    y: -55
                    color: "#40ffffff"
                    opacity: 0.14
                    visible: !bannerImage.visible
                }

                Rectangle {
                    width: 220
                    height: 220
                    radius: 110
                    x: parent.width - 120
                    y: 105
                    color: "#502568ff"
                    opacity: 0.4
                    visible: !bannerImage.visible
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 20

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 26
                            radius: 13
                            color: "#30ffffff"
                            border.color: "#44ffffff"

                            Text {
                                anchors.centerIn: parent
                                text: "DAILY MIX"
                                color: "#e8efff"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                font.letterSpacing: 1.2
                            }
                        }

                        Text {
                            text: "在城市灯火里,\n找到属于你的节拍"
                            color: "white"
                            font.pixelSize: 30
                            font.weight: Font.DemiBold
                            lineHeight: 1.1
                        }

                        Text {
                            text: "为你精选 42 首歌曲 · 根据最近播放实时更新"
                            color: "#c8d6eb"
                            font.pixelSize: 12
                        }

                        Row {
                            spacing: 10

                            Button {
                                id: bannerPlay
                                text: "▶ 立即播放"
                                width: 116
                                height: 38

                                background: Rectangle {
                                    radius: 19
                                    color: bannerPlay.hovered ? "#f8fbff" : "#eaf2ff"
                                }

                                contentItem: Text {
                                    text: bannerPlay.text
                                    color: "#152239"
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    // if(!root.playerController.playing)
                                    //     root.playerController.togglePlay()
                                    root.playRecommendRequested()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 184
                        Layout.preferredHeight: 184
                        radius: 92
                        color: "#17000000"
                        border.color: "#48ffffff"
                        border.width: 1

                        Rectangle {
                            width: 142
                            height: 142
                            radius: 71
                            anchors.centerIn: parent
                            color: "#18ffffff"
                            border.color: "#26ffffff"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "♫"
                            color: "#ffffff"
                            font.pixelSize: 64
                            font.bold: true
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 10

                Text {
                    id: recommendationTitle
                    text: "为你推荐"
                    color: root.textPrimaryColor
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.baseline: recommendationTitle.baseline
                    text: "根据你的最近播放"
                    color: root.textSecondaryColor
                    font.pixelSize: 11
                }
            }

            GridLayout {
                width: parent.width
                columns: width >= 1040 ? 4 : (width >= 780 ? 3 : 2)
                rowSpacing: 18
                columnSpacing: 18

                Repeater {
                    model: [
                        { title: "夜色公路", artist: "Synthwave · 32首",a1: "#7559ff", a2: "#2b8cff",cover:"../image_resource/night_road.png"},
                        { title: "雨天书房", artist: "Lo-fi · 48首",a1: "#44637f", a2: "#82a4b3",cover:"../image_resource/rainy_room.png"},
                        { title: "午夜霓虹", artist: "Electronic · 27首",a1: "#b24f8d",a2: "#6046c7",cover:"../image_resource/midnight_neon.png"},
                        { title: "晨间轻醒", artist: "Pop · 36首",a1: "#d88d52",a2: "#e8bc68",cover:"../image_resource/morning_clarity.png"},
                        { title: "深夜独处", artist: "R&B · 41首",a1: "#394e73",a2: "#6a4f82",cover:"../image_resource/alone_night.png"},
                        { title: "专注编码", artist: "Focus · 55首",a1: "#25598d",a2:"#4a9c88",cover:"../image_resource/focused_coding.png"},
                        { title: "城市漫游", artist: "Indie · 29首",a1: "#bc6d4f",a2:"#7d527d",cover:"../image_resource/city_wandering.png"},
                        { title: "周末咖啡馆", artist: "Jazz · 38首",a1: "#6a604b",a2: "#b98b63",cover:"../image_resource/weekend_coffee.png"}
                    ]

                    delegate: AlbumCard {

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 220
                        title: modelData.title
                        artist: modelData.artist
                        accent1: modelData.a1
                        accent2: modelData.a2
                        coverSource: modelData.cover
                    }
                }
            }

            RowLayout {
                width: parent.width

                Text {
                    text: "最近播放"
                    color: root.textPrimaryColor
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true}

                Button {
                    id: moreButton
                    text: "查看全部 ->"
                    background: null
                    hoverEnabled: true

                    contentItem: Text {
                        text: moreButton.text
                        color: moreButton.hovered ? "#9dc3ff" : "#7891b0"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.viewAllRecentRequested()
                    }
                }
            }

            // 空状态提示
            Rectangle {
                width: parent.width
                height: 80
                radius: 14
                color: "#101925"
                border.color: "#1c293a"
                border.width: 1
                visible: !root.recentModel || root.recentModel.count === 0

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "♫"
                        color: root.accentColor
                        font.pixelSize: 22
                        opacity: 0.7
                    }

                    Text {
                        text: "暂无最近播放记录，快去听听音乐吧~"
                        color: root.textSecondaryColor
                        font.pixelSize: 13
                    }
                }
            }

            // 最近播放前5首列表
            ListView {
                id: recentListView
                width: parent.width
                height: Math.min(5, count) * 68
                interactive: false
                clip: true
                model: root.recentModel
                visible: root.recentModel && root.recentModel.count > 0

                delegate: Item {
                    width: recentListView.width
                    height: index < 5 ? 68 : 0
                    visible: index < 5

                    MusicRow {
                        width: parent.width
                        height: 60
                        anchors.top: parent.top
                        numberText: (index + 1 < 10 ? "0" : "") + (index + 1)
                        title: model.title || "未知歌曲"
                        artist: model.artist || "未知歌手"
                        album: model.album || ""
                        durationText: root.playerController ? root.playerController.formatTime(model.duration) : "03:45"
                        favorite: model.favorite || false
                        isCurrent: root.playerController && root.playerController.currentLibrary === root.recentModel && root.playerController.currentIndex === index
                        isPlaying: isCurrent && root.playerController.playing
                        textPrimaryColor: root.textPrimaryColor
                        textSecondaryColor: root.textSecondaryColor
                        accentColor: root.accentColor

                        onPlayRequested: {
                            if (root.playerController && root.recentModel) {
                                root.playerController.playFromModel(root.recentModel, index);
                            }
                        }

                        onFavoriteToggled: {
                            if (root.recentModel) {
                                root.recentModel.toggleFavorite(index);
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 18
            }
        }
    }
}

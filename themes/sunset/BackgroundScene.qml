import QtQuick

Item {
    id: scene
    property url source
    property bool animated: true
    readonly property bool running: animated && visible
    property real drift: 0
    clip: true

    // The whole scene moves together, so the light stays attached to the sun.
    Item {
        anchors.fill: parent
        scale: scene.animated ? 1.018 + scene.drift * 0.018 : 1
        transform: Translate {
            x: scene.animated ? (scene.drift - 0.5) * scene.width * 0.012 : 0
            y: scene.animated ? (scene.drift - 0.5) * scene.height * 0.008 : 0
        }

        Image {
            id: landscape
            anchors.fill: parent
            source: scene.source
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
        }

        Canvas {
            id: sunlight
            anchors.fill: parent
            visible: scene.animated
            opacity: 0.18
            // Match the sun's position after PreserveAspectCrop on any aspect ratio.
            readonly property real imageScale: Math.max(width / Math.max(1, landscape.sourceSize.width),
                                                        height / Math.max(1, landscape.sourceSize.height))
            readonly property real imageWidth: landscape.sourceSize.width * imageScale
            readonly property real imageHeight: landscape.sourceSize.height * imageScale
            onImageWidthChanged: requestPaint()
            onImageHeightChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var x = (width - imageWidth) / 2 + imageWidth * 0.25
                var y = (height - imageHeight) / 2 + imageHeight * 0.4
                var radius = Math.max(1, imageWidth * 0.2)
                var glow = ctx.createRadialGradient(x, y, 0, x, y, radius)
                glow.addColorStop(0, "#fff8ca")
                glow.addColorStop(0.35, "#ffca63")
                glow.addColorStop(1, "transparent")
                ctx.fillStyle = glow
                ctx.fillRect(0, 0, width, height)
            }

            SequentialAnimation on opacity {
                running: scene.running
                loops: Animation.Infinite
                NumberAnimation { from: 0.035; to: 0.09; duration: 4800; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.09; to: 0.035; duration: 4800; easing.type: Easing.InOutSine }
            }
        }
    }

    SequentialAnimation on drift {
        running: scene.running
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 24000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1; to: 0; duration: 24000; easing.type: Easing.InOutSine }
    }

    // A small fixed number of embers avoids an extra particle or video dependency.
    Repeater {
        model: 26
        delegate: Item {
            id: ember
            required property int index
            readonly property real initialPhase: ((index * 17 + 3) % 29) / 29
            readonly property real origin: ((index * 37 + 11) % 101) / 101
            readonly property int lifetime: 14000 + (index % 7) * 1600
            property real progress: initialPhase
            width: (index % 3 + 1.5) * Math.max(0.6, scene.height / 768)
            height: width
            x: scene.width * (0.04 + origin * 0.85)
               + Math.sin(progress * Math.PI * 2 + index) * 22 * scene.height / 768
            y: scene.height * (1.06 - progress * 0.94)
            visible: scene.animated
            opacity: Math.sin(progress * Math.PI) * (index % 3 === 0 ? 0.75 : 0.4)

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 4; height: width; radius: width / 2
                color: "#ffb849"
                opacity: 0.1
            }
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: ember.index % 3 === 0 ? "#fff0bb" : "#ffc266"
            }

            SequentialAnimation {
                running: scene.running
                // Seed the first pass to populate the scene immediately.
                NumberAnimation {
                    target: ember; property: "progress"
                    from: ember.initialPhase; to: 1
                    duration: ember.lifetime * (1 - ember.initialPhase)
                }
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation {
                        target: ember; property: "progress"
                        from: 0; to: 1; duration: ember.lifetime
                    }
                }
            }
        }
    }
}

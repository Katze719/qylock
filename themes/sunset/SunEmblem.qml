import QtQuick

Canvas {
    id: emblem
    property color ink: "#d8b77e"
    property bool animated: false
    onInkChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.save()
        ctx.translate(width / 2, height / 2)
        var radius = Math.min(width, height) * 0.29
        ctx.strokeStyle = ink
        ctx.lineWidth = Math.max(0.7, width / 64)
        ctx.beginPath()
        ctx.arc(0, 0, radius, 0, Math.PI * 2)
        ctx.stroke()
        for (var i = 0; i < 16; ++i) {
            ctx.save()
            ctx.rotate(i * Math.PI / 8)
            ctx.beginPath()
            ctx.moveTo(0, -radius * 1.16)
            ctx.lineTo(0, -radius * (i % 4 === 0 ? 1.68 : 1.43))
            ctx.stroke()
            ctx.restore()
        }
        ctx.beginPath()
        ctx.moveTo(0, -radius * 0.42)
        ctx.lineTo(radius * 0.3, 0)
        ctx.lineTo(0, radius * 0.42)
        ctx.lineTo(-radius * 0.3, 0)
        ctx.closePath()
        ctx.stroke()
        ctx.restore()
    }

    RotationAnimation on rotation {
        running: emblem.animated && emblem.visible
        from: 0; to: 360; duration: 180000
        loops: Animation.Infinite
    }
}

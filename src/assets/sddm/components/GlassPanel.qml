import QtQuick
import QtQuick.Effects

Item {
    id: glass

    // The item to blur (your background image/video). It must NOT be a parent of the glass.
    property Item source
    property real radius: height / 4
    property color tint: Qt.rgba(Config.textColor.r, Config.textColor.g, Config.textColor.b, 0.25)
    property color borderColor: Qt.rgba(Config.black.r, Config.black.g, Config.black.b, 0.5)
    property real borderWidth: 1
    property real blurAmount: 1.0
    property int blurMax: 24

    // Captures only the region of the background that sits behind this panel
    ShaderEffectSource {
        id: capture
        anchors.fill: parent
        sourceItem: glass.source
        sourceRect: {
            // Touch these so the rect is re-evaluated if layout changes
            glass.x; glass.y; glass.width; glass.height
            if (!glass.source) return Qt.rect(0, 0, 0, 0)
            var p = glass.mapToItem(glass.source, 0, 0)
            return Qt.rect(p.x, p.y, glass.width, glass.height)
        }
        visible: false
        live: false          // set to true if your background is animated/video
        recursive: false
    }

    // Rounded mask so the blur follows the pill shape
    Rectangle {
        id: mask
        anchors.fill: parent
        radius: glass.radius
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: capture
        blurEnabled: true
        blur: glass.blurAmount
        blurMax: glass.blurMax
        saturation: 0.2          // slight boost, 0 = unchanged
        maskEnabled: true
        maskSource: mask
        autoPaddingEnabled: false
    }

    // Tint + border on top of the blur
    Rectangle {
        anchors.fill: parent
        radius: glass.radius
        color: glass.tint
        border.color: glass.borderColor
        border.width: glass.borderWidth
    }
}

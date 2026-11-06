import QtQuick
import QtQuick.Effects

// Recolorable SVG icon. Size the item to the size you want the icon drawn at.
Item {
    id: icon

    property url source
    property color color: Config.textColor

    Image {
        id: img
        anchors.fill: parent
        source: icon.source
        sourceSize.height: icon.height   // rasterize at final size = crisp
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    MultiEffect {
        anchors.fill: img
        source: img
        colorization: 1.0
        colorizationColor: icon.color
    }
}

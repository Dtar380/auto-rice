import QtQuick
import QtQuick.Effects

// Circular avatar with fallback image and a thin ring.
Item {
    id: avatar

    property url source
    property url fallback
    property real ringWidth: 1

    Item {
        id: imageContainer
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Image {
            id: userImage
            anchors.fill: parent
            source: avatar.source
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            anchors.fill: parent
            source: avatar.fallback
            fillMode: Image.PreserveAspectCrop
            visible: userImage.status !== Image.Ready
        }
    }

    Item {
        id: maskItem
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "black"
        }
    }

    MultiEffect {
        anchors.fill: imageContainer
        source: imageContainer
        maskEnabled: true
        maskSource: maskItem
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: Config.black
        border.width: avatar.ringWidth
        opacity: 0.5
    }
}

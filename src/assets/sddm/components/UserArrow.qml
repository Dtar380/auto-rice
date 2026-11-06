import QtQuick

// Clickable glyph (‹ / ›) with hover feedback. Set `text` and font.pixelSize at the use site.
Text {
    id: arrow

    signal clicked()

    color: Config.textColor
    font.family: Config.customFont
    opacity: mouse.containsMouse ? 0.85 : 0.6

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: arrow.clicked()
    }
}

import QtQuick

// Square glass button with a recolorable icon.
GlassPanel {
    id: button

    property url icon
    property bool error: false
    readonly property bool hovered: mouse.containsMouse

    signal clicked()

    borderColor: hovered ? Config.accent
               : error ? Config.red
               : Qt.rgba(Config.black.r, Config.black.g, Config.black.b, 0.5)

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }

    ColoredIcon {
        anchors.centerIn: parent
        width: parent.height * 0.4
        height: width
        source: button.icon
    }
}

import QtQuick

Column {
    id: hint

    property color color: Config.subtextColor
    property string label: "Press to unlock"

    opacity: 0.8

    ColoredIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.height * 0.025
        height: width
        source: Qt.resolvedUrl("../assets/icons/enter.svg")
        color: hint.color
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: hint.label
        font.pixelSize: root.height * 0.015
        font.family: Config.customFont
        color: hint.color
    }
}

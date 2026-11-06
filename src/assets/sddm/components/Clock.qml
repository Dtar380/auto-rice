import QtQuick

// Time + date. `screenHeight` drives all proportions.
Column {
    id: clock

    property real screenHeight: 1080
    property date now: new Date()

    spacing: -screenHeight * 0.025

    function capitalizeWords(s) {
        return s.toLowerCase().replace(/(^\w|\s\w)/g, function (m) { return m.toUpperCase(); });
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(clock.now, "hh:mm")
        font.pixelSize: clock.screenHeight * 0.1
        font.family: Config.customFont
        font.bold: true
        color: Config.textColor
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: clock.capitalizeWords(Qt.formatDateTime(clock.now, "ddd dd MMM yyyy"))
        font.pixelSize: clock.screenHeight * 0.05
        font.family: Config.customFont
        color: Config.textColor
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }
}

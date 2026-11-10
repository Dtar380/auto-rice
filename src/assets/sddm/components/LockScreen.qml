import QtQuick

Item {
    id: lockRoot

    signal loginRequested()

    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true;
            lockRoot.loginRequested();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: lockRoot.loginRequested()
    }

    Clock {
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.25
        anchors.horizontalCenter: parent.horizontalCenter
    }

    UnlockHint {
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

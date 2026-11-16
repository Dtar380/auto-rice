import QtQuick
import QtQuick.Effects
import "components"

// Adapted from the SDDM Main.qml. One instance per monitor.
// NOTE: keep `id: root` -- Clock.qml and UnlockHint.qml reference root.height.
Item {
    id: root

    property var context      // the shared LockContext

    state: Config.lockScreenDisplay ? "lockState" : "loginState"

    states: [
        State {
            name: "lockState"
            PropertyChanges { target: lockScreen; y: 0 }
            PropertyChanges { target: loginScreen; y: root.height }
            PropertyChanges { target: backgroundEffect; blurMax: 24 }
        },
        State {
            name: "loginState"
            PropertyChanges { target: lockScreen; y: -root.height }
            PropertyChanges { target: loginScreen; y: 0 }
            PropertyChanges { target: backgroundEffect; blurMax: 8 }
        }
    ]

    transitions: [
        Transition {
            from: "lockState"; to: "loginState"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: lockScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                    NumberAnimation { target: loginScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                    NumberAnimation { target: backgroundEffect; property: "blurMax"; duration: 550 }
                }
                ScriptAction { script: loginScreen.resetFocus() }
            }
        },
        Transition {
            from: "loginState"; to: "lockState"
            ParallelAnimation {
                NumberAnimation { target: lockScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                NumberAnimation { target: loginScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                NumberAnimation { target: backgroundEffect; property: "blurMax"; duration: 550 }
            }
        }
    ]

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: Qt.resolvedUrl("assets/background.png")
        fillMode: Image.PreserveAspectCrop
        cache: true
        mipmap: true
    }

    MultiEffect {
        id: backgroundEffect
        source: backgroundImage
        anchors.fill: parent
        blurEnabled: true
        blur: 1.0
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#000"
        opacity: 0.1
    }

    // PAM result -> login screen (was `Connections { target: sddm }`)
    Connections {
        target: root.context
        function onFailed() { loginScreen.showError() }
    }

    Item {
        id: screenContainer
        anchors.fill: parent

        LockScreen {
            id: lockScreen
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            visible: y > -height
            enabled: root.state === "lockState"
            focus: root.state === "lockState"

            onLoginRequested: {
                root.state = "loginState"
                loginScreen.resetFocus()
            }
        }

        LoginScreen {
            id: loginScreen
            x: 0
            y: root.height
            width: parent.width
            height: parent.height
            visible: y < height
            enabled: root.state === "loginState"
            focus: root.state === "loginState"

            backgroundSource: backgroundImage
            userName: root.context.userName
            userRealName: root.context.realName
            userIcon: root.context.userIcon
            userCount: 1                       // single user: hides the ‹ › arrows

            onLoginRequested: (password) => root.context.tryUnlock(password)
            onClose: root.state = "lockState"
        }
    }
}

import "."
import QtQuick
import QtQuick.Effects
import "components"

Item {
    id: root

    width: 2560
    height: 1440

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
        // Swipe up: lock screen leaves through the top, login screen rises in from the bottom
        Transition {
            from: "lockState"; to: "loginState"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: lockScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                    NumberAnimation { target: loginScreen; property: "y"; duration: 550; easing.type: Easing.InOutCubic }
                    NumberAnimation { target: backgroundEffect; property: "blurMax"; duration: 550 }
                }
                // Make sure the password box is focused once the slide is done
                ScriptAction { script: loginScreen.resetFocus() }
            }
        },
        // Swipe down: login screen leaves through the bottom, lock screen comes down from the top
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
        id: backgroundDimmer
        anchors.fill: parent
        color: "#000"
        opacity: 0.1
    }

    // Hidden list used only to read the current user from SDDM's userModel
    ListView {
        id: userList
        model: userModel
        currentIndex: Config.currentUserIndex
        visible: false
	width: 100
	height: 100

        delegate: Item {
            property string userName: model.name || ""
            property string userRealName: model.realName || ""
            property string userIcon: model.icon || ""
        }
    }

    // All SDDM interaction lives here so the screens stay presentational
    Connections {
        target: sddm
        function onLoginFailed() { loginScreen.showError() }
    }

    Item {
        id: screenContainer
        anchors.fill: parent

        LockScreen {
            id: lockScreen
            // No anchors.fill: anchors would fight the y animation (same for the login screen below)
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            visible: y > -height
            enabled: root.state === "lockState"
            focus: root.state === "lockState"

            onLoginRequested: {
                root.state = "loginState";
                loginScreen.resetFocus();
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
            userName: userList.currentItem ? userList.currentItem.userName : ""
            userRealName: userList.currentItem ? userList.currentItem.userRealName : ""
            userIcon: userList.currentItem ? userList.currentItem.userIcon : ""
            userCount: userList.count

            onLoginRequested: (password) => {
                console.log("[rice] login attempt as:", loginScreen.userName)
                sddm.login(loginScreen.userName, password, 0)
            }
            onPreviousUser: Config.currentUserIndex = (Config.currentUserIndex - 1 + userList.count) % userList.count
            onNextUser: Config.currentUserIndex = (Config.currentUserIndex + 1) % userList.count
            onClose: root.state = "lockState"
        }
    }
}

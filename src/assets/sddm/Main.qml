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
            PropertyChanges { target: lockScreen; opacity: 1.0 }
            PropertyChanges { target: loginScreen; opacity: 0.0 }
            PropertyChanges { target: backgroundEffect; blurMax: 24 }
        },
        State {
            name: "loginState"
            PropertyChanges { target: lockScreen; opacity: 0.0 }
            PropertyChanges { target: loginScreen; opacity: 1.0 }
            PropertyChanges { target: backgroundEffect; blurMax: 8 }
        }
    ]

    transitions: Transition {
        enabled: true
        PropertyAnimation { duration: 150; properties: "opacity" }
        PropertyAnimation { duration: 400; properties: "blurMax" }
    }

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
            anchors.fill: parent
            opacity: 0.0
            enabled: opacity > 0
            focus: opacity > 0

            onLoginRequested: {
                root.state = "loginState";
                loginScreen.resetFocus();
            }
        }

        LoginScreen {
            id: loginScreen
            anchors.fill: parent
            opacity: 0.0
            enabled: opacity > 0
            focus: opacity > 0

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

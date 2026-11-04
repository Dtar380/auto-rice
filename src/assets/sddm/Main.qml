import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Item {
    id: root
    width: 2560
    height: 1440

    // Load font
    readonly property string customFont: config.stringValue("fontFamily") || "JetBrainsMono NF"

    // Active User Index for switching
    property int currentUserIndex: 0

    // --- BASE PALETTE ---
    readonly property color background: config.stringValue("background") || "#2e3440"
    readonly property color foreground: config.stringValue("foreground") || "#e5e9f0"
    readonly property color accent: config.stringValue("accent") || "#81a1c1"
    readonly property color selection: config.stringValue("selection") || "#88c0d0"
    readonly property color textColor: config.stringValue("textColor") || "#e5e9f0"
    readonly property color subtextColor: config.stringValue("subtextColor") || "#d8dee9"

    // --- ANSI REFERENCE MAPPING ---
    readonly property color black: config.stringValue("black") || "#2e3440"
    readonly property color red: config.stringValue("red") || "#bf616a"
    readonly property color green: config.stringValue("green") || "#a3be8c"
    readonly property color yellow: config.stringValue("yellow") || "#ebcb8b"
    readonly property color blue: config.stringValue("blue") || "#5e81ac"
    readonly property color magenta: config.stringValue("magenta") || "#b48ead"
    readonly property color cyan: config.stringValue("cyan") || "#88c0d0"
    readonly property color white: config.stringValue("white") || "#e5e9f0"
    readonly property color brightWhite: config.stringValue("brightWhite") || "#eceff4"

    // Hidden ListView to safely interface with SDDM's C++ UserModel
    ListView {
        id: userList
        model: userModel
        currentIndex: root.currentUserIndex
        visible: false
        delegate: Item {
            property string userName: model.name || ""
            property string userRealName: model.realName || ""
            property string userIcon: model.icon || ""
        }
    }

    // Background
    Image {
        id: bgImage
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Background Blur Effect
    FastBlur {
        id: blurEffect
        anchors.fill: bgImage
        source: bgImage
        radius: 8
    }

    // Background Darken Effect
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.1
    }

    // Time
    Column {
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: -parent.height * 0.025

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "hh:mm")
            color: root.textColor
            font.family: root.customFont
            font.pixelSize: root.height * 0.1
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter

            text: {
                var rawDate = Qt.formatDateTime(new Date(), "ddd dd MMM yyyy");
                return rawDate.toLowerCase().replace(/(^\w|\s\w)/g, function (match) {
                    return match.toUpperCase();
                });
            }

            color: root.textColor
            font.family: root.customFont
            font.pixelSize: root.height * 0.05
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                timeText.text = Qt.formatDateTime(new Date(), "hh:mm");

                var rawDate = Qt.formatDateTime(new Date(), "ddd dd MMM yyyy");
                dateText.text = rawDate.toLowerCase().replace(/(^\w|\s\w)/g, function (match) {
                    return match.toUpperCase();
                });
            }
        }
    }

    // Profile Avatar Circle
    Item {
        id: avatarContainer
        width: root.height * 0.25
        height: root.height * 0.25
        anchors.top: parent.top
        anchors.topMargin: root.height * 0.33
        anchors.horizontalCenter: parent.horizontalCenter

        // 1. Container for images
        Item {
            id: imageContainer
            anchors.fill: parent
            visible: false

            // Primary User Avatar (Dynamic based on userList currentItem)
            Image {
                id: userAvatar
                anchors.fill: parent
                source: {
                    if (userList.currentItem) {
                        var userIcon = userList.currentItem.userIcon;
                        if (userIcon && userIcon !== "") {
                            return userIcon;
                        }
                    }
                    return "";
                }
                fillMode: Image.PreserveAspectCrop
            }

            // Fallback Default Avatar
            Image {
                id: defaultAvatar
                anchors.fill: parent
                source: Qt.resolvedUrl("default_avatar.png")
                fillMode: Image.PreserveAspectCrop
                visible: userAvatar.status !== Image.Ready
            }
        }

        // 2. The circular shape mask
        Rectangle {
            id: maskRect
            width: parent.width
            height: parent.height
            radius: width / 2
            visible: false
            layer.enabled: true
        }

        // 3. Applies the mask to make the images circular
        OpacityMask {
            anchors.fill: imageContainer
            source: imageContainer
            maskSource: maskRect
        }

        // 4. Outer Border Ring
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: root.black
            border.width: root.width * 0.001
            opacity: 0.25
        }
    }

    // Left Arrow for User Switching
    Text {
        text: "‹"
        color: root.textColor
        font.family: root.customFont
        font.pixelSize: root.height * 0.08
        anchors.right: avatarContainer.left
        anchors.rightMargin: root.height * 0.03
        anchors.verticalCenter: avatarContainer.verticalCenter
        visible: userModel && userModel.count > 1
        opacity: leftMouse.containsMouse ? 1.0 : 0.6

        MouseArea {
            id: leftMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (userModel && userModel.count > 0) {
                    currentUserIndex = (currentUserIndex - 1 + userModel.count) % userModel.count;
                    passwordInput.text = "";
                }
            }
        }
    }

    // Right Arrow for User Switching
    Text {
        text: "›"
        color: root.textColor
        font.family: root.customFont
        font.pixelSize: root.height * 0.08
        anchors.left: avatarContainer.right
        anchors.leftMargin: root.height * 0.03
        anchors.verticalCenter: avatarContainer.verticalCenter
        visible: userModel && userModel.count > 1
        opacity: rightMouse.containsMouse ? 1.0 : 0.6

        MouseArea {
            id: rightMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (userModel && userModel.count > 0) {
                    currentUserIndex = (currentUserIndex + 1) % userModel.count;
                    passwordInput.text = "";
                }
            }
        }
    }

    // Username Label Displayed Below Avatar
    Text {
        id: usernameText
        anchors.top: avatarContainer.bottom
        anchors.topMargin: root.height * 0.02
        anchors.horizontalCenter: parent.horizontalCenter

        text: {
            if (userList.currentItem) {
                var real = userList.currentItem.userRealName;
                var name = userList.currentItem.userName;
                return real !== "" ? real : name;
            }
            return "User";
        }

        color: root.textColor
        font.family: root.customFont
        font.pixelSize: root.height * 0.03
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    // Password Input Box
    TextField {
        id: passwordInput
        width: root.height * 0.3
        height: root.height * 0.075

        anchors.top: usernameText.bottom
        anchors.topMargin: root.height * 0.025
        anchors.horizontalCenter: parent.horizontalCenter

        font.family: root.customFont
        font.pixelSize: height * 0.4
        font.letterSpacing: height * 0.02
        color: root.black

        horizontalAlignment: TextInput.AlignHCenter

        echoMode: TextInput.Password
        passwordCharacter: "●"
        placeholderText: "Password..."
        selectByMouse: true

        property bool loginError: false

        Connections {
            target: sddm
            function onLoginFailed() {
                passwordInput.loginError = true;
                passwordInput.text = "";
            }
        }

        onTextChanged: {
            if (loginError) loginError = false;
        }

        background: Rectangle {
            id: inputBg
            width: parent.width
            height: parent.height
            radius: height / 2
            color: Qt.rgba(root.subtextColor.r, root.subtextColor.g, root.subtextColor.b, 0.25)

            border.color: passwordInput.loginError ? (root.red) : (passwordInput.activeFocus ? (root.accent) : (Qt.rgba(root.black.r, root.black.g, root.black.b, 0.5)))
            border.width: root.width * 0.001
        }

        onAccepted: {
            var username = userList.currentItem ? userList.currentItem.userName : "";
            sddm.login(username, passwordInput.text, 0);
        }
    }
}

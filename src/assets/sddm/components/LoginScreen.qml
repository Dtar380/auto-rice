import QtQuick

// Presentational login screen: data comes in as properties, actions go out as signals.
// It knows nothing about sddm, userModel or other files' ids.
Item {
    id: loginRoot

    // --- Inputs ---
    property Item backgroundSource          // item that GlassPanels blur (e.g. the wallpaper)
    property string userName: ""
    property string userRealName: ""
    property url userIcon
    property int userCount: 0
    property bool loginError: false

    // --- Outputs ---
    signal loginRequested(string password)
    signal previousUser()
    signal nextUser()
    signal close()

    // --- API ---
    function resetFocus() { passwordField.focusInput() }
    function showError() {
        loginError = true
        passwordField.clear()
        passwordField.focusInput()
    }
    function submit() { loginRequested(passwordField.text) }

    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            loginRoot.close();
        }
    }

    // Grab focus when shown; wipe password and error when hidden
    onEnabledChanged: {
        if (enabled) {
            resetFocus()
        } else {
            passwordField.clear()
            loginError = false
        }
    }

    UserAvatar {
        id: avatar
        width: loginRoot.height * 0.25
        height: width
        anchors.top: parent.top
        anchors.topMargin: loginRoot.height * 0.33
        anchors.horizontalCenter: parent.horizontalCenter
        source: loginRoot.userIcon
        fallback: Qt.resolvedUrl("../assets/default_avatar.png")
        ringWidth: Math.max(1, loginRoot.width * 0.001)
    }

    UserArrow {
        text: "‹"
        font.pixelSize: loginRoot.height * 0.08
        anchors.right: avatar.left
        anchors.rightMargin: loginRoot.height * 0.03
        anchors.verticalCenter: avatar.verticalCenter
        visible: loginRoot.userCount > 1
        onClicked: {
            passwordField.clear()
            loginRoot.previousUser()
        }
    }

    UserArrow {
        text: "›"
        font.pixelSize: loginRoot.height * 0.08
        anchors.left: avatar.right
        anchors.leftMargin: loginRoot.height * 0.03
        anchors.verticalCenter: avatar.verticalCenter
        visible: loginRoot.userCount > 1
        onClicked: {
            passwordField.clear()
            loginRoot.nextUser()
        }
    }

    Text {
        id: usernameText
        anchors.top: avatar.bottom
        anchors.topMargin: loginRoot.height * 0.01
        anchors.horizontalCenter: parent.horizontalCenter

        text: loginRoot.userRealName !== "" ? loginRoot.userRealName
            : loginRoot.userName !== "" ? loginRoot.userName
            : "User"

        color: Config.textColor
        font.family: Config.customFont
        font.pixelSize: loginRoot.height * 0.03
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    Row {
        id: inputRow
        width: loginRoot.height * 0.475
        height: loginRoot.height * 2 / 30
        anchors.top: usernameText.bottom
        anchors.topMargin: loginRoot.height * 0.025
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: loginRoot.height * 0.0075

        PasswordField {
            id: passwordField
            width: parent.width - parent.height - parent.spacing
            height: parent.height
            source: loginRoot.backgroundSource
            icon: Qt.resolvedUrl("../assets/icons/password.svg")
            error: loginRoot.loginError

            onEdited: loginRoot.loginError = false
            onAccepted: loginRoot.submit()
        }

        GlassButton {
            width: parent.height
            height: parent.height
            source: loginRoot.backgroundSource
            icon: Qt.resolvedUrl("../assets/icons/arrow-right.svg")
            error: loginRoot.loginError

            onClicked: loginRoot.submit()
        }
    }
}

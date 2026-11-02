import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1280
    height: 720
    color: config.background

    Image {
        id: bgImage
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        width: 360
        height: 380
        anchors.centerIn: parent
        color: config.cardBackground
        radius: 16
        border.color: config.cardBorder
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 15
            width: 280

            Text {
                text: "Welcome Back"
                color: config.textColor
                font.pixelSize: 22
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            TextBox {
                id: nameField
                width: parent.width
                height: 40
                text: userModel.lastUser
                font.pixelSize: 14

                Keys.onReturnPressed: passwordField.focus = true
            }

            PasswordBox {
                id: passwordField
                width: parent.width
                height: 40
                font.pixelSize: 14

                Keys.onReturnPressed: sddm.login(nameField.text, passwordField.text, 0)
            }

            Button {
                id: loginButton
                width: parent.width
                height: 40
                text: "Log In"
                color: config.buttonBackground
                textColor: config.buttonText
                activeColor: config.accentColor

                onClicked: sddm.login(nameField.text, passwordField.text, 0)
            }
        }
    }
}

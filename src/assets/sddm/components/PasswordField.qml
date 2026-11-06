import QtQuick

// Glass field: icon | divider | password input.
// Purely presentational: error state is driven from outside, actions go out as signals.
GlassPanel {
    id: field

    property alias text: input.text
    property url icon
    property string placeholder: "Password"
    property bool error: false
    readonly property bool inputFocused: input.activeFocus

    signal accepted()
    signal edited()      // user typed (NOT fired by clear())

    function clear() { input.text = "" }
    function focusInput() { input.forceActiveFocus() }

    borderColor: error ? Config.red
               : input.activeFocus ? Config.accent
               : Qt.rgba(Config.black.r, Config.black.g, Config.black.b, 0.5)

    Row {
        anchors.fill: parent

        // Icon
        Item {
            width: parent.height
            height: parent.height

            ColoredIcon {
                anchors.centerIn: parent
                width: parent.height * 0.4
                height: width
                source: field.icon
            }
        }

        // Divider
        Rectangle {
            width: 1
            height: parent.height
            color: field.borderColor
        }

        // Text area
        Item {
            width: parent.width - parent.height - 1
            height: parent.height

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: parent.height * 0.2
                anchors.rightMargin: parent.height * 0.2
                font.family: Config.customFont
                font.pixelSize: height * 0.35
                font.letterSpacing: 4
                color: Config.textColor
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                selectByMouse: true

                onTextEdited: field.edited()
                onAccepted: field.accepted()
            }

            Text {
                text: field.placeholder
                color: Qt.rgba(Config.textColor.r, Config.textColor.g, Config.textColor.b, 0.5)
                font.family: input.font.family
                font.pixelSize: input.font.pixelSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: parent.height * 0.2
                visible: input.text.length === 0 && !input.activeFocus
            }
        }
    }
}

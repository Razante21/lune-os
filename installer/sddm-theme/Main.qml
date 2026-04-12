// Lune OS — SDDM Theme
// Tela de login com visual Lune

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#0D0E14"

    // Fundo gradiente sutil
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0D0E14" }
            GradientStop { position: 1.0; color: "#1A1B26" }
        }
    }

    // Card central
    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: 420
        radius: 20
        color: "#1A1B2680"
        border.color: "#C8A8E940"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width - 60

            // Logo / título
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🌙"
                font.pixelSize: 48
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Lune OS"
                color: "#C8A8E9"
                font.pixelSize: 28
                font.bold: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Your world, just lighter."
                color: "#A0A0B0"
                font.pixelSize: 13
                font.italic: true
            }

            // Campo de usuário
            TextField {
                id: userField
                Layout.fillWidth: true
                placeholderText: "Usuário"
                text: userModel.lastUser
                color: "#E8E8F0"
                placeholderTextColor: "#A0A0B0"
                font.pixelSize: 14
                background: Rectangle {
                    radius: 10
                    color: "#2E2F3E"
                    border.color: userField.activeFocus ? "#C8A8E9" : "#2E2F3E"
                    border.width: 1.5
                }
                padding: 12
            }

            // Campo de senha
            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Senha"
                echoMode: TextInput.Password
                color: "#E8E8F0"
                placeholderTextColor: "#A0A0B0"
                font.pixelSize: 14
                background: Rectangle {
                    radius: 10
                    color: "#2E2F3E"
                    border.color: passwordField.activeFocus ? "#C8A8E9" : "#2E2F3E"
                    border.width: 1.5
                }
                padding: 12
                Keys.onReturnPressed: loginButton.clicked()
            }

            // Botão de login
            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "Entrar"
                font.pixelSize: 14
                font.bold: true
                contentItem: Text {
                    text: loginButton.text
                    color: "#0D0E14"
                    font: loginButton.font
                    horizontalAlignment: Text.AlignHCenter
                }
                background: Rectangle {
                    radius: 10
                    color: loginButton.pressed ? "#9B7FD4" : "#C8A8E9"
                }
                padding: 12
                onClicked: {
                    sddm.login(userField.text, passwordField.text, sessionIndex)
                }
            }

            // Mensagem de erro
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                color: "#EB5757"
                font.pixelSize: 12
                visible: false
            }
        }
    }

    // Relógio
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#A0A0B060"
        font.pixelSize: 12
        text: Qt.formatDateTime(new Date(), "hh:mm  •  dddd, dd 'de' MMMM")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm  •  dddd, dd 'de' MMMM")
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Senha incorreta"
            errorMessage.visible = true
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    Component.onCompleted: {
        passwordField.focus = true
    }
}

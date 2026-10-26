import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#160f1c"
    clip: true

    readonly property real s: Math.min(width / 1366, height / 768)
    readonly property real margin: 64 * s
    readonly property color cream: "#f4e8d4"
    readonly property color gold: "#d8b77e"
    readonly property string uiFont: mainFont.name || "Sans Serif"
    readonly property string titleFont: displayFont.name || "Serif"
    readonly property bool isQuickshell: typeof sddm === "undefined" || sddm.hostName === undefined
    readonly property bool animationsEnabled: typeof config === "undefined"
                                             || (config.enableAnimations !== false && config.enableAnimations !== "false")
    property int userIndex: typeof userModel !== "undefined" && userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property date now: new Date()
    property real reveal: 0
    property bool busy: false
    property string errorMessage: ""
    property real loginShake: 0

    FontLoader { id: mainFont; source: "font/GoogleSans-VariableFont_GRAD,opsz,wght.ttf" }
    FontLoader { id: displayFont; source: "font/Cinzel-Bold.ttf" }

    // Keep model access compatible with both SDDM and the Quickshell shim.
    ListView {
        id: userHelper
        visible: false
        width: 1; height: 1
        model: typeof userModel !== "undefined" ? userModel : null
        currentIndex: root.userIndex
        delegate: Item {
            property string displayName: model.realName || model.name || ""
            property string loginName: model.name || ""
        }
    }
    ListView {
        id: sessionHelper
        visible: false
        width: 1; height: 1
        model: typeof sessionModel !== "undefined" ? sessionModel : null
        currentIndex: root.sessionIndex
        delegate: Item { property string sessionName: model.name || "" }
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }
    Timer { interval: 300; running: true; onTriggered: password.forceActiveFocus() }
    Component.onCompleted: {
        if (animationsEnabled) entrance.start()
        else reveal = 1
    }
    onAnimationsEnabledChanged: {
        if (!animationsEnabled) {
            entrance.stop()
            loginFeedback.stop()
            reveal = 1
            loginShake = 0
        }
    }
    NumberAnimation {
        id: entrance
        target: root; property: "reveal"
        from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic
    }

    BackgroundScene {
        id: backgroundScene
        anchors.fill: parent
        source: typeof config !== "undefined" && config.background
                ? config.background : "witch-of-the-sun-proportions-4k.png"
        animated: root.animationsEnabled
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.ArrowCursor
        onClicked: password.forceActiveFocus()
    }

    Row {
        anchors { left: parent.left; top: parent.top; margins: root.margin }
        spacing: 12 * root.s
        opacity: root.reveal
        transform: Translate { y: (1 - root.reveal) * -12 * root.s }
        SunEmblem {
            width: 28 * root.s; height: width
            ink: root.gold
            animated: root.animationsEnabled
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "THE WITCH OF THE SUN"
            font.family: root.uiFont; font.pixelSize: 10 * root.s
            font.letterSpacing: 2.4 * root.s
            color: root.gold
        }
    }

    Column {
        anchors { right: parent.right; top: parent.top; margins: root.margin }
        width: 310 * root.s
        spacing: 2 * root.s
        opacity: root.reveal
        transform: Translate { y: (1 - root.reveal) * -18 * root.s }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: Qt.formatTime(root.now, "HH:mm")
            color: root.cream
            font.family: root.titleFont; font.pixelSize: 60 * root.s
            font.letterSpacing: -1 * root.s
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: Qt.formatDate(root.now, "dddd, d. MMMM")
            color: root.gold
            font.family: root.uiFont; font.pixelSize: 12 * root.s
            font.letterSpacing: 1.2 * root.s
        }
    }

    Column {
        id: login
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: root.margin }
        anchors.verticalCenterOffset: 90 * root.s
        width: 310 * root.s
        spacing: 14 * root.s
        opacity: root.reveal
        transform: Translate { x: (1 - root.reveal) * 18 * root.s + root.loginShake }

        Row {
            spacing: 10 * root.s
            SunEmblem { width: 22 * root.s; height: width; ink: root.gold }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Welcome back")
                color: root.cream
                font.family: root.titleFont; font.pixelSize: 19 * root.s
                font.letterSpacing: 1 * root.s
            }
        }
        ActionButton {
            id: userButton
            width: parent.width
            unit: root.s; font.family: root.uiFont
            motionEnabled: root.animationsEnabled
            text: (userHelper.currentItem && userHelper.currentItem.displayName)
                  ? userHelper.currentItem.displayName
                  : (typeof userModel !== "undefined" && userModel.lastUser ? userModel.lastUser : qsTr("User"))
            enabled: !root.busy && !root.isQuickshell && root.modelCount(userHelper.model) > 1
            // A single user is still displayed at full contrast.
            opacity: 1
            onClicked: {
                root.userIndex = (root.userIndex + 1) % root.modelCount(userHelper.model)
                password.clear()
                root.errorMessage = ""
                password.forceActiveFocus()
            }
        }
        TextField {
            id: password
            width: parent.width; height: 48 * root.s
            enabled: !root.busy
            focus: true
            font.family: root.uiFont; font.pixelSize: 15 * root.s
            color: root.cream
            placeholderText: qsTr("Password")
            placeholderTextColor: "#bcaeb8"
            echoMode: TextInput.Password
            passwordCharacter: "•"
            selectByMouse: true
            selectionColor: "#70444c"
            selectedTextColor: root.cream
            leftPadding: 14 * root.s; rightPadding: 14 * root.s
            background: Rectangle {
                color: "#a0201728"
                radius: 2 * root.s
                border.width: 1
                border.color: root.errorMessage ? "#f4a6a0" : password.activeFocus ? root.gold : "#65d8b77e"
                Behavior on border.color {
                    enabled: root.animationsEnabled
                    ColorAnimation { duration: 180 }
                }
            }
            onAccepted: root.doLogin()
            onTextEdited: root.errorMessage = ""
            Keys.onEscapePressed: { clear(); root.errorMessage = "" }
        }
        ActionButton {
            width: parent.width; implicitHeight: 44 * root.s
            unit: root.s; font.family: root.uiFont
            motionEnabled: root.animationsEnabled
            primary: true
            text: root.busy ? qsTr("Signing in…") : root.isQuickshell ? qsTr("Unlock  →") : qsTr("Sign in  →")
            enabled: !root.busy
            onClicked: root.doLogin()
        }
        Text {
            width: parent.width; height: 30 * root.s
            text: root.errorMessage
            color: "#ffb6a6"
            font.family: root.uiFont; font.pixelSize: 12 * root.s
            wrapMode: Text.WordWrap
            Accessible.role: Accessible.StaticText
            Accessible.name: text
        }
    }

    Column {
        anchors { right: parent.right; bottom: parent.bottom; margins: root.margin }
        width: 310 * root.s
        spacing: 12 * root.s
        opacity: root.reveal
        transform: Translate { y: (1 - root.reveal) * 18 * root.s }

        ActionButton {
            width: parent.width
            visible: !root.isQuickshell
            unit: root.s; font.family: root.uiFont
            motionEnabled: root.animationsEnabled
            text: qsTr("Session: %1").arg(sessionHelper.currentItem ? sessionHelper.currentItem.sessionName : qsTr("Default"))
            enabled: !root.busy && root.modelCount(sessionHelper.model) > 1
            opacity: 1
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % root.modelCount(sessionHelper.model)
        }
        Row {
            width: parent.width
            spacing: 10 * root.s
            ActionButton {
                width: (parent.width - parent.spacing) / 2
                unit: root.s; font.family: root.uiFont
                motionEnabled: root.animationsEnabled
                text: qsTr("Restart")
                enabled: !root.busy && typeof sddm !== "undefined" && (sddm.canReboot === undefined || sddm.canReboot)
                onClicked: sddm.reboot()
            }
            ActionButton {
                width: (parent.width - parent.spacing) / 2
                unit: root.s; font.family: root.uiFont
                motionEnabled: root.animationsEnabled
                text: qsTr("Shut down")
                enabled: !root.busy && typeof sddm !== "undefined" && (sddm.canPowerOff === undefined || sddm.canPowerOff)
                onClicked: sddm.powerOff()
            }
        }
    }

    Connections {
        target: typeof sddm !== "undefined" ? sddm : null
        function onLoginFailed() {
            root.busy = false
            root.errorMessage = qsTr("Authentication failed. Please try again.")
            password.clear()
            password.forceActiveFocus()
            if (root.animationsEnabled) loginFeedback.restart()
        }
        function onLoginSucceeded() { password.clear() }
    }

    SequentialAnimation {
        id: loginFeedback
        NumberAnimation { target: root; property: "loginShake"; to: -7 * root.s; duration: 65; easing.type: Easing.OutSine }
        NumberAnimation { target: root; property: "loginShake"; to: 7 * root.s; duration: 90; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "loginShake"; to: -4 * root.s; duration: 80; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "loginShake"; to: 0; duration: 100; easing.type: Easing.OutSine }
    }

    function modelCount(model) {
        if (!model) return 0
        return typeof model.rowCount === "function" ? model.rowCount() : (model.count || 0)
    }

    function doLogin() {
        if (busy || typeof sddm === "undefined") return
        var user = userHelper.currentItem ? userHelper.currentItem.loginName
                   : (typeof userModel !== "undefined" ? userModel.lastUser : "")
        if (!user) return
        busy = true
        errorMessage = ""
        sddm.login(user, password.text, sessionIndex)
    }
}

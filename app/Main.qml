import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Window 2.2
import Morph.Web 0.1
import QtWebEngine 1.7
import "UCSComponents"
import Qt.labs.settings 1.0
import QtSystemInfo 5.5

MainView {
    id:window

    objectName: "mainView"
    theme.name: "Ubuntu.Components.Themes.SuruDark"

    applicationName: "youtube-web.mateo-salta"
    backgroundColor : theme.palette.normal.background

    property bool loaded: false

    WebView {
        id: webview
        anchors.fill: parent

        enableSelectOverride: true

        settings.fullScreenSupportEnabled: true
        property var currentWebview: webview
        settings.pluginsEnabled: true

        backgroundColor: theme.palette.normal.background

        onFullScreenRequested: function(request) {
            nav.visible = !nav.visible

            request.accept();
        }

        profile:  WebEngineProfile{
            id: webContext
            persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
            property alias dataPath: webContext.persistentStoragePath

            dataPath: dataLocation
            //enable to store cookie
            offTheRecord: false

            httpUserAgent: "Mozilla/5.0 (Linux; Android 8.0.0; Pixel Build/OPR3.170623.007) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.98 Mobile Safari/537.36"
        }

        url: "https://www.youtube.com"
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentReady
                worldId: WebEngineScript.ApplicationWorld
                sourceUrl: "ubuntutheme.js"
            }
        ]

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                window.loaded = true
            }
        }
    }

    RadialBottomEdge {
        id: nav
        visible: window.loaded
        actions: [
            RadialAction {
                id: reload
                iconName: "reload"
                onTriggered: {
                    webview.reload()
                }
                text: qsTr("Reload")
            },

            RadialAction {
                id: forward
                enabled: webview.canGoForward
                iconName: "go-next"
                onTriggered: {
                    webview.goForward()
                }
                text: qsTr("Forward")
            },
            RadialAction {
                id: account
                iconName: "account"
                onTriggered: {
                    webview.url = 'https://m.youtube.com/feed/account'
                }
                text: qsTr("Account")

            },
            RadialAction {
                id: subscriptions
                iconName: "media-playlist"
                onTriggered: {
                    webview.url = 'https://m.youtube.com/feed/subscriptions'
                }
                text: qsTr("Subscriptions")

            },
            RadialAction {
                id: trending
                iconName: "weather-chance-of-storm"
                onTriggered: {
                    webview.url = 'https://m.youtube.com/feed/trending'
                }
                text: qsTr("Trending")
            },

            RadialAction {
                id: home
                iconName: "home"
                onTriggered: {
                    webview.url = 'http://m.youtube.com'
                }
                text: qsTr("Home")
            },

            RadialAction {
                id: back
                enabled: webview.canGoBack
                iconName: "go-previous"
                onTriggered: {
                    webview.goBack()
                }
                text: qsTr("Back")
            }
        ]
    }
    
    Rectangle {
        id: splashScreen
        color: theme.palette.normal.background
        anchors.fill: parent

        ActivityIndicator{
            id:loadingflg
            anchors.centerIn: parent

            running: splashScreen.visible
        }

        states: [
            State { when: !window.loaded;
                PropertyChanges { target: splashScreen; opacity: 1.0 }
            },
            State { when: window.loaded;
                PropertyChanges { target: splashScreen; opacity: 0.0 }
            }
        ]

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 400}
        }

    }

    Connections {
        target: Qt.inputMethod
        onVisibleChanged: nav.visible = !nav.visible
    }
    
    Connections {
        target: webview

        onIsFullScreenChanged: {
            console.log('onIsFullScreenChanged:')
            window.setFullscreen()
            if (currentWebview.isFullScreen) {

                nav.state = "hidden"
            }
            else {

                nav.state = "shown"
            }
        }
    }


    Connections {
        target: UriHandler

        onOpened: {

            if (uris.length > 0) {
                console.log('Incoming call from UriHandler ' + uris[0]);
                webview.url = uris[0];
            }
        }
    }

    Component.onCompleted: {
        //Check if opened the app because we have an incoming call
        if (Qt.application.arguments && Qt.application.arguments.length > 0) {
            for (var i = 0; i < Qt.application.arguments.length; i++) {
                if (Qt.application.arguments[i].match(/^http/)) {
                    console.log(' open video to:', Qt.application.arguments[i])
                    webview.url = Qt.application.arguments[i];
                }
                //}
            }
        }
    }


    function setFullscreen(fullscreen) {
        if (!window.forceFullscreen) {
            if (fullscreen) {
                if (window.visibility != Window.FullScreen) {
                    console.log('hello fullscreen')
                    internal.currentWindowState = window.visibility
                    window.visibility = 5
                }
            } else {
                console.log('hello fullscreen', fullscreen)
                window.visibility = internal.currentWindowState
                //window.currentWebview.fullscreen = false
                //window.currentWebview.fullscreen = false
            }
        }
    }

}

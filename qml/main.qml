import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    visible: true
    width: Screen.width
    height: Screen.height
    visibility: Window.FullScreen
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint


    color: "transparent"
    background: Rectangle {
        color: "black"
        opacity: 0.666
    }

    id: rootWindow
    property int columns: 6

    header: ToolBar {
        height: rootWindow.height * 0.1
        background: Rectangle { color: "transparent" }

        TextField {
            id: searchField
            text: ""
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            width: rootWindow.width * 0.16
            onTextEdited: refresh()

            Keys.onEscapePressed: Qt.quit()
            Keys.onDownPressed: swipeView.forceActiveFocus()
            onAccepted: {
                var app = swipeView.currentItem.page[0]
                if (app) {
                    exec(app[2])
                }
            }
        }
    }

    property var appPages: []

    function filter(app, q) {
        for (var i in app) {
            if (app[i].trim().toLowerCase().indexOf(q) > -1) {
                return true;
            }
        }
        return false;
    }

    function refresh() {
        var page = 0
        var itemsPerPage = 24
        console.log(searchField.text)
        appPages = [];
        appPages[page] = []

        pageRepeater.model = 0

        for (var i in apps) {
            if (appPages[page].length >= itemsPerPage)
                page++

            if (!appPages[page])
                appPages[page] = []

            var app = apps[i]
            if (filter(app, searchField.text))
                appPages[page].push(app)
        }

        pageRepeater.model = appPages.length
    }

    Component.onCompleted: {
        x = Qt.application.screens[0].virtualX
        refresh()
        searchField.forceActiveFocus()
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        focus: true

        property int selectedIndex: 0

        function select(index) {
            selectedIndex = index
        }

        Keys.onEscapePressed: Qt.quit()

        Keys.onUpPressed: {
            var place = selectedIndex - rootWindow.columns
            if (place >= 0)
                selectedIndex = place
        }

        Keys.onDownPressed: {
            var place = selectedIndex + rootWindow.columns
            if (place < currentItem.count())
                selectedIndex = place
        }

        Keys.onRightPressed: {
            selectedIndex = Math.min(selectedIndex + 1, currentItem.count() - 1)
        }

        Keys.onLeftPressed: {
            selectedIndex = Math.max(0, selectedIndex - 1)
        }

        Keys.onReturnPressed: {
            var app = appPages[currentIndex][selectedIndex]
            if (app) {
                exec(app[2])
            }
        }

        onFocusChanged: {
            if (focus) {
                select(0)
            }
        }

        Repeater {
            id: pageRepeater
            model: appPages.length

            Item {
                id: pageContainer
                function count() {
                    return page.length;
                }

                property var page: appPages[index]

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }

                Grid {
                    spacing: rootWindow.height * 0.01
                    anchors.centerIn: parent
                    columns: rootWindow.columns
                    horizontalItemAlignment: Grid.AlignHCenter

                    populate: Transition {
                        id: trans
                        SequentialAnimation {
                            NumberAnimation {
                                properties: "opacity"
                                from: 1
                                to: 0
                                duration: 0
                            }
                            PauseAnimation {
                                duration: (trans.ViewTransition.index -
                                           trans.ViewTransition.targetIndexes[0]) * 20
                            }
                            ParallelAnimation {
                                NumberAnimation {
                                    properties: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 600
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    properties: "y"
                                    from: trans.ViewTransition.destination.y + 50
                                    duration: 620
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Repeater {
                        model: page !== undefined ? page.length : 0

                        AppEntry {
                            app: page !== undefined ? page[index] : ["undefined", "", ""]
                            height: pageContainer.height * 0.19
                            width: height
                            padding: 10
                            selected: swipeView.selectedIndex === index
                        }
                    }
                }
            }
        }
    }

    function exec(program) {
        console.debug("Exec: " + program)
        proc.start(program)
        Qt.quit()
    }

    footer: ToolBar {
        background: Rectangle { color: "transparent" }
        height: rootWindow.height * 0.05

        PageIndicator {
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            anchors.centerIn: parent
        }
    }
}

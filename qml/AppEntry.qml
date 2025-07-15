import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3


Pane {
    id: root
    property var app
    property bool selected: false
    background: Rectangle {
        visible: selected
        radius: height * 0.04
        opacity: 0.5
        color: "black"
    }

    onHoveredChanged: if (hovered) root.parent.swipeView.select(index)
    onClicked: root.parent.exec(app[2])

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Column {
        anchors.fill: parent

        Image {
            source: "image://icons/" + app[1]
            height: parent.height - label.height
            width: height
            sourceSize.height: height
            sourceSize.width: width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: label
            text: app[0]
            width: parent.width
            fontSizeMode: Text.Fit
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            //height: 28
        }
    }
}

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {

    Layout.minimumWidth: 60

    Rectangle {
        id: background
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 5
        height: parent.height - 5
        color: "#FFFFFF"
    }

    Rectangle {
        id: notch
        anchors.verticalCenter: background.verticalCenter
        width: parent.width
        height: parent.height / 2
        color: "#FFFFFF"
        y: (parent.height / 2) - (height / 2)
    }

    Rectangle {
        id: backdrop
        anchors.verticalCenter: background.verticalCenter
        width: background.width - 6
        height: background.height - 6
        color: "#000000"
        x: 3
        y: 3
    }

    Rectangle {
        id: fill
        anchors.verticalCenter: background.verticalCenter
        anchors.left: backdrop.left
        width: 0
        height: backdrop.height
        color: "#139948"
    }

    Label {
        id: perc
        text: "---"
        color: "#FFFFFF"
        anchors.verticalCenter: fill.verticalCenter
        anchors.horizontalCenter: fill.horizontalCenter
        font.pixelSize: 14
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: function() {

            /**
              * This is a helper function for obtaining files from disk
              */
            var getFile = function(path, callback, error) {
                var a = new XMLHttpRequest()
                a.onreadystatechange = function() {
                    if (a.readyState == XMLHttpRequest.DONE) {
                        if (a.status == 200) {
                            callback(a.responseText);
                        } else {
                            error();
                        }
                    }
                }
                a.open("GET", path);
                a.send();
            }

            var setPercentage = function(value) {
                if (value == 0) {
                    perc.text = "---";
                    fill.width = 0;
                    return;
                }
                perc.text = value + "%";
                fill.width = backdrop.width * (value / 100);
                if (value < 20) {
                    fill.color = "#f4c711";
                } else {
                    fill.color = "#139948";
                }
            }

            /* First fetch the primary battery capacity */
            getFile("/sys/class/power_supply/BAT0/capacity", function(data) {
                var primaryPerc = parseInt(data.replace("\n", ""));
                getFile("/sys/class/power_supply/BAT1/capacity", function(data) {
                    var secondaryPerc = parseInt(data.replace("\n", ""));
                    setPercentage((primaryPerc + secondaryPerc) / 200 * 100);
                }, function() {
                    setPercentage(primaryPerc);
                });
            }, function() {
                perc.text = "---";
                fill.width = 0;
            });

        }
    }

}

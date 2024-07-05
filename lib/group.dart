import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/createuser.dart';
import 'package:ntu_fyp_chatalone/group_chat.dart';
import 'chat.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({required this.mydata});
  final String mydata;

  @override
  GroupListScreenState createState() => GroupListScreenState();
}

class GroupListScreenState extends State<GroupListScreen> {
  String groupname = "";
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late Chat activity;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController txtController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 17, 20, 17),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          children: [
            SizedBox(width: 40),
            Text(
              "Group Chat",
              style: TextStyle(fontFamily: 'RobotoMono'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                          child: GestureDetector(
                        child: Column(
                          textDirection: TextDirection.ltr,
                          children: [
                            SizedBox(height: 9.0),
                            Text(
                              device.deviceName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RobotoMono'),
                            ),
                            Text(
                              getStateName(device.state),
                              style:
                                  TextStyle(color: getStateColor(device.state)),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      )),
                      // Request connection
                      GestureDetector(
                        onTap: () => _onButtonClicked(device),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          height: 40,
                          width: 40,
                          color: getButtonColor(device.state),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Icon(
                                  getButtonStateIcon(device.state),
                                  color: Colors.white,
                                )
                              ]),
                        ),
                      ),
                      SizedBox.fromSize(
                        size: Size(40, 40), // button width and height
                        // child: ClipOval(
                        child: Material(
                          color: Colors.blue, // button color
                          child: InkWell(
                            // splash color
                            onTap: () {
                              if (device.state == SessionState.connected) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(" Connected"),
                                  backgroundColor: Colors.green,
                                ));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupChat(
                                            myName: this.widget.mydata,
                                            connected_device: connectedDevices,
                                            nearbyService: nearbyService,
                                            groupName: groupname,
                                          )),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Disconnected "),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }, // button pressed
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                ), // icon
                              ],
                            ),
                          ),
                        ),
                        // ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  )
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text("Create Group"),
                    content: TextFormField(
                        controller: txtController,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Enter New Name')),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          nearbyService.init(
                              serviceType: 'mpconn',
                              deviceName: txtController.text,
                              strategy: Strategy.P2P_CLUSTER,
                              callback: (isRunning) async {
                                if (isRunning) {
                                  await nearbyService.stopAdvertisingPeer();
                                  await nearbyService.stopBrowsingForPeers();
                                  nearbyService.startAdvertisingPeer();
                                  nearbyService.startBrowsingForPeers();
                                }
                              });
                          groupname = txtController.text;
                          Navigator.pop(context, 'Confirm');
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ));
        },
        icon: const Icon(
          Icons.add,
          color: Colors.black87,
        ),
        label: const Text(
          'Create Group',
          style: TextStyle(fontFamily: 'RobotoMono', color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "Disconnected";
      case SessionState.connecting:
        return "Connecting";
      default:
        return "Connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "Connect";
      case SessionState.connecting:
        return "Connecting";
      default:
        return "Disconnect";
    }
  }

  IconData getButtonStateIcon(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Icons.link;
      case SessionState.connecting:
        return Icons.autorenew;
      default:
        return Icons.link_off;
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.red;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.green;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: txtController.text,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
    nearbyService = NearbyService();
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          }
        }
      });
      setState(() {
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });
  }
}

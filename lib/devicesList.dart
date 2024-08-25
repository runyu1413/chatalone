import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/mesh_chat.dart';
import 'chat.dart';

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.mydata});
  final String mydata;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        centerTitle: true,
        title: Row(
          children: [
            SizedBox(width: 40),
            Text(
              "Finding nearby devices",
              style: textTheme.headline6?.copyWith(fontFamily: 'RobotoMono'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: theme.bottomAppBarColor,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeshChat(
                myName: widget.mydata,
                connected_device: connectedDevices,
                nearbyService: nearbyService,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 7.5),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.chat_bubble,
                  color: theme.iconTheme.color,
                ),
                Text(
                  'Mesh Chat',
                  style: textTheme.button?.copyWith(fontFamily: 'RobotoMono'),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 9.0),
                            Text(
                              device.deviceName,
                              style: textTheme.bodyText1?.copyWith(
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                            Text(
                              getStateName(device.state),
                              style: textTheme.bodyText2?.copyWith(
                                color: getStateColor(device.state, theme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onButtonClicked(device),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: getButtonColor(device.state, theme),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          getButtonStateIcon(device.state),
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                    SizedBox.fromSize(
                      size: Size(40, 40),
                      child: Material(
                        color: theme.primaryColor,
                        child: InkWell(
                          onTap: () {
                            if (device.state == SessionState.connected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Connected"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Chat(
                                    connected_device: device,
                                    nearbyService: nearbyService,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Disconnected"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.chat,
                                  color: theme.colorScheme.onPrimary),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8.0),
                Divider(
                  height: 1,
                  color: theme.dividerColor,
                ),
              ],
            ),
          );
        },
      ),
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

  Color getStateColor(SessionState state, ThemeData theme) {
    switch (state) {
      case SessionState.notConnected:
        return theme.errorColor;
      case SessionState.connecting:
        return theme.disabledColor;
      default:
        return theme.colorScheme.secondary;
    }
  }

  Color getButtonColor(SessionState state, ThemeData theme) {
    switch (state) {
      case SessionState.notConnected:
        return theme.colorScheme.secondary;
      case SessionState.connecting:
        return theme.disabledColor;
      default:
        return theme.errorColor;
    }
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: widget.mydata,
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
    await nearbyService.init(
      serviceType: 'mpconn',
      deviceName: widget.mydata,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {
        if (isRunning) {
          await nearbyService.stopAdvertisingPeer();
          await nearbyService.stopBrowsingForPeers();
          nearbyService.startAdvertisingPeer();
          nearbyService.startBrowsingForPeers();
        }
      },
    );
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

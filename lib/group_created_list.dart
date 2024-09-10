import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'group_chat_creator.dart';
import 'chat.dart';

class GroupCreatedScreen extends StatefulWidget {
  const GroupCreatedScreen({required this.mydata, required this.groupName});
  final String mydata;
  final String groupName;

  @override
  _GroupCreatedScreenState createState() => _GroupCreatedScreenState();
}

class _GroupCreatedScreenState extends State<GroupCreatedScreen> {
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
        title: Text(
          "Nearby Person",
          style: textTheme.titleLarge?.copyWith(fontFamily: 'RobotoMono'),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'RobotoMono',
                                    ),
                                  ),
                                  Text(
                                    getStateName(device.state),
                                    style: textTheme.bodyMedium?.copyWith(
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
          ),
          if (connectedDevices.isNotEmpty)
            Container(
              margin: EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatCreator(
                        connectedDevices: devices,
                        nearbyService: nearbyService,
                        myName: widget.mydata,
                        groupName: widget.groupName,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.chat),
                label: Text('Start Chat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width button
                ),
              ),
            ),
        ],
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
        return theme.colorScheme.error;
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
        return theme.colorScheme.error;
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
      deviceName: 'group:${widget.groupName}',
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
        devices.addAll(devicesList
            .where((d) => d.deviceName.contains('joining:'))
            .map((d) {
          d.deviceName = d.deviceName.replaceAll('joining:', '');
          return d;
        }).toList());
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });
  }
}

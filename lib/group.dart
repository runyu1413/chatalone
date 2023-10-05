import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/mesh_chat.dart';
import 'chat.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({required this.mydata});
  final String mydata;

  @override
  GroupListScreenState createState() => GroupListScreenState();
}
class GroupListScreenState extends State<GroupListScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 17, 20, 17),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            children: [
              SizedBox(width: 40),
              Text("Group Chat",style: TextStyle(fontFamily: 'RobotoMono'),),
            ],
          ),
        )
    );
  }
}
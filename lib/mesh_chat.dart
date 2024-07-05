import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/createuser.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:image_picker/image_picker.dart';

class MeshChat extends StatefulWidget {
  List<Device> connected_device;
  NearbyService nearbyService;
  String myName;
  var chat_state;
  MeshChat(
      {required this.myName,
      required this.connected_device,
      required this.nearbyService});

  @override
  State<StatefulWidget> createState() => _MeshChat();
}

class _MeshChat extends State<MeshChat> {
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  final filter = ProfanityFilter();
  List<ChatMessage> messages = [];
  final myController = TextEditingController();
  File? imageFile;
  String? imagebase64;
  final ImagePicker picker = ImagePicker();
  void addMessgeToList(ChatMessage obj) {
    setState(() {
      messages.insert(0, obj);
    });
  }

  void encodeImageBase64() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    Uint8List imagebyte = await image.readAsBytes();
    String base = base64Encode(imagebyte);
    final imagepath = File(image.path);
    for (Device device in this.widget.connected_device) {
      this.widget.nearbyService.sendMessage(device.deviceId, "image|" + base);
      var obj = ChatMessage(
          from: this.widget.myName,
          messageContent: base,
          messageType: "sender",
          messageFormat: "image");
      addMessgeToList(obj);
    }
    setState(() {
      imageFile = imagepath;
      imagebase64 = base;
      //myController.text=base;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    receivedDataSubscription.cancel();
  }

  void init() {
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      for (Device device in this.widget.connected_device) {
        var obj = ChatMessage(
            from: device.deviceName,
            messageContent: splited[1],
            messageType: "receiver",
            messageFormat: splited[0]);
        addMessgeToList(obj);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Mesh Chat",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'RobotoMono',
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              return Container(
                padding:
                    EdgeInsets.only(left: 10, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "receiver"
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType == "receiver"
                          ? Colors.grey.shade200
                          : Colors.green[200]),
                    ),
                    padding: EdgeInsets.all(16),
                    child: (messages[index].messageFormat == "image"
                        ? Card(
                            child: ListTile(
                              title: Text(
                                messages[index].from,
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Image.memory(
                                  base64Decode(messages[index].messageContent)),
                            ),
                          )
                        : Card(
                            child: ListTile(
                              title: Text(
                                messages[index].from,
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: Text(
                                messages[index].messageContent,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          )),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        } else if (filter.hasProfanity(value)) {
                          return 'User contain profanity';
                        }
                        return null;
                      },
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'RobotoMono'),
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: "Enter your message...",
                        hintStyle: TextStyle(
                            color: Colors.white, fontFamily: 'RobotoMono'),
                        hintTextDirection: TextDirection.ltr,
                        border: InputBorder.none,
                      ),
                      controller: myController,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                    onPressed: () {
                      encodeImageBase64();
                    },
                    icon: Icon(
                      Icons.file_upload,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("press");
                      if (txtController.text == null ||
                          txtController.text.isEmpty) {
                        print(1);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter a username")));
                      } else if (filter.hasProfanity(txtController.text)) {
                        print(2);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please do not enter profanity")));
                      } else {
                        print(3);
                        this.widget.nearbyService.sendMessage(
                            "device.deviceId", "message|" + myController.text);
                        var obj = ChatMessage(
                            from: this.widget.myName,
                            messageContent: myController.text,
                            messageType: "sender",
                            messageFormat: "message");
                        addMessgeToList(obj);
                        myController.text = "";
                        /*
                        for (Device device in this.widget.connected_device) {
                          print(4);
                          this.widget.nearbyService.sendMessage(
                              device.deviceId, "message|" + myController.text);
                          var obj = ChatMessage(
                              from: this.widget.myName,
                              messageContent: myController.text,
                              messageType: "sender",
                              messageFormat: "message");
                          addMessgeToList(obj);
                          myController.text = "";
                        }
                        */
                      }
                    },
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                      textDirection: TextDirection.ltr,
                    ),
                    backgroundColor: Colors.green[600],
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  String from;
  String messageContent;
  String messageType;
  String messageFormat;
  ChatMessage(
      {required this.from,
      required this.messageContent,
      required this.messageType,
      required this.messageFormat});
}

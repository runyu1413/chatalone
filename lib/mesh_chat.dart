import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:profanity_filter/profanity_filter.dart';


class MeshChat extends StatefulWidget{
  List<Device> connected_device;
  NearbyService nearbyService;
  String myName;
  var chat_state;
  MeshChat({ required this.myName,required this.connected_device, required this.nearbyService});


  @override
  State<StatefulWidget> createState()  => _MeshChat();

}
class _MeshChat extends State<MeshChat>{
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  final filter = ProfanityFilter();
  List<ChatMessage> messages = [];
  final myController = TextEditingController();
  void addMessgeToList(ChatMessage  obj){

    setState(() {
      messages.insert(0, obj);
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    receivedDataSubscription.cancel();
  }
  void init(){
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
          for (Device device in this.widget.connected_device){
            var obj = ChatMessage(from:device.deviceName,messageContent: data["message"], messageType: "receiver");
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
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.white,),
                ),

                SizedBox(width: 13,),
                Expanded(
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 6,),
                      Text("Mesh Chat",style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w500,fontFamily:'RobotoMono' , color: Colors.white),),
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
            padding: EdgeInsets.only(top: 10,bottom: 10),
            itemBuilder: (context, index){
              return Container(
                padding: EdgeInsets.only(left: 10,right: 14,top: 10,bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.green[200]),
                    ),
                    padding: EdgeInsets.all(16),
                    child:(messages[index].messageType  == "receiver"? 
                    Card(child: ListTile(title: Text(messages[index].from, style: TextStyle(fontSize: 15),), subtitle:Text(messages[index].messageContent, style: TextStyle(fontSize: 15),) ,),):
                     Text(messages[index].messageContent, style: TextStyle(fontSize: 15),)),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextFormField(
                      validator: (value){
                        if (value == null|| value.isEmpty){
                          return 'Please enter a message';
                        }else if (filter.hasProfanity(value)){
                          return 'User contain profanity';
                          }
                          return null;
                      },
                      style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: "Enter your message...",
                        hintStyle: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
                        hintTextDirection: TextDirection.ltr,
                        border: InputBorder.none,
                      ),
                      controller: myController,
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: (){
                        for(Device device in this.widget.connected_device){
                            this.widget.nearbyService.sendMessage(
                            device.deviceId, myController.text);
                            var obj = ChatMessage(from:this.widget.myName ,messageContent: myController.text, messageType: "sender");
                            addMessgeToList(obj);
                            myController.text = "";
                        }
                    },
                    child: Icon(Icons.play_circle_outline_rounded,color: Colors.white,size: 18,textDirection: TextDirection.ltr,),
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

class ChatMessage{
  String from;
  String messageContent;
  String messageType;
  ChatMessage({ required this.from, required this.messageContent,  required this.messageType});
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:ntu_fyp_chatalone/main.dart';
import 'package:ntu_fyp_chatalone/model/user_model.dart';

TextEditingController txtController = TextEditingController();
class CreateUser extends StatelessWidget {
  final filter = ProfanityFilter();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 17, 20, 17),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(width: 150),
              Text("Chatalone" ,
                  style: TextStyle(
                      color: Colors.white,
                      //fontSize: 15,
                      fontFamily: 'RobotoMono')),
            ],
          ),
        ),
      body: Column(
        children: [const SizedBox(width: 50,height: 50),
          Image.asset("image/live-chat.png",height: 100,width: 100),Container(padding: EdgeInsets.all(20.0),child:Center( 
          child:TextFormField(
          validator:(value){
            if (value == null|| value.isEmpty){
              return 'Please enter a username';
            }else if (filter.hasProfanity(value)){
              return 'User contain profanity';
            }
             return null;
          },
          style: TextStyle(color: Colors.black),
            controller: txtController,decoration: InputDecoration(filled: true,fillColor: Colors.white,labelText: 'Enter Username'),
          ),)),
          UserButton(), 
      ],
      ),
    );
  }

}
class UserButton extends StatefulWidget{
  const UserButton({super.key});
  @override
  UserButtonState createState () => new UserButtonState();
}
class UserButtonState extends State<UserButton>{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('home',arguments: txtController.text), 
          child: Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color:Color.fromARGB(255, 95, 150, 96)),child: const Text('Confirm'),), 
    );
  }
}
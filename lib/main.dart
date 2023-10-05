import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/createuser.dart';
import 'package:ntu_fyp_chatalone/model/user_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'devicesList.dart';
import 'home.dart';

void main() async{
  await Hive.initFlutter();
  Hive.registerAdapter(UsersAdapter());
  await Hive.openBox<Users>('Username');
  runApp(MyApp());
}
Route<dynamic> generateRoute(RouteSettings settings) {
  final userBox = Hive.box<Users>('Username');
    //String user = "Testing";
    switch (settings.name) {
    case '/':
   final String? user = userBox.get('Username')?.username;
    if(user != null){
            return MaterialPageRoute(
        builder:  (context) => Home(name: user)
        );
    }
    else{      
    return MaterialPageRoute(builder: (_) => CreateUser());
    }
    case 'home':
      final usern= settings.arguments as String;
      var device = Users(username: usern);
      userBox.add(device);
      return MaterialPageRoute(
        builder:  (context) => Home(name: usern,)
        );
    case 'start':
      final name= settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => DevicesListScreen(mydata: name));
    case 'group':
      
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      onGenerateRoute:generateRoute,
      initialRoute: '/', debugShowCheckedModeBanner: false,
    );
  }
}
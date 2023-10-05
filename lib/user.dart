import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

 @HiveType()
 class User extends HiveObject{
   @HiveField(0)
   String username;

   User({
     required this.username,
   });
 }
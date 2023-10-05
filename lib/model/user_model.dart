import 'package:hive/hive.dart';

part 'user_model.g.dart';
@HiveType(typeId:0)
class Users{
  @HiveField(0)
  String username;

  Users({ required this.username});
}
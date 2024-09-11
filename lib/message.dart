import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

class ChatMessage {
  int? id;
  String chatId;
  String messageContent;
  String messageType;
  String messageFormat;
  bool isEdited;
  String? reaction;
  bool autoDelete;
  int? timeRemaining;
  DateTime timestamp;
  ChatMessage? replyTo;
  Uint8List? imageData;
  Timer? timer;
  String personName;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.messageContent,
    required this.messageType,
    required this.messageFormat,
    required this.timestamp,
    required this.personName,
    this.isEdited = false,
    this.reaction,
    this.autoDelete = false,
    this.timeRemaining,
    this.replyTo,
    this.imageData,
    this.timer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'messageContent': messageContent,
      'messageType': messageType,
      'messageFormat': messageFormat,
      'personName': personName,
      'isEdited': isEdited ? 1 : 0,
      'reaction': reaction,
      'autoDelete': autoDelete ? 1 : 0,
      'timeRemaining': timeRemaining,
      'timestamp': timestamp.toIso8601String(),
      'replyTo': replyTo?.toMap(),
      'imageData': imageData,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      chatId: map['chatId'],
      messageContent: map['messageContent'],
      messageType: map['messageType'],
      messageFormat: map['messageFormat'],
      timestamp: DateTime.parse(map['timestamp']),
      personName: map['personName'],
      isEdited: map['isEdited'] == 1,
      reaction: map['reaction'],
      autoDelete: map['autoDelete'] == 1,
      timeRemaining: map['timeRemaining'],
      replyTo: map['replyTo'] != null
          ? ChatMessage.fromMap(jsonDecode(map['replyTo']))
          : null,
      imageData: map['imageData'],
    );
  }
}

class GroupChatMessage {
  int? id;
  String chatId;
  String messageContent;
  String messageType;
  String messageFormat;
  DateTime timestamp;
  Uint8List? imageData;
  String personName;
  String groupName;

  GroupChatMessage({
    this.id,
    required this.chatId,
    required this.messageContent,
    required this.messageType,
    required this.messageFormat,
    required this.timestamp,
    required this.personName,
    required this.groupName,
    this.imageData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'messageContent': messageContent,
      'messageType': messageType,
      'messageFormat': messageFormat,
      'personName': personName,
      'groupName': groupName,
      'timestamp': timestamp.toIso8601String(),
      'imageData': imageData,
    };
  }

  static GroupChatMessage fromMap(Map<String, dynamic> map) {
    return GroupChatMessage(
      id: map['id'],
      chatId: map['chatId'],
      messageContent: map['messageContent'],
      messageType: map['messageType'],
      messageFormat: map['messageFormat'],
      timestamp: DateTime.parse(map['timestamp']),
      personName: map['personName'],
      groupName: map['groupName'],
      imageData: map['imageData'],
    );
  }
}

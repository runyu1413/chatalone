// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(error) => "选择图片时出错：${error}";

  static String m1(time) => "${time}秒后自毁";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("Chatalone"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "disconnect": MessageLookupByLibrary.simpleMessage("断开连接"),
        "disconnectMessage": MessageLookupByLibrary.simpleMessage("您确定要断开连接吗？"),
        "disconnectTitle": MessageLookupByLibrary.simpleMessage("断开连接"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "editMessage": MessageLookupByLibrary.simpleMessage("编辑您的消息..."),
        "enterMessage": MessageLookupByLibrary.simpleMessage("输入您的消息..."),
        "enterNewName": MessageLookupByLibrary.simpleMessage("输入新名称"),
        "errorPickingImage": m0,
        "failedToProcessImage":
            MessageLookupByLibrary.simpleMessage("处理图片文本失败"),
        "imageNotSelected": MessageLookupByLibrary.simpleMessage("未选择图片。"),
        "imageTooLarge": MessageLookupByLibrary.simpleMessage("图片太大"),
        "imageTooLargeMessage":
            MessageLookupByLibrary.simpleMessage("所选图片太大，无法发送。请选择小于20KB的图片。"),
        "messageContainsProfanity":
            MessageLookupByLibrary.simpleMessage("消息包含不当言辞"),
        "messageOptionsTitle": MessageLookupByLibrary.simpleMessage("消息选项"),
        "newChat": MessageLookupByLibrary.simpleMessage("新聊天"),
        "ok": MessageLookupByLibrary.simpleMessage("好"),
        "oldChat": MessageLookupByLibrary.simpleMessage("旧聊天"),
        "playGame": MessageLookupByLibrary.simpleMessage("玩游戏"),
        "playedConnectFour": MessageLookupByLibrary.simpleMessage("玩过四连棋"),
        "playedOthello": MessageLookupByLibrary.simpleMessage("玩过黑白棋"),
        "playedTicTacToe": MessageLookupByLibrary.simpleMessage("玩过井字棋"),
        "pleaseEnterMessage": MessageLookupByLibrary.simpleMessage("请输入消息"),
        "profanityDetected": MessageLookupByLibrary.simpleMessage("检测到不当言辞"),
        "profanityDetectedMessage":
            MessageLookupByLibrary.simpleMessage("图片包含不当言辞，无法发送。"),
        "profileNameChange": MessageLookupByLibrary.simpleMessage("更改个人资料名称"),
        "react": MessageLookupByLibrary.simpleMessage("反应"),
        "reply": MessageLookupByLibrary.simpleMessage("回复"),
        "searchHint": MessageLookupByLibrary.simpleMessage("搜索..."),
        "selfDestructsIn": m1,
        "sendImage": MessageLookupByLibrary.simpleMessage("发送图片"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "start": MessageLookupByLibrary.simpleMessage("开始"),
        "startConnectFour": MessageLookupByLibrary.simpleMessage("开始四连棋"),
        "startOthello": MessageLookupByLibrary.simpleMessage("开始黑白棋"),
        "startTicTacToe": MessageLookupByLibrary.simpleMessage("开始井字棋"),
        "title": MessageLookupByLibrary.simpleMessage("标题"),
        "welcomeText": MessageLookupByLibrary.simpleMessage("欢迎，")
      };
}

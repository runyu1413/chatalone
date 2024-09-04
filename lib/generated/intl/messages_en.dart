// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(error) => "Error picking image: ${error}";

  static String m1(time) => "Self-destructs in ${time} seconds";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("Chatalone"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "disconnectMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to disconnect?"),
        "disconnectTitle": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editMessage":
            MessageLookupByLibrary.simpleMessage("Edit your message..."),
        "enterMessage":
            MessageLookupByLibrary.simpleMessage("Enter your message..."),
        "enterNewName": MessageLookupByLibrary.simpleMessage("Enter New Name"),
        "errorPickingImage": m0,
        "failedToProcessImage": MessageLookupByLibrary.simpleMessage(
            "Failed to process the image for text"),
        "imageNotSelected":
            MessageLookupByLibrary.simpleMessage("No image was selected."),
        "imageTooLarge":
            MessageLookupByLibrary.simpleMessage("Image Too Large"),
        "imageTooLargeMessage": MessageLookupByLibrary.simpleMessage(
            "The selected image is too large to send. Please choose an image smaller than 20KB."),
        "messageContainsProfanity":
            MessageLookupByLibrary.simpleMessage("Message contains profanity"),
        "messageOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Message Options"),
        "newChat": MessageLookupByLibrary.simpleMessage("New Chat"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "oldChat": MessageLookupByLibrary.simpleMessage("Old Chat"),
        "playGame": MessageLookupByLibrary.simpleMessage("Play Game"),
        "playedConnectFour":
            MessageLookupByLibrary.simpleMessage("Played Connect Four"),
        "playedOthello": MessageLookupByLibrary.simpleMessage("Played Othello"),
        "playedTicTacToe":
            MessageLookupByLibrary.simpleMessage("Played Tic Tac Toe"),
        "pleaseEnterMessage":
            MessageLookupByLibrary.simpleMessage("Please enter a message"),
        "profanityDetected":
            MessageLookupByLibrary.simpleMessage("Profanity Detected"),
        "profanityDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "The image contains profanity and cannot be sent."),
        "profileNameChange":
            MessageLookupByLibrary.simpleMessage("Change Profile Name"),
        "react": MessageLookupByLibrary.simpleMessage("React"),
        "reply": MessageLookupByLibrary.simpleMessage("Reply"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Search..."),
        "selfDestructsIn": m1,
        "sendImage": MessageLookupByLibrary.simpleMessage("Send Image"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "start": MessageLookupByLibrary.simpleMessage("Start"),
        "startConnectFour":
            MessageLookupByLibrary.simpleMessage("Start Connect Four"),
        "startOthello": MessageLookupByLibrary.simpleMessage("Start Othello"),
        "startTicTacToe":
            MessageLookupByLibrary.simpleMessage("Start Tic Tac Toe"),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "welcomeText": MessageLookupByLibrary.simpleMessage("Welcome, ")
      };
}

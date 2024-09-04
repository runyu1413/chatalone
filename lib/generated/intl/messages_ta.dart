// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ta locale. All the
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
  String get localeName => 'ta';

  static String m0(error) => "படத்தைத் தேர்வு செய்வதில் பிழை: ${error}";

  static String m1(time) => "${time} விநாடிகளில் சுய அழிவடையும்";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("Chatalone"),
        "cancel": MessageLookupByLibrary.simpleMessage("ரத்து செய்"),
        "confirm": MessageLookupByLibrary.simpleMessage("உறுதிசெய்"),
        "copy": MessageLookupByLibrary.simpleMessage("நகல் எடு"),
        "delete": MessageLookupByLibrary.simpleMessage("அழி"),
        "disconnect": MessageLookupByLibrary.simpleMessage("துண்டி"),
        "disconnectMessage": MessageLookupByLibrary.simpleMessage(
            "நீங்கள் இணைப்பை துண்டிக்க விரும்புகிறீர்களா?"),
        "disconnectTitle":
            MessageLookupByLibrary.simpleMessage("இணைப்பை துண்டி"),
        "edit": MessageLookupByLibrary.simpleMessage("தொகு"),
        "editMessage": MessageLookupByLibrary.simpleMessage(
            "உங்கள் செய்தியைத் திருத்தவும்..."),
        "enterMessage": MessageLookupByLibrary.simpleMessage(
            "உங்கள் செய்தியை உள்ளிடவும்..."),
        "enterNewName":
            MessageLookupByLibrary.simpleMessage("புதிய பெயரை உள்ளிடவும்"),
        "errorPickingImage": m0,
        "failedToProcessImage": MessageLookupByLibrary.simpleMessage(
            "படத்திற்கான உரையை செயலாக்க முடியவில்லை"),
        "imageNotSelected": MessageLookupByLibrary.simpleMessage(
            "படம் தேர்ந்தெடுக்கப்படவில்லை."),
        "imageTooLarge":
            MessageLookupByLibrary.simpleMessage("படம் மிகப்பெரியது"),
        "imageTooLargeMessage": MessageLookupByLibrary.simpleMessage(
            "தேர்ந்தெடுக்கப்பட்ட படத்தை அனுப்ப முடியாது. 20KB க்கு குறைவான படத்தைத் தேர்ந்தெடுக்கவும்."),
        "messageContainsProfanity": MessageLookupByLibrary.simpleMessage(
            "செய்தியில் மோசமான சொற்கள் உள்ளன"),
        "messageOptionsTitle":
            MessageLookupByLibrary.simpleMessage("செய்தி விருப்பங்கள்"),
        "newChat": MessageLookupByLibrary.simpleMessage("புதிய உரையாடல்"),
        "ok": MessageLookupByLibrary.simpleMessage("சரி"),
        "oldChat": MessageLookupByLibrary.simpleMessage("பழைய உரையாடல்"),
        "playGame": MessageLookupByLibrary.simpleMessage("விளையாட்டு விளையாடு"),
        "playedConnectFour":
            MessageLookupByLibrary.simpleMessage("நான்கு இணைப்பை விளையாடினான்"),
        "playedOthello":
            MessageLookupByLibrary.simpleMessage("ஒதெல்லோவை விளையாடினான்"),
        "playedTicTacToe":
            MessageLookupByLibrary.simpleMessage("டிக் டாக் டோவை விளையாடினான்"),
        "pleaseEnterMessage": MessageLookupByLibrary.simpleMessage(
            "தயவுசெய்து செய்தியை உள்ளிடவும்"),
        "profanityDetected": MessageLookupByLibrary.simpleMessage(
            "மோசமான சொற்கள் கண்டறியப்பட்டன"),
        "profanityDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "படத்தில் மோசமான சொற்கள் உள்ளதால் அனுப்ப முடியாது."),
        "profileNameChange":
            MessageLookupByLibrary.simpleMessage("சுயவிவர பெயரை மாற்றவும்"),
        "react": MessageLookupByLibrary.simpleMessage("மாற்றம் செய்"),
        "reply": MessageLookupByLibrary.simpleMessage("பதிலளி"),
        "searchHint": MessageLookupByLibrary.simpleMessage("தேடு..."),
        "selfDestructsIn": m1,
        "sendImage": MessageLookupByLibrary.simpleMessage("படத்தை அனுப்பு"),
        "settings": MessageLookupByLibrary.simpleMessage("அமைப்புகள்"),
        "start": MessageLookupByLibrary.simpleMessage("ஆரம்பம்"),
        "startConnectFour":
            MessageLookupByLibrary.simpleMessage("நான்கு இணைப்பை தொடங்கு"),
        "startOthello":
            MessageLookupByLibrary.simpleMessage("ஒதெல்லோவை தொடங்கு"),
        "startTicTacToe":
            MessageLookupByLibrary.simpleMessage("டிக் டாக் டோவை தொடங்கு"),
        "title": MessageLookupByLibrary.simpleMessage("தலைப்பு"),
        "welcomeText": MessageLookupByLibrary.simpleMessage("வரவேற்கிறோம், ")
      };
}

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ms locale. All the
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
  String get localeName => 'ms';

  static String m0(error) => "Ralat semasa memilih imej: ${error}";

  static String m1(time) => "Hapus diri dalam ${time} saat";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("Chatalone"),
        "cancel": MessageLookupByLibrary.simpleMessage("Batal"),
        "confirm": MessageLookupByLibrary.simpleMessage("Sahkan"),
        "copy": MessageLookupByLibrary.simpleMessage("Salin"),
        "delete": MessageLookupByLibrary.simpleMessage("Padam"),
        "disconnect":
            MessageLookupByLibrary.simpleMessage("Putuskan Sambungan"),
        "disconnectMessage": MessageLookupByLibrary.simpleMessage(
            "Adakah anda pasti mahu putuskan sambungan?"),
        "disconnectTitle":
            MessageLookupByLibrary.simpleMessage("Putus Sambungan"),
        "edit": MessageLookupByLibrary.simpleMessage("Sunting"),
        "editMessage":
            MessageLookupByLibrary.simpleMessage("Sunting mesej anda..."),
        "enterMessage":
            MessageLookupByLibrary.simpleMessage("Masukkan mesej anda..."),
        "enterNewName":
            MessageLookupByLibrary.simpleMessage("Masukkan Nama Baru"),
        "errorPickingImage": m0,
        "failedToProcessImage": MessageLookupByLibrary.simpleMessage(
            "Gagal memproses imej untuk teks"),
        "imageNotSelected":
            MessageLookupByLibrary.simpleMessage("Tiada imej yang dipilih."),
        "imageTooLarge":
            MessageLookupByLibrary.simpleMessage("Imej Terlalu Besar"),
        "imageTooLargeMessage": MessageLookupByLibrary.simpleMessage(
            "Imej yang dipilih terlalu besar untuk dihantar. Sila pilih imej yang lebih kecil daripada 20KB."),
        "messageContainsProfanity": MessageLookupByLibrary.simpleMessage(
            "Mesej mengandungi kata-kata kesat"),
        "messageOptionsTitle":
            MessageLookupByLibrary.simpleMessage("Pilihan Mesej"),
        "newChat": MessageLookupByLibrary.simpleMessage("Sembang Baru"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "oldChat": MessageLookupByLibrary.simpleMessage("Sembang Lama"),
        "playGame": MessageLookupByLibrary.simpleMessage("Main Permainan"),
        "playedConnectFour":
            MessageLookupByLibrary.simpleMessage("Main Connect Four"),
        "playedOthello": MessageLookupByLibrary.simpleMessage("Main Othello"),
        "playedTicTacToe":
            MessageLookupByLibrary.simpleMessage("Main Tic Tac Toe"),
        "pleaseEnterMessage":
            MessageLookupByLibrary.simpleMessage("Sila masukkan mesej"),
        "profanityDetected":
            MessageLookupByLibrary.simpleMessage("Kata-Kata Kesat Dikesan"),
        "profanityDetectedMessage": MessageLookupByLibrary.simpleMessage(
            "Imej mengandungi kata-kata kesat dan tidak boleh dihantar."),
        "profileNameChange":
            MessageLookupByLibrary.simpleMessage("Tukar Nama Profil"),
        "react": MessageLookupByLibrary.simpleMessage("Reaksi"),
        "reply": MessageLookupByLibrary.simpleMessage("Balas"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Cari..."),
        "selfDestructsIn": m1,
        "sendImage": MessageLookupByLibrary.simpleMessage("Hantar Imej"),
        "settings": MessageLookupByLibrary.simpleMessage("Tetapan"),
        "start": MessageLookupByLibrary.simpleMessage("Mulakan"),
        "startConnectFour":
            MessageLookupByLibrary.simpleMessage("Mulakan Connect Four"),
        "startOthello": MessageLookupByLibrary.simpleMessage("Mulakan Othello"),
        "startTicTacToe":
            MessageLookupByLibrary.simpleMessage("Mulakan Tic Tac Toe"),
        "title": MessageLookupByLibrary.simpleMessage("Tajuk"),
        "welcomeText": MessageLookupByLibrary.simpleMessage("Selamat datang, ")
      };
}

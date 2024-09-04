// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Chatalone`
  String get appTitle {
    return Intl.message(
      'Chatalone',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, `
  String get welcomeText {
    return Intl.message(
      'Welcome, ',
      name: 'welcomeText',
      desc: 'Welcome message for the user',
      args: [],
    );
  }

  /// `Change Profile Name`
  String get profileNameChange {
    return Intl.message(
      'Change Profile Name',
      name: 'profileNameChange',
      desc: '',
      args: [],
    );
  }

  /// `Enter New Name`
  String get enterNewName {
    return Intl.message(
      'Enter New Name',
      name: 'enterNewName',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `New Chat`
  String get newChat {
    return Intl.message(
      'New Chat',
      name: 'newChat',
      desc: '',
      args: [],
    );
  }

  /// `Old Chat`
  String get oldChat {
    return Intl.message(
      'Old Chat',
      name: 'oldChat',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Title for the settings page',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get searchHint {
    return Intl.message(
      'Search...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Message Options`
  String get messageOptionsTitle {
    return Intl.message(
      'Message Options',
      name: 'messageOptionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnectTitle {
    return Intl.message(
      'Disconnect',
      name: 'disconnectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disconnect?`
  String get disconnectMessage {
    return Intl.message(
      'Are you sure you want to disconnect?',
      name: 'disconnectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Send Image`
  String get sendImage {
    return Intl.message(
      'Send Image',
      name: 'sendImage',
      desc: '',
      args: [],
    );
  }

  /// `Play Game`
  String get playGame {
    return Intl.message(
      'Play Game',
      name: 'playGame',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `React`
  String get react {
    return Intl.message(
      'React',
      name: 'react',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Start Tic Tac Toe`
  String get startTicTacToe {
    return Intl.message(
      'Start Tic Tac Toe',
      name: 'startTicTacToe',
      desc: '',
      args: [],
    );
  }

  /// `Start Connect Four`
  String get startConnectFour {
    return Intl.message(
      'Start Connect Four',
      name: 'startConnectFour',
      desc: '',
      args: [],
    );
  }

  /// `Start Othello`
  String get startOthello {
    return Intl.message(
      'Start Othello',
      name: 'startOthello',
      desc: '',
      args: [],
    );
  }

  /// `Image Too Large`
  String get imageTooLarge {
    return Intl.message(
      'Image Too Large',
      name: 'imageTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `The selected image is too large to send. Please choose an image smaller than 20KB.`
  String get imageTooLargeMessage {
    return Intl.message(
      'The selected image is too large to send. Please choose an image smaller than 20KB.',
      name: 'imageTooLargeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Profanity Detected`
  String get profanityDetected {
    return Intl.message(
      'Profanity Detected',
      name: 'profanityDetected',
      desc: '',
      args: [],
    );
  }

  /// `The image contains profanity and cannot be sent.`
  String get profanityDetectedMessage {
    return Intl.message(
      'The image contains profanity and cannot be sent.',
      name: 'profanityDetectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Enter your message...`
  String get enterMessage {
    return Intl.message(
      'Enter your message...',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit your message...`
  String get editMessage {
    return Intl.message(
      'Edit your message...',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message`
  String get pleaseEnterMessage {
    return Intl.message(
      'Please enter a message',
      name: 'pleaseEnterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Message contains profanity`
  String get messageContainsProfanity {
    return Intl.message(
      'Message contains profanity',
      name: 'messageContainsProfanity',
      desc: '',
      args: [],
    );
  }

  /// `Self-destructs in {time} seconds`
  String selfDestructsIn(int time) {
    return Intl.message(
      'Self-destructs in $time seconds',
      name: 'selfDestructsIn',
      desc: 'A message indicating how long until a message self-destructs.',
      args: [time],
    );
  }

  /// `Played Tic Tac Toe`
  String get playedTicTacToe {
    return Intl.message(
      'Played Tic Tac Toe',
      name: 'playedTicTacToe',
      desc: '',
      args: [],
    );
  }

  /// `Played Connect Four`
  String get playedConnectFour {
    return Intl.message(
      'Played Connect Four',
      name: 'playedConnectFour',
      desc: '',
      args: [],
    );
  }

  /// `Played Othello`
  String get playedOthello {
    return Intl.message(
      'Played Othello',
      name: 'playedOthello',
      desc: '',
      args: [],
    );
  }

  /// `Failed to process the image for text`
  String get failedToProcessImage {
    return Intl.message(
      'Failed to process the image for text',
      name: 'failedToProcessImage',
      desc: '',
      args: [],
    );
  }

  /// `No image was selected.`
  String get imageNotSelected {
    return Intl.message(
      'No image was selected.',
      name: 'imageNotSelected',
      desc: '',
      args: [],
    );
  }

  /// `Error picking image: {error}`
  String errorPickingImage(String error) {
    return Intl.message(
      'Error picking image: $error',
      name: 'errorPickingImage',
      desc: 'Error message when failing to pick an image.',
      args: [error],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

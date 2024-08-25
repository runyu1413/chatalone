import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/createuser.dart';
import 'package:ntu_fyp_chatalone/group.dart';
import 'package:ntu_fyp_chatalone/model/user_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'devicesList.dart';
import 'package:intl/intl.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ntu_fyp_chatalone/settings.dart'; // Adjust the path based on your project structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UsersAdapter());
  await Hive.openBox<Users>('Username');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language_code') ?? 'en';
  String? themeMode = prefs.getString('theme_mode') ?? 'system';

  ThemeMode initialThemeMode;
  if (themeMode == 'light') {
    initialThemeMode = ThemeMode.light;
  } else if (themeMode == 'dark') {
    initialThemeMode = ThemeMode.dark;
  } else {
    initialThemeMode = ThemeMode.system;
  }

  runApp(MyApp(languageCode: languageCode, initialThemeMode: initialThemeMode));
}

Route<dynamic> generateRoute(RouteSettings settings) {
  final userBox = Hive.box<Users>('Username');
  switch (settings.name) {
    case '/':
      final String? user = userBox.get('Username')?.username;
      if (user != null) {
        return MaterialPageRoute(builder: (context) => Home(name: user));
      } else {
        return MaterialPageRoute(builder: (_) => CreateUser());
      }
    case 'home':
      final usern = settings.arguments as String;
      var device = Users(username: usern);
      userBox.add(device);
      print(userBox.get('Username')?.username);
      return MaterialPageRoute(
          builder: (context) => Home(
                name: usern,
              ));
    case 'start':
      final name = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => DevicesListScreen(mydata: name));
    case 'group':
      final name = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => GroupListScreen(mydata: name));
    case 'settings': // Add this case for the settings route
      return MaterialPageRoute(builder: (context) => SettingsPage());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

class MyApp extends StatefulWidget {
  final String languageCode;
  final ThemeMode initialThemeMode;

  MyApp({required this.languageCode, required this.initialThemeMode});

  // Define the setLocale method
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  // Define the setTheme method
  static void setTheme(BuildContext context, ThemeMode newTheme) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setTheme(newTheme);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.languageCode);
    _themeMode = widget.initialThemeMode;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemePreference(themeMode); // Save the theme preference
  }

  void _saveThemePreference(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.light) {
      await prefs.setString('theme_mode', 'light');
    } else if (themeMode == ThemeMode.dark) {
      await prefs.setString('theme_mode', 'dark');
    } else {
      await prefs.setString('theme_mode', 'system');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      themeMode: _themeMode, // Apply the current theme mode
      theme: ThemeData.light(), // Define your light theme here
      darkTheme: ThemeData.dark(), // Define your dark theme here
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ms'), // Malay
        const Locale('zh'), // Simplified Chinese
        const Locale('ta'), // Tamil
      ],
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

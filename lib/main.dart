import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:ntu_fyp_chatalone/createuser.dart';
import 'package:ntu_fyp_chatalone/group.dart';
import 'home.dart';
import 'devicesList.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ntu_fyp_chatalone/settings.dart'; // Adjust the path based on your project structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatefulWidget {
  final String languageCode;
  final ThemeMode initialThemeMode;

  MyApp({required this.languageCode, required this.initialThemeMode});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

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
    _saveThemePreference(themeMode);
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

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => FutureBuilder<String?>(
                future: getUsername(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    return Home(name: snapshot.data!);
                  } else {
                    return SettingsPage(); // Direct to settings page if username is not set
                  }
                },
              ),
            );
          case 'home':
            final usern = settings.arguments as String;
            saveUsername(usern);
            return MaterialPageRoute(
              builder: (context) => Home(name: usern),
            );
          case 'start':
            final name = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => DevicesListScreen(mydata: name),
            );
          case 'group':
            final name = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => GroupListScreen(mydata: name),
            );
          case 'settings':
            return MaterialPageRoute(builder: (context) => SettingsPage());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
            );
        }
      },
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}

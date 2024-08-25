import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntu_fyp_chatalone/main.dart'; // Ensure this import is correct
import 'package:ntu_fyp_chatalone/generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedLanguage;
  ThemeMode? _themeMode;
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? 'en';
      _usernameController.text = prefs.getString('username') ?? '';

      String? theme = prefs.getString('theme_mode');
      if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  _changeLanguage(String languageCode) async {
    Locale locale = Locale(languageCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    setState(() {
      _selectedLanguage = languageCode; // Update the selected language state
    });

    // Update the app's locale
    MyApp.setLocale(context, locale);
  }

  _changeTheme(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.light) {
      await prefs.setString('theme_mode', 'light');
    } else if (themeMode == ThemeMode.dark) {
      await prefs.setString('theme_mode', 'dark');
    } else {
      await prefs.setString('theme_mode', 'system');
    }

    MyApp.setTheme(context, themeMode);
  }

  _changeUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    setState(() {
      _usernameController.text = username; // Update the controller text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            onSubmitted: _changeUsername,
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Language/Bahasa/语言/மொழி'),
            subtitle: Column(
              children: [
                RadioListTile<String>(
                  title: Text('English'),
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text('Melayu'),
                  value: 'ms',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text('简体中文'),
                  value: 'zh',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text('தமிழ்'),
                  value: 'ta',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Theme'),
            subtitle: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _changeTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _changeTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _changeTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

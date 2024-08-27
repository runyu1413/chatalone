import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntu_fyp_chatalone/main.dart'; // Ensure this import is correct
//import 'package:ntu_fyp_chatalone/generated/l10n.dart';
import 'home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedLanguage;
  ThemeMode? _themeMode;
  TextEditingController _usernameController = TextEditingController();
  bool _isUsernameEmpty = false; // Add this variable

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
      _selectedLanguage = languageCode;
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

  _saveUsername() async {
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
    }
  }

  _navigateToHome() async {
    String username = _usernameController.text.trim();

    if (username.isNotEmpty) {
      await _saveUsername();
      setState(() {
        _isUsernameEmpty = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(name: _usernameController.text)),
      );
    } else {
      setState(() {
        _isUsernameEmpty = true; // Set this to true if the username is empty
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings/Tetapan/设置/அமைப்பு"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username/Nama Pengguna/用户名/பயனர்பெயர்',
              border: OutlineInputBorder(),
              errorText: _isUsernameEmpty
                  ? 'Please enter a username\nSila masukkan nama pengguna\n请输入用户名\nதயவுசெய்து பயனர் பெயரை உள்ளிடுங்கள்'
                  : null,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _isUsernameEmpty ? Colors.red : Colors.blue,
                ),
              ),
            ),
            onSubmitted: (_) => _saveUsername(),
          ),
          SizedBox(height: 20),
          ListTile(
            title: const Text('Language/Bahasa/语言/மொழி'),
            subtitle: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Melayu'),
                  value: 'ms',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('简体中文'),
                  value: 'zh',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('தமிழ்'),
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
          const Divider(),
          ListTile(
            title: const Text('Theme/Tema/主题/வடிகம்'),
            subtitle: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode/Cahaya/亮/வெளிச்சம்'),
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _changeTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode/Gelap/黑/கருப்பு'),
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _changeTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text(
                      'System Default/Default Sistem/系统默认/சிஸ்டம் இயல்பு'),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToHome,
            child: const Text('Done/Selesai/完成/முடி'),
          ),
        ],
      ),
    );
  }
}

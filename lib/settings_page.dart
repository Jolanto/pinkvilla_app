import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = themeNotifier.value == ThemeMode.dark;


  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void toggleTheme(bool value) async {
    setState(() {
      isDarkMode = value;
      themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode') ?? true;
    setState(() {
      isDarkMode = savedTheme;
      themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: toggleTheme,
          ),
        ],
      ),
    );
  }
}

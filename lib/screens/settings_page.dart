import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDarkMode;
  }

  void _handleToggle(bool value) {
    setState(() {
      _isDark = value;
    });
    widget.onToggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFamily: 'Poppins-Bold',
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold, // fallback if custom font doesn't load
        )),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            trailing: Switch(
              value: _isDark,
              onChanged: _handleToggle,
              activeColor: Colors.pinkAccent,
            ),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/privacy-policy')),
          ),
          ListTile(
            title: Text(
              'Contact Us',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/contact-us')),
          ),
          ListTile(
            title: Text(
              'Terms Of Use',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/terms-of-use')),
          ),
          ListTile(
            title: Text(
              'About Us',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/about-us')),
          ),
          ListTile(
            title: Text(
              'Version',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            subtitle: Text(
              'Pinkvilla App v1.0',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

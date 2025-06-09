import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(
            title: Text('Dark Mode', style: TextStyle(color: Colors.white)),
            trailing: Switch(value: true, onChanged: null), // placeholder
          ),
          ListTile(
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/privacy-policy')),
          ),
          ListTile(
            title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/contact-us')),
          ),
          ListTile(
            title: const Text('Terms Of Use', style: TextStyle(color: Colors.white)),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/terms-of-use')),
          ),
          ListTile(
            title: const Text('About Us', style: TextStyle(color: Colors.white)),
            onTap: () => launchUrl(Uri.parse('https://www.pinkvilla.com/about-us')),
          ),
          const ListTile(
            title: Text('Version', style: TextStyle(color: Colors.white)),
            subtitle: Text('Pinkvilla App v1.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Image(
                    image: AssetImage('assets/icon/hanverse_logo.png'),
                    width: 72,
                    height: 72,
                  ),
                ),
                SizedBox(height: 8),
                Text('HanVerse', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                Text('Dipakai untuk pribadi, semua data tersimpan di HP ini.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Pengaturan AI'),
              subtitle: const Text('Atur API key untuk fitur rekomendasi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

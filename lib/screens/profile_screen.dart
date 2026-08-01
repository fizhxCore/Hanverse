import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../data/local_store.dart';
import '../models/drama.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, UserListEntry> _entries = {};
  int _jumlahKatalog = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await LocalStore.loadAll();
    final katalog = await CatalogStore.loadAll();
    if (mounted) setState(() {
      _entries = entries;
      _jumlahKatalog = katalog.length;
    });
  }

  int _count(WatchStatus s) => _entries.values.where((e) => e.status == s).length;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/icon/hanverse_logo.png',
                        width: 84,
                        height: 84,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('HanVerse',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  Text(
                    'Dipakai untuk pribadi \u2022 semua data tersimpan di HP ini',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Ringkasan statistik sederhana ---
            Row(
              children: [
                _StatCard(label: 'Ditonton', value: _count(WatchStatus.selesai)),
                const SizedBox(width: 10),
                _StatCard(label: 'Nonton', value: _count(WatchStatus.nonton)),
                const SizedBox(width: 10),
                _StatCard(label: 'Rencana', value: _count(WatchStatus.rencana)),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.auto_awesome_outlined, color: scheme.primary),
                    title: const Text('Pengaturan'),
                    subtitle: const Text('API key AI & TMDB'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.movie_outlined, color: scheme.primary),
                    title: const Text('Jumlah drama di katalog'),
                    trailing: Text('$_jumlahKatalog'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Versi aplikasi'),
                    trailing: Text('0.1.0'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: scheme.primary)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

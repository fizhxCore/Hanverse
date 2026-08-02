import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../models/drama.dart';
import '../widgets/drama_card.dart';
import '../widgets/ai_badge.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import 'tmdb_search_screen.dart';
import 'ai_chat_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  List<Drama> _katalog = [];
  List<Drama> _results = [];
  bool _loadingKatalog = true;

  @override
  void initState() {
    super.initState();
    _loadKatalog();
  }

  Future<void> _loadKatalog() async {
    final all = await CatalogStore.loadAll();
    if (mounted) setState(() {
      _katalog = all;
      _results = all;
      _loadingKatalog = false;
    });
  }

  void _search(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _results = _katalog;
        return;
      }
      final q = query.toLowerCase();
      _results = _katalog.where((d) {
        return d.judul.toLowerCase().contains(q) ||
            d.genre.any((g) => g.toLowerCase().contains(q));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari & Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah dari TMDB',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TmdbSearchScreen()),
              );
              _loadKatalog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _loadingKatalog
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- CTA ke halaman chat AI ---
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const AiBadge(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ngobrol sama AI — rekomendasi, info terbaru, atau tanya apa aja',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- Search dasar ---
                TextField(
                  controller: _searchController,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Cari judul atau genre di katalogmu',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (_results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        _katalog.isEmpty
                            ? 'Katalog masih kosong. Tap "+" buat nambah drama dari TMDB.'
                            : 'Gak ketemu drama yang cocok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ..._results.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DramaCard(
                        drama: d,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../models/drama.dart';
import '../widgets/drama_card.dart';
import '../widgets/ai_badge.dart';
import 'detail_screen.dart';
import 'discover_screen.dart';
import 'tmdb_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Drama> _dramas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await CatalogStore.loadAll();
    if (mounted) setState(() {
      _dramas = all;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comingSoon = _dramas.where((d) => d.status == 'coming_soon').toList();
    final ongoing = _dramas.where((d) => d.status == 'ongoing').toList();
    final lainnya = _dramas.where((d) => d.status == 'tamat').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HanVerse'),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DiscoverScreen()),
            ),
            child: const AiBadge(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah dari TMDB',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TmdbSearchScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (comingSoon.isNotEmpty) ...[
                    const _SectionTitle('Coming Soon'),
                    const SizedBox(height: 8),
                    ...comingSoon.map((d) => _buildCard(context, d)),
                    const SizedBox(height: 20),
                  ],
                  if (ongoing.isNotEmpty) ...[
                    const _SectionTitle('Sedang Tayang'),
                    const SizedBox(height: 8),
                    ...ongoing.map((d) => _buildCard(context, d)),
                    const SizedBox(height: 20),
                  ],
                  if (lainnya.isNotEmpty) ...[
                    const _SectionTitle('Tamat'),
                    const SizedBox(height: 8),
                    ...lainnya.map((d) => _buildCard(context, d)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCard(BuildContext context, Drama d) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DramaCard(
        drama: d,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  }
}

import 'package:flutter/material.dart';
import '../data/mock_dramas.dart';
import '../data/ai_service.dart';
import '../models/drama.dart';
import '../widgets/drama_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _aiController = TextEditingController();
  List<Drama> _results = mockDramas;

  bool _aiLoading = false;
  String? _aiAnswer;
  String? _aiError;

  void _search(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _results = mockDramas;
        return;
      }
      final q = query.toLowerCase();
      _results = mockDramas.where((d) {
        return d.judul.toLowerCase().contains(q) ||
            d.genre.any((g) => g.toLowerCase().contains(q));
      }).toList();
    });
  }

  Future<void> _askAi() async {
    final prompt = _aiController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _aiLoading = true;
      _aiAnswer = null;
      _aiError = null;
    });

    final apiKey = await AiService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _aiLoading = false;
        _aiError = 'API key belum diatur. Buka Pengaturan AI dulu.';
      });
      return;
    }

    try {
      final answer = await AiService.getRecommendation(
        apiKey: apiKey,
        userPrompt: prompt,
        katalog: mockDramas,
      );
      setState(() => _aiAnswer = answer);
    } catch (e) {
      setState(() => _aiError = 'Gagal minta rekomendasi: $e');
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari & Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan AI',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Tanya AI ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
                    const SizedBox(width: 6),
                    const Text('Tanya AI', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _aiController,
                  decoration: InputDecoration(
                    hintText: 'mis. "drakor apa yang baru tayang minggu ini?"',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _askAi(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _aiLoading ? null : _askAi,
                    child: _aiLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Minta rekomendasi'),
                  ),
                ),
                if (_aiAnswer != null) ...[
                  const Divider(height: 24),
                  Text(_aiAnswer!),
                ],
                if (_aiError != null) ...[
                  const SizedBox(height: 8),
                  Text(_aiError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // --- Search dasar ---
          TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Cari judul atau genre',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
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

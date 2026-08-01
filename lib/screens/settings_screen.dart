import 'package:flutter/material.dart';
import '../data/ai_service.dart';
import '../data/tmdb_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _aiController = TextEditingController();
  final _tmdbController = TextEditingController();
  bool _savedAi = false;
  bool _savedTmdb = false;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final aiKey = await AiService.getApiKey();
    final tmdbKey = await TmdbService.getApiKey();
    if (mounted) {
      if (aiKey != null) _aiController.text = aiKey;
      if (tmdbKey != null) _tmdbController.text = tmdbKey;
    }
  }

  Future<void> _saveAi() async {
    await AiService.setApiKey(_aiController.text.trim());
    setState(() => _savedAi = true);
  }

  Future<void> _saveTmdb() async {
    await TmdbService.setApiKey(_tmdbController.text.trim());
    setState(() => _savedTmdb = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AI Rekomendasi (Google Gemini)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Butuh API key Gemini milikmu sendiri (ada tier gratis, bikin di '
            'aistudio.google.com/apikey). Disimpan hanya di HP ini.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() => _savedAi = false),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _saveAi, child: const Text('Simpan')),
          if (_savedAi) ...[
            const SizedBox(height: 6),
            const Text('Tersimpan.', style: TextStyle(color: Colors.green)),
          ],

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          const Text('Database Drama (TMDB)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Buat cari & impor drakor dari TMDB (The Movie Database), gratis. '
            'Bikin akun & API key di themoviedb.org -> Settings -> API. '
            'Disimpan hanya di HP ini.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tmdbController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'TMDB API Key',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() => _savedTmdb = false),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _saveTmdb, child: const Text('Simpan')),
          if (_savedTmdb) ...[
            const SizedBox(height: 6),
            const Text('Tersimpan.', style: TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}

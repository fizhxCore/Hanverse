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
  bool _aiChecking = false;
  bool _tmdbChecking = false;

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

  void _showSnack(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveAi() async {
    final key = _aiController.text.trim();
    if (key.isEmpty) return;
    setState(() => _aiChecking = true);

    final valid = await AiService.validateKey(key);

    if (!mounted) return;
    setState(() => _aiChecking = false);

    if (valid) {
      await AiService.setApiKey(key);
      _showSnack('API key AI tervalidasi & tersimpan');
    } else {
      _showSnack('API key AI tidak valid, cek lagi ya', success: false);
    }
  }

  Future<void> _saveTmdb() async {
    final key = _tmdbController.text.trim();
    if (key.isEmpty) return;
    setState(() => _tmdbChecking = true);

    final valid = await TmdbService.validateKey(key);

    if (!mounted) return;
    setState(() => _tmdbChecking = false);

    if (valid) {
      await TmdbService.setApiKey(key);
      _showSnack('API key TMDB tervalidasi & tersimpan');
    } else {
      _showSnack('API key TMDB tidak valid, cek lagi ya', success: false);
    }
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
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _aiChecking ? null : _saveAi,
            child: _aiChecking
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text('Memvalidasi...'),
                    ],
                  )
                : const Text('Simpan'),
          ),

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
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _tmdbChecking ? null : _saveTmdb,
            child: _tmdbChecking
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text('Memvalidasi...'),
                    ],
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

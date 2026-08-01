import 'package:flutter/material.dart';
import '../data/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await AiService.getApiKey();
    if (key != null && mounted) _controller.text = key;
  }

  Future<void> _save() async {
    await AiService.setApiKey(_controller.text.trim());
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi AI di HanVerse butuh API key Google Gemini milikmu '
              'sendiri (ada versi gratis), disimpan hanya di HP ini (tidak '
              'dikirim ke mana-mana selain langsung ke Google saat kamu '
              'minta rekomendasi). Bikin key gratis di aistudio.google.com/apikey',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() => _saved = false),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _save,
              child: const Text('Simpan'),
            ),
            if (_saved) ...[
              const SizedBox(height: 8),
              const Text('Tersimpan.', style: TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}

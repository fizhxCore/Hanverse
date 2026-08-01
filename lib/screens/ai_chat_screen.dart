import 'package:flutter/material.dart';
import '../data/ai_service.dart';
import '../data/catalog_store.dart';
import '../models/drama.dart';

class ChatMessage {
  final String role; // 'user' atau 'model'
  final String text;
  ChatMessage(this.role, this.text);
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<Drama> _katalog = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    CatalogStore.loadAll().then((v) => setState(() => _katalog = v));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(ChatMessage('user', text));
      _controller.clear();
      _loading = true;
      _error = null;
    });
    _scrollToBottom();

    final apiKey = await AiService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'API key AI belum diatur. Buka Pengaturan dulu.';
      });
      return;
    }

    try {
      final history = _messages
          .map((m) => {'role': m.role, 'text': m.text})
          .toList();
      final reply = await AiService.chat(apiKey: apiKey, history: history, katalog: _katalog);
      setState(() => _messages.add(ChatMessage('model', reply)));
    } catch (e) {
      setState(() => _error = 'Gagal minta balasan: $e');
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            const Text('Ngobrol sama AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tanya apa aja soal drakor — rekomendasi, info '
                        'terbaru, atau ngobrol biasa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final isUser = m.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isUser ? scheme.primary : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              color: isUser ? scheme.onPrimary : scheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(_error!, style: TextStyle(color: scheme.error)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loading ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/tmdb_service.dart';
import '../data/catalog_store.dart';
import '../data/ai_service.dart';
import 'detail_screen.dart';

class TmdbSearchScreen extends StatefulWidget {
  final String? initialQuery;
  const TmdbSearchScreen({super.key, this.initialQuery});

  @override
  State<TmdbSearchScreen> createState() => _TmdbSearchScreenState();
}

class _TmdbSearchScreenState extends State<TmdbSearchScreen> {
  final _controller = TextEditingController();
  List<TmdbSearchResult> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final apiKey = await TmdbService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'API key TMDB belum diatur. Buka Pengaturan dulu.';
      });
      return;
    }

    try {
      final results = await TmdbService.search(apiKey, query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'Gagal cari: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _importDrama(TmdbSearchResult result) async {
    final tmdbKey = await TmdbService.getApiKey();
    if (tmdbKey == null || tmdbKey.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await TmdbService.getDetail(tmdbKey, result.id);
      var drama = detail.drama;

      if (detail.butuhTerjemahanSinopsis) {
        final aiKey = await AiService.getApiKey();
        if (aiKey != null && aiKey.isNotEmpty) {
          try {
            final terjemahan = await AiService.translateToIndonesian(
              apiKey: aiKey,
              englishText: drama.sinopsis,
            );
            drama = drama.copyWith(sinopsis: terjemahan);
          } catch (_) {
            // Kalau gagal terjemahkan, tetap lanjut pakai sinopsis Inggris asli.
            drama = drama.copyWith(
              sinopsis: '(Belum ada terjemahan Indonesia)\n${drama.sinopsis}',
            );
          }
        } else {
          drama = drama.copyWith(
            sinopsis: '(Belum ada terjemahan Indonesia — atur API key AI di '
                'Pengaturan supaya bisa diterjemahkan otomatis)\n${drama.sinopsis}',
          );
        }
      }

      await CatalogStore.add(drama);
      if (!mounted) return;
      Navigator.of(context).pop(); // tutup loading dialog
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(drama: drama)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal impor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah dari TMDB')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Cari judul drakor, mis. "Moving"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final r = _results[i];
                  return Card(
                    child: ListTile(
                      leading: r.posterUrl.isEmpty
                          ? Container(
                              width: 48,
                              height: 68,
                              color: scheme.primaryContainer,
                              child: const Icon(Icons.movie_outlined),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                r.posterUrl,
                                width: 48,
                                height: 68,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(r.judul),
                      subtitle: Text(r.tahun.isEmpty ? '-' : r.tahun),
                      trailing: FilledButton(
                        onPressed: () => _importDrama(r),
                        child: const Text('Tambah'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

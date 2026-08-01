import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../data/ai_service.dart';
import '../models/drama.dart';
import '../widgets/poster_card.dart';
import '../widgets/ai_badge.dart';
import 'detail_screen.dart';
import 'ai_chat_screen.dart';
import 'tmdb_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Drama> _dramas = [];
  bool _loading = true;

  List<TrendingItem>? _trending;
  bool _trendingLoading = false;
  String? _trendingError;

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

  Future<void> _loadTrending() async {
    if (_trending != null || _trendingLoading) return;
    setState(() {
      _trendingLoading = true;
      _trendingError = null;
    });

    final apiKey = await AiService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _trendingLoading = false;
        _trendingError = 'Atur API key AI di Pengaturan buat lihat trending.';
      });
      return;
    }

    try {
      final items = await AiService.getTrending(apiKey);
      setState(() => _trending = items);
    } catch (e) {
      setState(() => _trendingError = 'Gagal ambil trending: $e');
    } finally {
      setState(() => _trendingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final comingSoon = _dramas.where((d) => d.status == 'coming_soon').toList();
    final ongoing = _dramas.where((d) => d.status == 'ongoing').toList();
    final tamat = _dramas.where((d) => d.status == 'tamat').toList();
    final hero = _dramas.isNotEmpty ? _dramas.first : null;

    // Trigger load trending sekali saat pertama render (kalau belum).
    if (!_loading && _trending == null && !_trendingLoading && _trendingError == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrending());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HanVerse'),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AiChatScreen()),
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
              onRefresh: () async {
                setState(() {
                  _trending = null;
                  _trendingError = null;
                });
                await _load();
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // --- Hero banner ---
                  if (hero != null)
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DetailScreen(drama: hero)),
                      ),
                      child: Container(
                        height: 320,
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: scheme.primaryContainer,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            hero.posterUrl.isEmpty
                                ? Icon(Icons.movie_outlined,
                                    size: 64, color: scheme.onPrimaryContainer)
                                : Image.network(hero.posterUrl, fit: BoxFit.cover),
                            Positioned(
                              left: 0, right: 0, bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.85),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(hero.judul,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${hero.channel} • ${hero.jumlahEpisode} episode',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    FilledButton.icon(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => DetailScreen(drama: hero)),
                                      ),
                                      icon: const Icon(Icons.info_outline, size: 18),
                                      label: const Text('Lihat Detail'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Trending (AI) ---
                  _SectionHeader('Trending (via AI)'),
                  const SizedBox(height: 10),
                  if (_trendingLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_trendingError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(_trendingError!,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                    )
                  else if (_trending != null && _trending!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Belum ada data trending.',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    )
                  else if (_trending != null)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _trending!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final t = _trending![i];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TmdbSearchScreen(initialQuery: t.judul),
                              ),
                            ),
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.judul,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(t.alasan,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12, color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),

                  if (comingSoon.isNotEmpty) ...[
                    _SectionHeader('Coming Soon'),
                    const SizedBox(height: 10),
                    _PosterRow(dramas: comingSoon),
                    const SizedBox(height: 20),
                  ],
                  if (ongoing.isNotEmpty) ...[
                    _SectionHeader('Sedang Tayang'),
                    const SizedBox(height: 10),
                    _PosterRow(dramas: ongoing),
                    const SizedBox(height: 20),
                  ],
                  if (tamat.isNotEmpty) ...[
                    _SectionHeader('Tamat'),
                    const SizedBox(height: 10),
                    _PosterRow(dramas: tamat),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}

class _PosterRow extends StatelessWidget {
  final List<Drama> dramas;
  const _PosterRow({required this.dramas});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dramas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final d = dramas[i];
          return PosterCard(
            drama: d,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
            ),
          );
        },
      ),
    );
  }
}

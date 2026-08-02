import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../data/local_store.dart';
import '../data/ai_service.dart';
import '../data/tmdb_service.dart';
import '../models/drama.dart';
import '../widgets/poster_card.dart';
import '../widgets/ai_badge.dart';
import 'detail_screen.dart';
import 'ai_chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _tmdbKey;
  String? _aiKey;

  // "Lanjut Nonton" (dari data lokal yang sudah kamu simpan)
  List<Drama> _lanjutNonton = [];

  // Baris browse dari TMDB
  List<TmdbBrowseItem>? _populer;
  List<TmdbBrowseItem>? _topRated;
  String? _browseError;
  bool _browseLoading = false;

  // Trending via AI
  List<TrendingItem>? _trending;
  bool _trendingLoading = false;
  String? _trendingError;

  // Search langsung dari Home
  final _searchController = TextEditingController();
  List<TmdbBrowseItem> _searchResults = [];
  bool _searching = false;
  String? _searchError;

  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final tmdbKey = await TmdbService.getApiKey();
    final aiKey = await AiService.getApiKey();
    await _loadLanjutNonton();

    if (mounted) {
      setState(() {
        _tmdbKey = tmdbKey;
        _aiKey = aiKey;
        _initialLoading = false;
      });
    }

    if (tmdbKey != null && tmdbKey.isNotEmpty) {
      _loadBrowseRows(tmdbKey);
    }
    if (aiKey != null && aiKey.isNotEmpty) {
      _loadTrending(aiKey);
    }
  }

  Future<void> _loadLanjutNonton() async {
    final entries = await LocalStore.loadAll();
    final dramas = await CatalogStore.loadAll();
    _lanjutNonton =
        dramas.where((d) => entries[d.id]?.status == WatchStatus.nonton).toList();
  }

  Future<void> _loadBrowseRows(String tmdbKey) async {
    setState(() {
      _browseLoading = true;
      _browseError = null;
    });
    try {
      final results = await Future.wait([
        TmdbService.discoverKdrama(tmdbKey, sortBy: 'popularity.desc'),
        TmdbService.discoverKdrama(tmdbKey, sortBy: 'vote_average.desc', minVoteCount: 50),
      ]);
      if (!mounted) return;
      setState(() {
        _populer = results[0];
        _topRated = results[1];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _browseError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _browseLoading = false);
    }
  }

  Future<void> _loadTrending(String aiKey) async {
    setState(() {
      _trendingLoading = true;
      _trendingError = null;
    });
    try {
      final items = await AiService.getTrending(aiKey);
      if (!mounted) return;
      setState(() => _trending = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _trendingError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _trendingLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }
    if (_tmdbKey == null || _tmdbKey!.isEmpty) {
      setState(() => _searchError = 'Atur API key TMDB dulu di Pengaturan.');
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await TmdbService.search(_tmdbKey!, query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _searchError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _openTmdbItem(int tmdbId) async {
    if (_tmdbKey == null || _tmdbKey!.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final drama = await TmdbService.getFullDrama(
        tmdbApiKey: _tmdbKey!,
        tmdbId: tmdbId,
        aiApiKey: _aiKey,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(drama: drama)),
      );
      _loadLanjutNonton().then((_) => mounted ? setState(() {}) : null);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _refreshAll() async {
    await _loadLanjutNonton();
    if (mounted) setState(() {});
    if (_tmdbKey != null && _tmdbKey!.isNotEmpty) _loadBrowseRows(_tmdbKey!);
    if (_aiKey != null && _aiKey!.isNotEmpty) _loadTrending(_aiKey!);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSearching = _searchController.text.trim().isNotEmpty;
    final hero = _populer != null && _populer!.isNotEmpty ? _populer!.first : null;

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
        ],
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // --- Search bar ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() {}); // biar isSearching kebaca ulang
                        _search(v);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari drakor di TMDB...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                      ),
                    ),
                  ),

                  // --- Kalau lagi search, tampilkan hasil aja ---
                  if (isSearching) ...[
                    if (_searching)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_searchError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(_searchError!, style: TextStyle(color: scheme.error)),
                      )
                    else if (_searchResults.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: Text('Gak ketemu hasil buat "${_searchController.text}".',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      )
                    else
                      ..._searchResults.map((r) => _SearchResultTile(
                            item: r,
                            onTap: () => _openTmdbItem(r.id),
                          )),
                  ] else ...[
                    // --- TMDB belum diatur ---
                    if (_tmdbKey == null || _tmdbKey!.isEmpty)
                      _SetupPrompt(
                        icon: Icons.travel_explore_outlined,
                        text: 'Atur API key TMDB di Pengaturan buat mulai browsing drakor.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),

                    // --- Lanjut Nonton ---
                    if (_lanjutNonton.isNotEmpty) ...[
                      const _SectionHeader('Lanjut Nonton'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _lanjutNonton.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final d = _lanjutNonton[i];
                            return PosterCard(
                              drama: d,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
                                );
                                _loadLanjutNonton().then((_) => mounted ? setState(() {}) : null);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- Hero banner (dari Populer #1) ---
                    if (hero != null)
                      GestureDetector(
                        onTap: () => _openTmdbItem(hero.id),
                        child: Container(
                          height: 320,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: scheme.primaryContainer,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              hero.backdropUrl.isEmpty
                                  ? Icon(Icons.movie_outlined,
                                      size: 64, color: scheme.onPrimaryContainer)
                                  : Image.network(hero.backdropUrl, fit: BoxFit.cover),
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
                                        hero.tahun.isEmpty
                                            ? 'Populer di TMDB'
                                            : '${hero.tahun} • ★ ${hero.rating.toStringAsFixed(1)}',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      const SizedBox(height: 10),
                                      FilledButton.icon(
                                        onPressed: () => _openTmdbItem(hero.id),
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
                    if (_aiKey != null && _aiKey!.isNotEmpty) ...[
                      const _SectionHeader('Trending (via AI)'),
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
                      else if (_trending != null && _trending!.isNotEmpty)
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
                                onTap: () {
                                  _searchController.text = t.judul;
                                  _search(t.judul);
                                  setState(() {});
                                },
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
                    ],

                    // --- Populer & Top Rated (TMDB) ---
                    if (_browseLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_browseError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(_browseError!, style: TextStyle(color: scheme.error)),
                      )
                    else ...[
                      if (_populer != null && _populer!.isNotEmpty) ...[
                        const _SectionHeader('Populer'),
                        const SizedBox(height: 10),
                        _TmdbPosterRow(items: _populer!, onTap: _openTmdbItem),
                        const SizedBox(height: 20),
                      ],
                      if (_topRated != null && _topRated!.isNotEmpty) ...[
                        const _SectionHeader('Top Rated'),
                        const SizedBox(height: 10),
                        _TmdbPosterRow(items: _topRated!, onTap: _openTmdbItem),
                      ],
                    ],
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

class _SetupPrompt extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _SetupPrompt({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TmdbPosterRow extends StatelessWidget {
  final List<TmdbBrowseItem> items;
  final void Function(int tmdbId) onTap;
  const _TmdbPosterRow({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return GestureDetector(
            onTap: () => onTap(it.id),
            child: SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 168,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: it.posterUrl.isEmpty
                        ? Icon(Icons.movie_outlined, color: scheme.onPrimaryContainer)
                        : Image.network(
                            it.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.movie_outlined, color: scheme.onPrimaryContainer),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    it.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final TmdbBrowseItem item;
  final VoidCallback onTap;
  const _SearchResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: item.posterUrl.isEmpty
              ? Container(
                  width: 44, height: 64,
                  color: scheme.primaryContainer,
                  child: const Icon(Icons.movie_outlined),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(item.posterUrl,
                      width: 44, height: 64, fit: BoxFit.cover),
                ),
          title: Text(item.judul),
          subtitle: Text(item.tahun.isEmpty ? '-' : item.tahun),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

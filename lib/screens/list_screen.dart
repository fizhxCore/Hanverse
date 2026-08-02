import 'package:flutter/material.dart';
import '../data/catalog_store.dart';
import '../data/local_store.dart';
import '../models/drama.dart';
import '../widgets/drama_card.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Map<String, UserListEntry> _entries = {};
  List<Drama> _katalog = [];
  bool _loading = true;

  static const _tabs = {
    'Nonton': WatchStatus.nonton,
    'Selesai': WatchStatus.selesai,
    'Rencana': WatchStatus.rencana,
    'Drop': WatchStatus.drop,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await LocalStore.loadAll();
    final katalog = await CatalogStore.loadAll();
    if (mounted) setState(() {
      _entries = entries;
      _katalog = katalog;
      _loading = false;
    });
  }

  List<Drama> _dramasWith(WatchStatus status) {
    return _katalog.where((d) => _entries[d.id]?.status == status).toList();
  }

  IconData _iconFor(WatchStatus s) {
    switch (s) {
      case WatchStatus.nonton:
        return Icons.play_circle_outline;
      case WatchStatus.selesai:
        return Icons.check_circle_outline;
      case WatchStatus.rencana:
        return Icons.bookmark_border;
      case WatchStatus.drop:
        return Icons.cancel_outlined;
      default:
        return Icons.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('List-ku'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                dividerColor: Colors.transparent,
                labelColor: scheme.onPrimary,
                unselectedLabelColor: scheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: _tabs.entries
                    .map((e) => Tab(
                          height: 40,
                          icon: Icon(_iconFor(e.value), size: 16),
                          text: e.key,
                          iconMargin: const EdgeInsets.only(bottom: 2),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: TabBarView(
                  children: _tabs.values.map((status) {
                    final list = _dramasWith(status);
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_iconFor(status), size: 40, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada drama di kategori ini',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final d = list[i];
                        return DramaCard(
                          drama: d,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
                            );
                            _load();
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

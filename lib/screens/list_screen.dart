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

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Nonton': WatchStatus.nonton,
      'Selesai': WatchStatus.selesai,
      'Rencana': WatchStatus.rencana,
      'Drop': WatchStatus.drop,
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('List-ku'),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs.keys.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: TabBarView(
                  children: tabs.values.map((status) {
                    final list = _dramasWith(status);
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada drama di kategori ini',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                            _load(); // refresh setelah balik dari detail
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

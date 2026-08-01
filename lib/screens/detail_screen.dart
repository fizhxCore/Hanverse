import 'package:flutter/material.dart';
import '../models/drama.dart';
import '../data/local_store.dart';

class DetailScreen extends StatefulWidget {
  final Drama drama;
  const DetailScreen({super.key, required this.drama});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  UserListEntry _entry = UserListEntry(dramaId: '');

  @override
  void initState() {
    super.initState();
    _entry = UserListEntry(dramaId: widget.drama.id);
    _load();
  }

  Future<void> _load() async {
    final all = await LocalStore.loadAll();
    final saved = all[widget.drama.id];
    if (saved != null && mounted) setState(() => _entry = saved);
  }

  Future<void> _setStatus(WatchStatus status) async {
    setState(() => _entry.status = status);
    await LocalStore.save(_entry);
  }

  Drama get drama => widget.drama;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(drama.judul)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: drama.posterUrl.isEmpty
                ? Icon(Icons.movie_outlined, size: 48, color: scheme.onPrimaryContainer)
                : Image.network(
                    drama.posterUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Icon(Icons.movie_outlined,
                        size: 48, color: scheme.onPrimaryContainer),
                  ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Nonton'),
                selected: _entry.status == WatchStatus.nonton,
                onSelected: (_) => _setStatus(WatchStatus.nonton),
              ),
              ChoiceChip(
                label: const Text('Selesai'),
                selected: _entry.status == WatchStatus.selesai,
                onSelected: (_) => _setStatus(WatchStatus.selesai),
              ),
              ChoiceChip(
                label: const Text('Rencana'),
                selected: _entry.status == WatchStatus.rencana,
                onSelected: (_) => _setStatus(WatchStatus.rencana),
              ),
              ChoiceChip(
                label: const Text('Drop'),
                selected: _entry.status == WatchStatus.drop,
                onSelected: (_) => _setStatus(WatchStatus.drop),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: drama.genre.map((g) => Chip(label: Text(g))).toList(),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Channel', value: drama.channel),
          _InfoRow(label: 'Episode', value: '${drama.jumlahEpisode}'),
          _InfoRow(label: 'Tayang', value: drama.tanggalTayang),
          _InfoRow(label: 'Status', value: drama.status),
          if (drama.platformStreaming.isNotEmpty)
            _InfoRow(label: 'Platform', value: drama.platformStreaming.join(', ')),
          const SizedBox(height: 20),
          const Text('Sinopsis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(drama.sinopsis, style: const TextStyle(height: 1.5)),
          if (drama.pemeran.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Pemeran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...drama.pemeran.map((a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: a.fotoUrl.isEmpty ? null : NetworkImage(a.fotoUrl),
                  ),
                  title: Text(a.nama),
                  subtitle: Text('sebagai ${a.karakter}'),
                )),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

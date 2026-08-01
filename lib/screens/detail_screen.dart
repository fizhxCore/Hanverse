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
  late UserListEntry _entry;
  late TextEditingController _catatanController;
  bool _dirty = false;

  Drama get drama => widget.drama;

  @override
  void initState() {
    super.initState();
    _entry = UserListEntry(dramaId: drama.id);
    _catatanController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final all = await LocalStore.loadAll();
    final saved = all[drama.id];
    if (saved != null && mounted) {
      setState(() {
        _entry = saved;
        _catatanController.text = saved.catatan;
      });
    }
  }

  void _setStatus(WatchStatus status) {
    setState(() {
      _entry.status = status;
      _dirty = true;
    });
  }

  void _setEpisode(int value) {
    final clamped = value.clamp(0, drama.jumlahEpisode == 0 ? 999 : drama.jumlahEpisode);
    setState(() {
      _entry.episodeTerakhir = clamped;
      _dirty = true;
    });
  }

  void _setRating(double rating) {
    setState(() {
      _entry.rating = rating;
      _dirty = true;
    });
  }

  Future<void> _saveChanges() async {
    _entry.catatan = _catatanController.text;
    await LocalStore.save(_entry);
    setState(() => _dirty = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Perubahan tersimpan'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxEp = drama.jumlahEpisode == 0 ? 1 : drama.jumlahEpisode;

    return Scaffold(
      appBar: AppBar(title: Text(drama.judul)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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

          // --- Status ---
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Rencana'),
                selected: _entry.status == WatchStatus.rencana,
                onSelected: (_) => _setStatus(WatchStatus.rencana),
              ),
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
                label: const Text('Drop'),
                selected: _entry.status == WatchStatus.drop,
                onSelected: (_) => _setStatus(WatchStatus.drop),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Episode progress ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Episode ditonton', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('${_entry.episodeTerakhir} / ${drama.jumlahEpisode}',
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _setEpisode(_entry.episodeTerakhir - 1),
              ),
              Expanded(
                child: Slider(
                  value: _entry.episodeTerakhir.toDouble().clamp(0, maxEp.toDouble()),
                  min: 0,
                  max: maxEp.toDouble(),
                  divisions: maxEp > 0 ? maxEp : null,
                  onChanged: (v) => _setEpisode(v.round()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _setEpisode(_entry.episodeTerakhir + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Rating ---
          const Text('Rating Saya', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              final filled = (_entry.rating ?? 0) >= i + 1;
              return IconButton(
                onPressed: () => _setRating((i + 1).toDouble()),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: scheme.primary,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // --- Catatan ---
          const Text('Catatan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 4,
            onChanged: (_) => setState(() => _dirty = true),
            decoration: InputDecoration(
              hintText: 'Tulis pendapatmu tentang drama ini...',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            children: drama.genre.map((g) => Chip(label: Text(g))).toList(),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Channel', value: drama.channel),
          _InfoRow(label: 'Episode', value: '${drama.jumlahEpisode}'),
          _InfoRow(label: 'Tayang', value: drama.tanggalTayang),
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
      bottomNavigationBar: _dirty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _saveChanges,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            )
          : null,
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

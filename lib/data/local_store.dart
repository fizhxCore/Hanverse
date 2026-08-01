import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';

/// Menyimpan status List-ku (nonton/selesai/rencana/drop, rating, dst)
/// langsung di penyimpanan lokal HP. Cocok untuk pemakaian pribadi,
/// tidak butuh backend atau akun.
class LocalStore {
  static const _key = 'hanverse_user_list_v1';

  static Future<Map<String, UserListEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((id, value) {
      final map = value as Map<String, dynamic>;
      return MapEntry(
        id,
        UserListEntry(
          dramaId: id,
          status: WatchStatus.values.firstWhere(
            (s) => s.name == map['status'],
            orElse: () => WatchStatus.none,
          ),
          rating: (map['rating'] as num?)?.toDouble(),
          episodeTerakhir: map['episodeTerakhir'] as int? ?? 0,
          favorite: map['favorite'] as bool? ?? false,
          catatan: map['catatan'] as String? ?? '',
        ),
      );
    });
  }

  static Future<void> save(UserListEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all[entry.dramaId] = entry;

    final encoded = jsonEncode(all.map((id, e) => MapEntry(id, {
          'status': e.status.name,
          'rating': e.rating,
          'episodeTerakhir': e.episodeTerakhir,
          'favorite': e.favorite,
          'catatan': e.catatan,
        })));
    await prefs.setString(_key, encoded);
  }
}

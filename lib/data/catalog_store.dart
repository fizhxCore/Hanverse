import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';

/// Katalog drama = HANYA drama yang user tambah sendiri (lewat TMDB).
/// Tidak ada data contoh/dummy bawaan — kalau user belum nambah apa-apa,
/// katalognya beneran kosong. Disimpan lokal di HP, tidak ada server.
class CatalogStore {
  static const _key = 'hanverse_custom_dramas_v1';

  static Future<List<Drama>> loadCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Drama.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Drama>> loadAll() => loadCustom();

  static Future<void> add(Drama drama) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await loadCustom();
    // Hindari duplikat kalau drama yang sama diimpor lagi.
    custom.removeWhere((d) => d.id == drama.id);
    custom.add(drama);
    await prefs.setString(_key, jsonEncode(custom.map((d) => d.toJson()).toList()));
  }

  static Future<void> remove(String dramaId) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await loadCustom();
    custom.removeWhere((d) => d.id == dramaId);
    await prefs.setString(_key, jsonEncode(custom.map((d) => d.toJson()).toList()));
  }
}

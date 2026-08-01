import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';

class TmdbSearchResult {
  final int id;
  final String judul;
  final String? posterPath;
  final String tahun;

  TmdbSearchResult({
    required this.id,
    required this.judul,
    required this.posterPath,
    required this.tahun,
  });

  String get posterUrl =>
      posterPath == null ? '' : 'https://image.tmdb.org/t/p/w342$posterPath';
}

class TmdbDetailResult {
  final Drama drama;
  final bool butuhTerjemahanSinopsis;
  TmdbDetailResult({required this.drama, required this.butuhTerjemahanSinopsis});
}

/// Integrasi dengan TMDB (The Movie Database) — database film/TV gratis
/// yang datanya lengkap buat drama Korea. Dipakai supaya user gak perlu
/// input manual tiap nambah drama ke katalog.
class TmdbService {
  static const _apiKeyPref = 'hanverse_tmdb_api_key';
  static const _base = 'https://api.themoviedb.org/3';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
  }

  /// Cari drama Korea berdasarkan judul. Search TMDB tidak bisa difilter
  /// negara langsung, jadi kita filter hasilnya di sisi app (origin_country
  /// mengandung 'KR').
  static Future<List<TmdbSearchResult>> search(String apiKey, String query) async {
    final uri = Uri.parse('$_base/search/tv').replace(queryParameters: {
      'api_key': apiKey,
      'query': query,
      'language': 'id-ID',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Gagal cari drama (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);

    return results
        .where((r) => (r['origin_country'] as List?)?.contains('KR') ?? false)
        .map((r) => TmdbSearchResult(
              id: r['id'] as int,
              judul: r['name'] as String? ?? '(tanpa judul)',
              posterPath: r['poster_path'] as String?,
              tahun: (r['first_air_date'] as String? ?? '').split('-').first,
            ))
        .toList();
  }

  /// Ambil detail lengkap + cast, lalu ubah jadi objek Drama HanVerse.
  /// Kalau sinopsis bahasa Indonesia belum tersedia di TMDB, fallback ke
  /// bahasa Inggris (ditandai di sinopsisnya).
  static Future<TmdbDetailResult> getDetail(String apiKey, int tmdbId) async {
    final uriId = Uri.parse('$_base/tv/$tmdbId').replace(queryParameters: {
      'api_key': apiKey,
      'language': 'id-ID',
      'append_to_response': 'credits',
    });
    final res = await http.get(uriId);
    if (res.statusCode != 200) {
      throw Exception('Gagal ambil detail drama (${res.statusCode}): ${res.body}');
    }
    final d = jsonDecode(res.body) as Map<String, dynamic>;

    var sinopsis = d['overview'] as String? ?? '';
    var butuhTerjemahan = false;
    if (sinopsis.trim().isEmpty) {
      final uriEn = Uri.parse('$_base/tv/$tmdbId')
          .replace(queryParameters: {'api_key': apiKey, 'language': 'en-US'});
      final resEn = await http.get(uriEn);
      if (resEn.statusCode == 200) {
        final dEn = jsonDecode(resEn.body) as Map<String, dynamic>;
        final overviewEn = dEn['overview'] as String? ?? '';
        if (overviewEn.trim().isEmpty) {
          sinopsis = 'Sinopsis belum tersedia.';
        } else {
          sinopsis = overviewEn;
          butuhTerjemahan = true;
        }
      }
    }

    final genres = (d['genres'] as List<dynamic>? ?? [])
        .map((g) => g['name'] as String)
        .toList();

    final networks = (d['networks'] as List<dynamic>? ?? [])
        .map((n) => n['name'] as String)
        .toList();

    final cast = (d['credits']?['cast'] as List<dynamic>? ?? [])
        .take(6)
        .map((c) => Actor(
              nama: c['name'] as String? ?? '',
              karakter: c['character'] as String? ?? '',
              fotoUrl: c['profile_path'] == null
                  ? ''
                  : 'https://image.tmdb.org/t/p/w185${c['profile_path']}',
            ))
        .toList();

    final posterPath = d['poster_path'] as String?;
    final status = (d['status'] as String? ?? '').toLowerCase();

    return TmdbDetailResult(
      butuhTerjemahanSinopsis: butuhTerjemahan,
      drama: Drama(
        id: 'tmdb_$tmdbId',
        judul: d['name'] as String? ?? '',
        judulAsli: d['original_name'] as String? ?? '',
        sinopsis: sinopsis,
        genre: genres,
        negara: 'Korea Selatan',
        platformStreaming: const [],
        channel: networks.isNotEmpty ? networks.first : '-',
        jumlahEpisode: d['number_of_episodes'] as int? ?? 0,
        status: status.contains('end') || status.contains('cancel')
            ? 'tamat'
            : (d['first_air_date'] == null || (d['first_air_date'] as String).isEmpty)
                ? 'coming_soon'
                : 'ongoing',
        tanggalTayang: d['first_air_date'] as String? ?? 'TBA',
        ratingGlobal: (d['vote_average'] as num?)?.toDouble() ?? 0,
        sutradara: '-',
        penulis: '-',
        posterUrl: posterPath == null ? '' : 'https://image.tmdb.org/t/p/w500$posterPath',
        pemeran: cast,
      ),
    );
  }
}

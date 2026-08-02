import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';
import 'ai_service.dart';

/// Item ringan hasil search/browse TMDB (belum lengkap, cukup buat kartu).
class TmdbBrowseItem {
  final int id;
  final String judul;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double rating;
  final String tahun;

  TmdbBrowseItem({
    required this.id,
    required this.judul,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.rating,
    required this.tahun,
  });

  String get posterUrl =>
      posterPath == null ? '' : 'https://image.tmdb.org/t/p/w342$posterPath';
  String get backdropUrl =>
      backdropPath == null ? '' : 'https://image.tmdb.org/t/p/w780$backdropPath';
}

/// Integrasi dengan TMDB (The Movie Database) — database film/TV gratis
/// yang datanya lengkap buat drama Korea.
class TmdbService {
  static const _apiKeyPref = 'hanverse_tmdb_api_key';
  static const _base = 'https://api.themoviedb.org/3';
  static const _genreDrama = 18; // ID genre "Drama" di TMDB

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
  }

  static Future<bool> validateKey(String apiKey) async {
    try {
      final uri = Uri.parse('$_base/authentication')
          .replace(queryParameters: {'api_key': apiKey});
      final res = await http.get(uri);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static TmdbBrowseItem _fromJson(Map<String, dynamic> r) => TmdbBrowseItem(
        id: r['id'] as int,
        judul: r['name'] as String? ?? '(tanpa judul)',
        posterPath: r['poster_path'] as String?,
        backdropPath: r['backdrop_path'] as String?,
        overview: r['overview'] as String? ?? '',
        rating: (r['vote_average'] as num?)?.toDouble() ?? 0,
        tahun: (r['first_air_date'] as String? ?? '').split('-').first,
      );

  static void _throwIfError(http.Response res) {
    if (res.statusCode == 200) return;
    if (res.statusCode == 429) {
      throw Exception('Kena rate limit TMDB, coba lagi sebentar.');
    }
    if (res.statusCode == 401) {
      throw Exception('API key TMDB gak valid. Cek lagi di Pengaturan.');
    }
    throw Exception('Gagal mengambil data TMDB (${res.statusCode}).');
  }

  /// Cari drama Korea berdasarkan judul (dipakai buat search bar).
  static Future<List<TmdbBrowseItem>> search(String apiKey, String query) async {
    final uri = Uri.parse('$_base/search/tv').replace(queryParameters: {
      'api_key': apiKey,
      'query': query,
      'language': 'id-ID',
    });
    final res = await http.get(uri);
    _throwIfError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);
    return results
        .where((r) => (r['origin_country'] as List?)?.contains('KR') ?? false)
        .map((r) => _fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Browse katalog drama Korea TMDB (buat baris ala Netflix di Home),
  /// diurutkan sesuai [sortBy], mis. "popularity.desc" atau
  /// "vote_average.desc".
  static Future<List<TmdbBrowseItem>> discoverKdrama(
    String apiKey, {
    required String sortBy,
    int minVoteCount = 20,
  }) async {
    final uri = Uri.parse('$_base/discover/tv').replace(queryParameters: {
      'api_key': apiKey,
      'language': 'id-ID',
      'with_origin_country': 'KR',
      'with_genres': '$_genreDrama',
      'sort_by': sortBy,
      'vote_count.gte': '$minVoteCount',
      'include_adult': 'false',
    });
    final res = await http.get(uri);
    _throwIfError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);
    return results.map((r) => _fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Ambil detail lengkap + cast, ubah jadi objek Drama HanVerse siap
  /// pakai. Kalau sinopsis Indonesia belum ada di TMDB dan [aiApiKey]
  /// disediakan, otomatis diterjemahkan pakai AI.
  static Future<Drama> getFullDrama({
    required String tmdbApiKey,
    required int tmdbId,
    String? aiApiKey,
  }) async {
    final uriId = Uri.parse('$_base/tv/$tmdbId').replace(queryParameters: {
      'api_key': tmdbApiKey,
      'language': 'id-ID',
      'append_to_response': 'credits',
    });
    final res = await http.get(uriId);
    _throwIfError(res);
    final d = jsonDecode(res.body) as Map<String, dynamic>;

    var sinopsis = d['overview'] as String? ?? '';
    if (sinopsis.trim().isEmpty) {
      final uriEn = Uri.parse('$_base/tv/$tmdbId')
          .replace(queryParameters: {'api_key': tmdbApiKey, 'language': 'en-US'});
      final resEn = await http.get(uriEn);
      if (resEn.statusCode == 200) {
        final dEn = jsonDecode(resEn.body) as Map<String, dynamic>;
        final overviewEn = dEn['overview'] as String? ?? '';
        if (overviewEn.trim().isEmpty) {
          sinopsis = 'Sinopsis belum tersedia.';
        } else if (aiApiKey != null && aiApiKey.isNotEmpty) {
          try {
            sinopsis = await AiService.translateToIndonesian(
              apiKey: aiApiKey,
              englishText: overviewEn,
            );
          } catch (_) {
            sinopsis = '(Belum ada terjemahan Indonesia)\n$overviewEn';
          }
        } else {
          sinopsis = '(Belum ada terjemahan Indonesia — atur API key AI di '
              'Pengaturan supaya bisa diterjemahkan otomatis)\n$overviewEn';
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

    return Drama(
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
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';

/// Fitur AI sengaja dibuat sesederhana mungkin untuk pemakaian pribadi:
/// - API key disimpan lokal di HP (tidak ada server milik HanVerse)
/// - Panggil langsung ke Google Gemini API (ada tier gratis) tiap user
///   minta rekomendasi
/// - Tidak ada riwayat/percakapan tersimpan, murni satu kali tanya-jawab
class TrendingItem {
  final String judul;
  final String alasan;
  TrendingItem({required this.judul, required this.alasan});
}

class AiService {
  static const _apiKeyPref = 'hanverse_ai_api_key';
  static const _model = 'gemini-3.6-flash';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
  }

  /// Cek API key beneran valid dengan request kecil ke Gemini,
  /// bukan cuma disimpan mentah-mentah.
  static Future<bool> validateKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': 'ping'},
              ],
            },
          ],
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<String> getRecommendation({
    required String apiKey,
    required String userPrompt,
    required List<Drama> katalog,
  }) async {
    final daftarDrama = katalog
        .map((d) => '- ${d.judul} (${d.genre.join(", ")}): ${d.sinopsis}')
        .join('\n');

    final systemPrompt =
        'Kamu adalah asisten drama Korea di aplikasi HanVerse. '
        'Jawab singkat dalam bahasa Indonesia (maksimal 4-5 kalimat). '
        'Katalog drama yang sudah ada di list pengguna:\n$daftarDrama\n\n'
        'Kamu boleh pakai Google Search untuk cari info terkini (drama yang '
        'baru tayang/coming soon, cast, jadwal rilis) kalau pertanyaan '
        'butuh info terbaru yang mungkin tidak ada di katalog di atas. '
        'Kalau merekomendasikan drama, sebutkan juga apakah drama itu '
        'sudah ada di katalog pengguna atau belum.';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      ),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userPrompt},
            ],
          },
        ],
        'tools': [
          {'google_search': {}},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memanggil AI (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return 'AI tidak memberi jawaban.';
    }

    final parts = (candidates.first['content']?['parts'] as List<dynamic>?) ?? [];
    final text = parts
        .where((p) => p['text'] != null)
        .map((p) => p['text'] as String)
        .join('\n');
    return text.trim().isEmpty ? 'AI tidak memberi jawaban.' : text.trim();
  }

  /// Chat multi-turn: histori percakapan dikirim tiap request (Gemini API
  /// stateless), supaya AI inget konteks obrolan sebelumnya dalam sesi ini.
  static Future<String> chat({
    required String apiKey,
    required List<Map<String, String>> history, // [{role: user/model, text: ...}]
    required List<Drama> katalog,
  }) async {
    final daftarDrama = katalog
        .map((d) => '- ${d.judul} (${d.genre.join(", ")}): ${d.sinopsis}')
        .join('\n');

    final systemPrompt =
        'Kamu adalah asisten drama Korea di aplikasi HanVerse, ngobrol '
        'santai dalam bahasa Indonesia. '
        'Katalog drama yang sudah ada di list pengguna:\n$daftarDrama\n\n'
        'Kamu boleh pakai Google Search untuk info terkini (drama baru '
        'tayang/coming soon, cast, jadwal rilis, trending). Kalau '
        'merekomendasikan drama, sebutkan juga apakah drama itu sudah ada '
        'di katalog pengguna atau belum. Jawab singkat dan natural seperti '
        'ngobrol, bukan seperti laporan.';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      ),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': history
            .map((m) => {
                  'role': m['role'],
                  'parts': [
                    {'text': m['text']},
                  ],
                })
            .toList(),
        'tools': [
          {'google_search': {}},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memanggil AI (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return 'AI tidak memberi jawaban.';
    }

    final parts = (candidates.first['content']?['parts'] as List<dynamic>?) ?? [];
    final text = parts
        .where((p) => p['text'] != null)
        .map((p) => p['text'] as String)
        .join('\n');
    return text.trim().isEmpty ? 'AI tidak memberi jawaban.' : text.trim();
  }

  static Future<List<TrendingItem>> getTrending(String apiKey) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      ),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {
              'text':
                  'Cari drama Korea (drakor) yang sedang trending/populer saat '
                  'ini pakai Google Search. Balas HANYA dalam format JSON array '
                  '(tanpa markdown, tanpa teks lain), maksimal 6 item, format: '
                  '[{"judul": "...", "alasan": "alasan singkat max 10 kata dalam bahasa Indonesia"}]',
            },
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Drakor apa yang lagi trending sekarang?'},
            ],
          },
        ],
        'tools': [
          {'google_search': {}},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal ambil trending (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return [];

    final parts = (candidates.first['content']?['parts'] as List<dynamic>?) ?? [];
    var text = parts
        .where((p) => p['text'] != null)
        .map((p) => p['text'] as String)
        .join('\n')
        .trim();

    // Bersihkan kalau AI tetap bungkus dengan markdown code block.
    text = text.replaceAll(RegExp(r'^```json'), '').replaceAll(RegExp(r'```$'), '').trim();

    try {
      final list = jsonDecode(text) as List<dynamic>;
      return list
          .map((e) => TrendingItem(
                judul: e['judul'] as String? ?? '',
                alasan: e['alasan'] as String? ?? '',
              ))
          .where((t) => t.judul.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String> translateToIndonesian({
    required String apiKey,
    required String englishText,
  }) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      ),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {
              'text':
                  'Terjemahkan teks berikut ke bahasa Indonesia yang natural, '
                  'tanpa tambahan komentar apa pun, hanya hasil terjemahannya saja.',
            },
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': englishText},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menerjemahkan (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return englishText;

    final parts = (candidates.first['content']?['parts'] as List<dynamic>?) ?? [];
    final text = parts
        .where((p) => p['text'] != null)
        .map((p) => p['text'] as String)
        .join('\n');
    return text.trim().isEmpty ? englishText : text.trim();
  }
}

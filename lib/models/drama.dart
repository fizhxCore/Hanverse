enum WatchStatus { none, nonton, selesai, rencana, drop }

class Actor {
  final String nama;
  final String karakter;
  final String fotoUrl;

  const Actor({
    required this.nama,
    required this.karakter,
    required this.fotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'karakter': karakter,
        'fotoUrl': fotoUrl,
      };

  factory Actor.fromJson(Map<String, dynamic> json) => Actor(
        nama: json['nama'] as String? ?? '',
        karakter: json['karakter'] as String? ?? '',
        fotoUrl: json['fotoUrl'] as String? ?? '',
      );
}

class Drama {
  final String id;
  final String judul;
  final String judulAsli;
  final String sinopsis;
  final List<String> genre;
  final String negara;
  final List<String> platformStreaming;
  final String channel;
  final int jumlahEpisode;
  final String status; // ongoing / coming_soon / tamat
  final String tanggalTayang;
  final double ratingGlobal;
  final String sutradara;
  final String penulis;
  final String posterUrl;
  final List<Actor> pemeran;

  const Drama({
    required this.id,
    required this.judul,
    required this.judulAsli,
    required this.sinopsis,
    required this.genre,
    required this.negara,
    required this.platformStreaming,
    required this.channel,
    required this.jumlahEpisode,
    required this.status,
    required this.tanggalTayang,
    required this.ratingGlobal,
    required this.sutradara,
    required this.penulis,
    required this.posterUrl,
    required this.pemeran,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'judulAsli': judulAsli,
        'sinopsis': sinopsis,
        'genre': genre,
        'negara': negara,
        'platformStreaming': platformStreaming,
        'channel': channel,
        'jumlahEpisode': jumlahEpisode,
        'status': status,
        'tanggalTayang': tanggalTayang,
        'ratingGlobal': ratingGlobal,
        'sutradara': sutradara,
        'penulis': penulis,
        'posterUrl': posterUrl,
        'pemeran': pemeran.map((a) => a.toJson()).toList(),
      };

  factory Drama.fromJson(Map<String, dynamic> json) => Drama(
        id: json['id'] as String,
        judul: json['judul'] as String? ?? '',
        judulAsli: json['judulAsli'] as String? ?? '',
        sinopsis: json['sinopsis'] as String? ?? '',
        genre: (json['genre'] as List?)?.map((e) => e as String).toList() ?? [],
        negara: json['negara'] as String? ?? '',
        platformStreaming:
            (json['platformStreaming'] as List?)?.map((e) => e as String).toList() ?? [],
        channel: json['channel'] as String? ?? '',
        jumlahEpisode: json['jumlahEpisode'] as int? ?? 0,
        status: json['status'] as String? ?? 'ongoing',
        tanggalTayang: json['tanggalTayang'] as String? ?? '',
        ratingGlobal: (json['ratingGlobal'] as num?)?.toDouble() ?? 0,
        sutradara: json['sutradara'] as String? ?? '',
        penulis: json['penulis'] as String? ?? '',
        posterUrl: json['posterUrl'] as String? ?? '',
        pemeran: (json['pemeran'] as List?)
                ?.map((e) => Actor.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Drama copyWith({String? sinopsis}) => Drama(
        id: id,
        judul: judul,
        judulAsli: judulAsli,
        sinopsis: sinopsis ?? this.sinopsis,
        genre: genre,
        negara: negara,
        platformStreaming: platformStreaming,
        channel: channel,
        jumlahEpisode: jumlahEpisode,
        status: status,
        tanggalTayang: tanggalTayang,
        ratingGlobal: ratingGlobal,
        sutradara: sutradara,
        penulis: penulis,
        posterUrl: posterUrl,
        pemeran: pemeran,
      );
}

class UserListEntry {
  final String dramaId;
  WatchStatus status;
  double? rating;
  int episodeTerakhir;
  bool favorite;
  String catatan;

  UserListEntry({
    required this.dramaId,
    this.status = WatchStatus.none,
    this.rating,
    this.episodeTerakhir = 0,
    this.favorite = false,
    this.catatan = '',
  });
}

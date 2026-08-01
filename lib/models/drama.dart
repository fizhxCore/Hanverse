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

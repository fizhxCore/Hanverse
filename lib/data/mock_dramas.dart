import '../models/drama.dart';

final List<Drama> mockDramas = [
  Drama(
    id: 'd1',
    judul: 'Sinyal Waktu',
    judulAsli: 'Sample Drama 1',
    sinopsis:
        'Seorang detektif di masa kini menemukan cara berkomunikasi dengan '
        'detektif lain di masa lalu lewat sebuah radio tua, dan bersama-sama '
        'mereka mencoba memecahkan kasus yang belum terselesaikan selama '
        'puluhan tahun.',
    genre: const ['Misteri', 'Thriller', 'Fantasi'],
    negara: 'Korea Selatan',
    platformStreaming: const ['Netflix'],
    channel: 'tvN',
    jumlahEpisode: 16,
    status: 'tamat',
    tanggalTayang: '2016',
    ratingGlobal: 9.1,
    sutradara: 'Sutradara Contoh',
    penulis: 'Penulis Contoh',
    posterUrl: '',
    pemeran: const [
      Actor(nama: 'Aktor A', karakter: 'Detektif Park', fotoUrl: ''),
      Actor(nama: 'Aktor B', karakter: 'Detektif Lee', fotoUrl: ''),
    ],
  ),
  Drama(
    id: 'd2',
    judul: 'Rumah di Ujung Musim Semi',
    judulAsli: 'Sample Drama 2',
    sinopsis:
        'Kisah tiga bersaudara yang harus kembali ke rumah masa kecil mereka '
        'setelah bertahun-tahun berpisah, dan perlahan menyembuhkan luka '
        'keluarga yang selama ini mereka hindari.',
    genre: const ['Drama Keluarga', 'Romantis'],
    negara: 'Korea Selatan',
    platformStreaming: const ['Viu'],
    channel: 'JTBC',
    jumlahEpisode: 12,
    status: 'ongoing',
    tanggalTayang: '2026',
    ratingGlobal: 8.4,
    sutradara: 'Sutradara Contoh 2',
    penulis: 'Penulis Contoh 2',
    posterUrl: '',
    pemeran: const [
      Actor(nama: 'Aktor C', karakter: 'Anak Sulung', fotoUrl: ''),
    ],
  ),
  Drama(
    id: 'd3',
    judul: 'Malam Sebelum Kita Bertemu',
    judulAsli: 'Sample Drama 3',
    sinopsis:
        'Drama akan segera tayang tentang dua orang asing yang terus '
        'bertemu di malam yang sama, di kota yang sama, namun di garis '
        'waktu yang berbeda.',
    genre: const ['Fantasi', 'Romantis'],
    negara: 'Korea Selatan',
    platformStreaming: const [],
    channel: 'tvN',
    jumlahEpisode: 14,
    status: 'coming_soon',
    tanggalTayang: 'TBA',
    ratingGlobal: 0,
    sutradara: 'Sutradara Contoh 3',
    penulis: 'Penulis Contoh 3',
    posterUrl: '',
    pemeran: const [],
  ),
];

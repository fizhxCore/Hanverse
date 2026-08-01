# HanVerse

Database & tracker drakor dengan rekomendasi personal — versi lebih bagus dari MyDramaList.

## Status saat ini (versi simpel, pemakaian pribadi)
Aplikasi ini sengaja dibuat tanpa backend/server/akun — semua data
tersimpan lokal di HP kamu sendiri.

- **Home ala Netflix**: hero banner, baris "Trending" (dicari AI lewat
  Google Search, tap buat impor dari TMDB), lalu baris horizontal
  Coming Soon / Sedang Tayang / Tamat
- List drama (Rencana/Nonton/Selesai/Drop) dengan **rating bintang**,
  **progress episode** (slider + stepper), dan **catatan pribadi** —
  mirip MyDramaList, tersimpan lokal di HP
- **Ngobrol sama AI**: halaman chat penuh (bukan cuma satu kali
  tanya), inget konteks percakapan, bisa Google Search buat info
  terkini
- **Tambah dari TMDB**: cari drakor lewat database TMDB (gratis) dan
  impor langsung ke katalog — poster, sinopsis, cast, genre, jadwal
  tayang otomatis terisi. Kalau TMDB belum punya sinopsis bahasa
  Indonesia, otomatis diterjemahkan pakai AI (Gemini) saat diimpor
- Search dasar (judul & genre) di tab Discover
- UI minimalis ala Metrolist (Material 3), dengan logo HanVerse
  (motif taegeuk + aksen play) sebagai app icon
- Data drama: gabungan dari data contoh bawaan (`mock_dramas.dart`)
- Splash screen dengan animasi logo saat app dibuka
- API key (AI & TMDB) divalidasi beneran ke server saat disimpan,
  bukan cuma disimpan mentah — ketauan dari awal kalau salah ketik
  + drama yang kamu impor dari TMDB, semua tersimpan lokal di HP

## Cara pakai (development lokal)
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Clone repo ini, lalu jalankan:
   ```
   flutter create --platforms=android .
   flutter pub get
   flutter run
   ```
   (perintah `flutter create` di atas akan generate folder `android/`
   yang sengaja tidak di-commit ke repo — lihat penjelasan di
   `.github/workflows/build-apk.yml`)

## Cara build APK lewat GitHub Actions
1. Push project ini ke repo GitHub kamu (branch `main`).
2. Workflow di `.github/workflows/build-apk.yml` otomatis jalan setiap
   push ke `main`, atau bisa dipicu manual lewat tab **Actions** ->
   pilih workflow "Build APK" -> **Run workflow**.
3. Setelah selesai, buka run yang sukses -> bagian **Artifacts** ->
   download `hanverse-apk` (isinya `app-release.apk`).

## Struktur project
```
lib/
  models/drama.dart       -> model data Drama, Aktor, UserListEntry
  data/mock_dramas.dart   -> data contoh (sementara, sebelum ada backend)
  theme/app_theme.dart    -> tema Material 3 ala Metrolist
  screens/                -> Home, Discover (search), List-ku, Detail, Profil
  widgets/drama_card.dart -> kartu drama yang dipakai di beberapa halaman
```

## Langkah berikutnya (opsional, kalau nanti mau dikembangkan lagi)
- Tambah drama sendiri langsung di `lib/data/mock_dramas.dart`
- Integrasi sumber data drakor (API/scraping) untuk info "Coming Soon"
  otomatis (saat ini masih data statis)
- Fitur timeline keterkaitan drama
- (Backend, akun, komunitas sengaja tidak dibuat karena aplikasi ini
  untuk pemakaian pribadi)

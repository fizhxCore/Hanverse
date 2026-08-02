# HanVerse

Database & tracker drakor dengan rekomendasi personal — versi lebih bagus dari MyDramaList.

## Status saat ini (versi simpel, pemakaian pribadi)
Aplikasi ini sengaja dibuat tanpa backend/server/akun — semua data
tersimpan lokal di HP kamu sendiri.

- **Home ala Netflix**: search bar buat cari drakor langsung dari TMDB,
  baris "Lanjut Nonton" (dari yang kamu tracking), hero banner, baris
  "Trending" (AI + Google Search), "Populer" dan "Top Rated" (langsung
  dari TMDB, bukan data lokal) — tap drama mana pun buka halaman detail
- **List-ku**: tempat drama yang kamu simpan (Rencana/Nonton/Selesai/
  Drop) dengan **rating bintang**, **progress episode**, dan
  **catatan pribadi** — mirip MyDramaList. Drama otomatis masuk ke
  sini begitu kamu atur status & tekan "Simpan Perubahan" di halaman
  detail, dari mana pun kamu buka drama itu (Home, Discover, atau
  Tambah dari TMDB)
- **Discover**: search di drama yang sudah kamu simpan, plus tombol
  "+" buat impor cepat dari TMDB dan CTA ke chat AI
- **Ngobrol sama AI**: halaman chat penuh, inget konteks percakapan,
  bisa Google Search buat info terkini
- Kalau TMDB belum punya sinopsis bahasa Indonesia, otomatis
  diterjemahkan pakai AI (Gemini) saat drama dibuka/disimpan
- UI minimalis ala Metrolist (Material 3), dengan logo HanVerse
  (motif taegeuk + aksen play) sebagai app icon
- Splash screen dengan animasi logo saat app dibuka
- API key (AI & TMDB) divalidasi beneran ke server saat disimpan,
  bukan cuma disimpan mentah — ketauan dari awal kalau salah ketik
- Data drama: 100% dari TMDB (browse/search), gak ada data contoh/
  dummy bawaan

## Catatan soal kuota AI
Tier gratis Gemini punya limit request per menit/hari. Kalau muncul
pesan "kuota lagi habis", itu bukan bug — tunggu beberapa menit atau
cek limit di ai.google.dev/gemini-api/docs/rate-limits.

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

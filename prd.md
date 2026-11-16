# PRD 2 — Penyesuaian Aplikasi Flutter *Ayo Berhitung* untuk Backend Next.js + PostgreSQL

**Produk:** Aplikasi edukasi matematika `ayobitung` (Flutter) **Berkaitan dengan:** PRD 1 — Migrasi Backend Laravel ke Next.js + PostgreSQL **Status:** Draft untuk review **Sumber:** `desc.md` (klien Flutter) dan `desc_1.md` (backend Laravel)

---

## 1. Ringkasan

Aplikasi Flutter **tidak perlu ditulis ulang**. Backend baru dirancang menjaga kontrak API lama (PRD 1), sehingga pekerjaan di sisi klien berfokus pada:

1. **Memusatkan konfigurasi API** (base URL saat ini di-*hardcode* di lima file).
2. **Menyesuaikan klien dengan backend baru** (token, error, CORS, HTTPS).
3. **Menyelesaikan utang teknis** yang tercatat di `desc.md` bagian 3.5, karena sebagian bergantung pada data dari backend baru.
4. **Menyiapkan rilis fase 2** (validasi jawaban di server) tanpa memutus pengguna versi lama.

## 2. Tujuan & Non-Tujuan

### 2.1 Tujuan

| ID | Tujuan | Indikator keberhasilan |
| :-- | :-- | :-- |
| G-1 | Aplikasi berjalan penuh terhadap backend Next.js | Seluruh alur login → materi → kuis → unlock → profil lolos uji di staging |
| G-2 | Satu titik konfigurasi API | Nol literal `127.0.0.1:8000` tersisa di `lib/` |
| G-3 | Tidak ada data palsu di UI | Statistik beranda dan profil memakai data API; tidak ada fallback dummy |
| G-4 | Sesi stabil | Token tidak valid (401) otomatis mengarahkan ke login |
| G-5 | Basis kode bersih dan teruji | File legacy dihapus, test default diganti, dependensi diperbarui |

### 2.2 Non-Tujuan

- Tidak mengubah desain visual, animasi, atau gameplay Ular Tangga.
- Tidak menambah fitur siswa baru selain yang disebut (statistik nyata dan leaderboard opsional).
- Tidak memigrasikan state-management ke framework baru (tetap sederhana kecuali dibutuhkan, lihat 5.2).

## 3. Kondisi Saat Ini (Ringkas)

| Aspek | Kondisi |
| :-- | :-- |
| Framework | Flutter, Dart `^3.7.2`, Material |
| HTTP | `http ^0.13.3` dipanggil langsung dari tiap layar |
| Base URL | `http://127.0.0.1:8000/api`, tersebar di `name_input_screen`, `home_screen`, `materi_detail_screen`, `quiz_screen`, `profile_screen` |
| Penyimpanan lokal | `shared_preferences`: `token`, `completedMateriIds_<nisn>`, `unlockedMateriIds_<nisn>`, `bestScore`, `userName`, `nisn` |
| Autentikasi | Login NISN, bearer token |
| Platform | Android, iOS, Web, Linux, macOS, Windows |

## 4. Kompatibilitas Kontrak API

Klien membaca kunci JSON berikut. Backend baru **wajib** mempertahankannya (PRD 1, bagian 6.1); klien harus menanganinya secara defensif.

| Endpoint | Kunci yang dibaca Flutter | Perubahan di klien |
| :-- | :-- | :-- |
| `POST /login` | `token`, `data_siswa.nama`, `data_siswa.nisn`, `data_siswa.kelas` | Simpan juga `nama` dan `nisn` ke penyimpanan (lihat 5.4) |
| `GET /materi` | `id`, `judul` | Tidak ada |
| `GET /materi/{id}` | `konten`, `gambar_url` | Tangani `gambar_url` null/404 dengan placeholder |
| `GET /materi-unlock` | `unlocked_materi_ids` | Tidak ada |
| `GET /kuis/{id}` | `kuis` (List atau Map) | Pertahankan parser yang menerima keduanya |
| `POST /hasil-kuis` | status `200` | Baca `total_skor` bila dibutuhkan |
| `POST /unlock-next-materi` | `message` | Baca `unlocked` (boolean, baru) bila tersedia |
| `GET /user/stats` | `total_skor`, `gelar` | Gunakan juga untuk kartu statistik beranda |
| `GET /user/profile` | `nama`, `nisn`, `kelas`, `sekolah`, `alamat` | **Ganti** panggilan `POST /login` di profil menjadi `GET /user/profile` (lihat 5.5) |

**Catatan:** `ProfileScreen` saat ini memanggil `POST /api/login` ulang hanya untuk mengambil data profil. Setiap login menghapus token lama dan menerbitkan token baru di backend, sehingga pola ini berisiko membuat token yang tersimpan di perangkat lain tidak valid. Endpoint `GET /user/profile` sudah tersedia di backend dan harus dipakai.

## 5. Kebutuhan Fungsional & Teknis

### 5.1 Konfigurasi API Terpusat (wajib)

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-01 | Buat `lib/core/api_config.dart` berisi `baseUrl` dari `--dart-define=API_BASE_URL` dengan default aman | Pencarian `127.0.0.1` di `lib/` tidak menemukan apa pun |
| FE-02 | Dukungan lingkungan: lokal, emulator Android (`10.0.2.2`), staging, produksi | Build dapat berpindah lingkungan tanpa ubah kode |
| FE-03 | Buat `lib/services/api_client.dart` pembungkus HTTP: menambahkan header `Authorization`, `Accept: application/json`, timeout seragam (20 detik), dan decoding error seragam | Tidak ada layar yang memanggil `http.get/post` langsung |
| FE-04 | Pisahkan layanan per domain: `auth_service`, `materi_service`, `kuis_service`, `user_service` | Layar hanya memanggil service, bukan URL |

Contoh perintah build:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
flutter build apk --dart-define=API_BASE_URL=https://api.contoh.sch.id/api
```

### 5.2 Manajemen Sesi & Error

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-05 | `ApiClient` mendeteksi `401`, menghapus token, lalu mengarahkan ke `NameInputScreen` dengan pesan *"Sesi berakhir, silakan masuk lagi"* | Token dihapus di server → aplikasi kembali ke login tanpa crash |
| FE-06 | Pemetaan error seragam: `422` → tampilkan `message`/`errors`, `404` → "data tidak ditemukan", `5xx` → "server bermasalah", timeout/koneksi → "periksa koneksi" dengan tombol *Coba Lagi* | Setiap layar memiliki state error yang konsisten |
| FE-07 | Siswa yang tokennya tidak berlaku setelah cutover backend diarahkan login ulang **satu kali** | Tidak ada layar kosong/spinner tak berujung setelah migrasi |
| FE-08 | Pertimbangkan `flutter_secure_storage` untuk token (menggantikan `shared_preferences`) | Token tersimpan terenkripsi di Android/iOS; fallback ke `shared_preferences` di Web |

Untuk state management, cukup `ChangeNotifier`/`Provider` ringan atau tetap `setState` bila layar hanya memakai service; keputusan diambil saat implementasi FE-03/FE-04.

### 5.3 Statistik Beranda Nyata

Kartu `Materi`, `Progress`, `Streak` di `HomeScreen` saat ini statis (`'4'`, `'75%'`, `'5 hari'`).

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-09 | **Materi:** jumlah materi terbuka dibanding total (`unlocked / total`) dari `GET /materi-unlock` dan `GET /materi` | Angka berubah saat materi baru terbuka |
| FE-10 | **Progress:** persentase dari `total_skor` (`GET /user/stats`, maks. 100) | Sama dengan `total_skor` di profil |
| FE-11 | **Streak:** tidak ada sumber data di backend | **Keputusan:** hapus kartu Streak, atau minta backend menambah field `streak_hari` (di luar PRD 1 fase 1). Rekomendasi: ganti dengan kartu **Gelar** dari `/user/stats` |
| FE-12 | Tampilkan shimmer saat memuat dan state error bila gagal | Tidak ada angka palsu saat gagal |

### 5.4 Konsistensi Data Lokal

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-13 | Saat login berhasil simpan `token`, `userName`, `nisn` (dan `kelas`) ke penyimpanan lokal | `QuizResultScreen` tidak lagi jatuh ke fallback `'Siswa'` / `''` |
| FE-14 | `HomeScreen` dan `QuizResultScreen` membaca identitas dari satu `SessionStore` | Satu sumber kebenaran; tidak ada `prefs.getString` tersebar |
| FE-15 | Server adalah sumber kebenaran status unlock; cache lokal hanya untuk mode luring singkat | Setelah login di perangkat baru, daftar materi terbuka sama dengan di server |
| FE-16 | `completedMateriIds_<nisn>` tetap lokal (penanda UI) dan tidak memengaruhi logika unlock | Tidak ada regresi tampilan |

### 5.5 Profil & Navigasi

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-17 | `ProfileScreen` memakai `GET /user/profile` + `GET /user/stats` (bukan `POST /login`) | Membuka profil tidak mengubah token |
| FE-18 | **Hapus data dummy** (`Siswa Contoh`, skor 1500, `Pejuang Hebat`) dari catch block; tampilkan state error dengan *Coba Lagi* | Saat offline tidak ada data palsu |
| FE-19 | Samakan label bottom nav di `ProfileScreen` dengan `HomeScreen` (`Game`, `Home`, `Profil`); tab 0 membuka Game, tab 1 membuka Home | Navigasi identik di semua layar |
| FE-20 | Tampilkan field `sekolah`, `alamat`, `profile_picture` bila tersedia; sembunyikan baris bila null | Tidak ada teks "null" di UI |
| FE-21 | Logout: panggil endpoint logout bila tersedia (opsional di backend), lalu hapus **hanya kunci sesi** (`token`, `userName`, `nisn`), bukan `prefs.clear()`, agar `bestScore` game tidak hilang | Rekor Ular Tangga bertahan setelah logout |

### 5.6 Alur Kuis & Unlock

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-22 | Kirim jawaban dengan nilai kecil `a–d` (sudah demikian) dan tangani `422` | Tidak ada jawaban huruf besar yang terkirim |
| FE-23 | Setelah soal terakhir, **selalu** panggil `POST /unlock-next-materi` dan percayai hasil server; jangan memutuskan unlock hanya dari persentase lokal | Materi terbuka/terkunci sesuai respons server |
| FE-24 | Tampilkan pesan hasil unlock dari server (mis. *"Materi berikutnya terbuka"*) di `QuizResultScreen` | Siswa tahu status materi berikutnya |
| FE-25 | Segarkan daftar unlock saat kembali ke beranda | Materi baru langsung tidak terkunci |
| FE-26 | Idempoten: pengiriman jawaban yang gagal di tengah kuis dapat diulang tanpa menggandakan skor | Dengan `UNIQUE(siswa_id, kuis_id)` di server, kirim ulang aman |

**Perhatian:** server lama membuka materi berdasarkan `SUM(skor) ≥ 70` absolut, sedangkan klien memakai persentase. Bila PRD 1 bagian 9.1 disetujui (persentase di server), FE-23 menjadikan keduanya selaras otomatis.

### 5.7 Fase 2 — Validasi Jawaban di Server (rilis terpisah)

Bila backend berhenti mengirim `jawaban_benar` (PRD 1, 9.3):

- `QuizScreen` memakai respons `POST /hasil-kuis` (`benar`, `skor`, `pembahasan`) untuk umpan balik, bukan perhitungan lokal.
- `QuizResultScreen` menyusun rincian dari data respons yang dikumpulkan.
- **Kompatibilitas versi:** backend mempertahankan perilaku lama untuk header versi aplikasi lama (`X-App-Version`) selama masa transisi; klien baru mengirim header ini mulai rilis 5.1.

### 5.8 Game Ular Tangga

| ID | Kebutuhan | Kriteria penerimaan |
| :-- | :-- | :-- |
| FE-27 | Tidak ada perubahan gameplay | Papan, tangga, ular, dan generator soal identik |
| FE-28 | `bestScore` disimpan per NISN (`bestScore_<nisn>`) | Siswa berbeda di satu perangkat memiliki rekor sendiri |
| FE-29 | *(Opsional)* tampilkan leaderboard dari `GET /leaderboard` di profil atau tab baru | Hanya bila disetujui; tidak wajib untuk rilis migrasi |

### 5.9 Konfigurasi Platform

| Platform | Kebutuhan |
| :-- | :-- |
| **Android** | Produksi wajib **HTTPS**. Untuk pengembangan lokal, izinkan `cleartextTraffic` hanya pada build debug (`network_security_config`). Pastikan izin `INTERNET` ada di `AndroidManifest` rilis. |
| **iOS** | HTTPS wajib (ATS). Jangan menambah pengecualian ATS pada rilis produksi. |
| **Web** | Backend harus mengizinkan origin aplikasi melalui CORS (PRD 1, 6.1). Pastikan `Authorization` ada di `Access-Control-Allow-Headers`. |
| **Desktop** | Tidak ada perubahan selain base URL. |

### 5.10 Dependensi & Kebersihan Kode

| ID | Kebutuhan |
| :-- | :-- |
| FE-30 | Naikkan `http` dari `^0.13.3` ke seri `1.x` (perhatikan perubahan API kecil); jalankan `flutter pub outdated` dan perbarui dependensi lain yang aman |
| FE-31 | Hapus file legacy: `lib/widgets/custom_button.dart` (kosong), `lib/screens/login.dart`, `lib/screens/detail_screen_quiz.dart`, `lib/screens/tetstinf.dart` |
| FE-32 | Ganti `test/widget_test.dart` (smoke test counter bawaan) dengan test yang sesuai `WelcomeScreen` dan layanan baru |
| FE-33 | Aktifkan `flutter analyze` dengan `flutter_lints` di CI; nol peringatan error |

## 6. Persyaratan Non-Fungsional

| Area | Persyaratan |
| :-- | :-- |
| **Keandalan jaringan** | Timeout 20 detik seragam, *retry* manual dengan tombol Coba Lagi; satu *retry* otomatis untuk `GET` yang gagal karena jaringan |
| **Performa** | Waktu muat daftar materi di jaringan 4G < 2 detik; gambar materi di-cache (`cached_network_image`) |
| **Keamanan** | Tidak ada secret di aplikasi; token tidak dicatat di log; HTTPS di produksi; token disimpan terenkripsi di mobile (FE-08) |
| **Aksesibilitas** | Kontras teks memadai, label semantik pada tombol utama, ukuran sentuh minimal 48 dp |
| **Kompatibilitas** | Android 6.0+ (API 23) dan iOS 13+ sebagai target minimum yang disarankan; konfirmasi dengan kebutuhan sekolah |
| **Umpan balik** | `HapticFeedback`, transisi, dan `SnackBar` yang ada dipertahankan |
| **Kebersihan sumber daya** | `AnimationController` dan `AudioPlayer` tetap di-*dispose* |

## 7. Strategi Pengujian

- **Unit:** `ApiClient` (header, timeout, pemetaan error 401/422/404/5xx), parser `kuis` (List dan Map), logika sapaan dan gelar tampilan.
- **Widget:** `NameInputScreen` (validasi 10 digit, animasi error), `QuizResultScreen` (kategori Luar Biasa/Bagus/Tetap Semangat), `ProfileScreen` (state error tanpa data dummy).
- **Integrasi (staging):** login → materi 1 → kuis → skor ≥ batas → materi 2 terbuka → profil menampilkan skor dan gelar yang sama dengan panel admin.
- **Uji kompatibilitas kontrak:** jalankan skrip yang memanggil endpoint staging dan memverifikasi kunci yang dibaca klien (bagian 4).
- **Manual:** Android fisik, emulator Android, iOS, Web (CORS), kondisi offline, token kedaluwarsa.

## 8. Rencana Rilis & Migrasi

| Tahap | Aksi | Syarat lanjut |
| :-- | :-- | :-- |
| **A. Persiapan** | FE-01 s.d. FE-04, FE-30 s.d. FE-33 (refactor tanpa perubahan perilaku), diuji terhadap Laravel lama | Aplikasi tetap berjalan normal terhadap backend lama |
| **B. Integrasi staging** | Arahkan ke staging Next.js; FE-05 s.d. FE-26 | Alur kuis/unlock lolos pada staging |
| **C. Rilis klien** | Rilis versi baru (mis. `1.1.0+2`) yang memakai base URL produksi baru | Cutover backend dijadwalkan bersamaan |
| **D. Cutover** | Backend beralih; siswa login ulang sekali | Tidak ada lonjakan error 401 yang tidak wajar |
| **E. Fase 2** | Validasi jawaban di server (5.7) bila disetujui | Mayoritas pengguna sudah di versi baru |

**Penting:** karena base URL tertanam di build, versi lama aplikasi hanya dapat mengikuti backend baru bila (a) domain/URL lama dialihkan ke Next.js, atau (b) siswa memperbarui aplikasi. Putuskan strategi ini bersama jadwal cutover PRD 1.

## 9. Risiko

| Risiko | Dampak | Mitigasi |
| :-- | :-- | :-- |
| Versi aplikasi lama masih menunjuk ke URL lama | Siswa tak bisa masuk setelah cutover | Pertahankan domain API sama dan alihkan ke Next.js, atau paksa pembaruan aplikasi |
| Penghapusan fallback dummy memunculkan layar error di jaringan buruk | Kesan aplikasi tidak stabil | State error yang ramah + Coba Lagi + cache terakhir yang valid (bukan data palsu) |
| Perbedaan aturan unlock klien vs server | Materi terbuka/terkunci tak terduga | Server sebagai sumber kebenaran (FE-23) dan PRD 1 bagian 9.1 |
| CORS salah konfigurasi di Web | Flutter Web gagal memanggil API | Uji di staging; daftar origin eksplisit |
| Pembaruan `http 0.13 → 1.x` | Kompilasi gagal pada penggunaan lama | Lakukan di tahap A, terpisah dari perubahan perilaku |

## 10. Pertanyaan Terbuka

1. Platform mana yang benar-benar dirilis ke siswa (Android saja, atau juga iOS/Web)?
2. Apakah domain API produksi akan tetap sama dengan yang dipakai versi aplikasi lama?
3. Kartu **Streak**: dihapus, diganti Gelar, atau backend menambah datanya?
4. Apakah leaderboard (FE-29) ditampilkan ke siswa?
5. Apakah perlu mode luring (kuis tanpa internet) atau cukup tampilan error?
6. Apakah rekor `bestScore` Ular Tangga perlu disinkronkan ke server?

## 11. Definition of Done

- Nol URL *hardcode*; seluruh HTTP lewat `ApiClient`.
- Seluruh FE-01 s.d. FE-26 dan FE-30 s.d. FE-33 lulus; FE-27 (tanpa perubahan gameplay) terverifikasi.
- Beranda dan profil hanya menampilkan data dari API (tanpa angka statis atau dummy).
- 401 selalu mengarahkan ke login dengan pesan jelas.
- Uji integrasi staging hijau dan rilis klien terjadwal bersama cutover backend.

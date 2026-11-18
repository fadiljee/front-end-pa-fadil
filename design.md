# Design System — Edu Quiz App (Flutter)

Dokumen ini adalah panduan desain lengkap (theme, style, komponen, dan layout) untuk aplikasi edukasi kuis anak/pelajar, berdasarkan referensi UI: **Home**, **Quiz**, dan **Results/Profile**.

---

## 1. Design Principles

1. **Friendly & Playful** — Terasa ramah untuk anak/remaja, tidak kaku seperti aplikasi sekolah tradisional.
2. **Clean & Focused** — Banyak ruang kosong, satu aksi utama per layar.
3. **Color-coded** — Warna dipakai sebagai penanda kategori dan status (bagus/sedang/rendah).
4. **Gamified** — Grade badge, skor persen, progress, dan indikator lingkaran memotivasi pengguna.
5. **Soft & Rounded** — Semua elemen punya sudut membulat besar, tanpa garis tajam.

**Style keyword:** Modern Flat UI · Card-based · Soft Pastel · 3D Clay Illustration · Gamification

---

## 2. Color Palette

### 2.1 Brand / Primary

| Token | Hex | Penggunaan |
|---|---|---|
| `primary` | `#2E2FD1` | Header, tombol utama, ikon aktif, judul penting |
| `primaryLight` | `#4B4BE0` | Gradient/hover, kartu "Recent Quiz" |
| `primaryDark` | `#2020A8` | Pressed state |
| `onPrimary` | `#FFFFFF` | Teks/ikon di atas primary |

### 2.2 Background & Surface

| Token | Hex | Penggunaan |
|---|---|---|
| `bgApp` | `#9A9CF5` | Background luar (opsional, untuk presentasi/splash) |
| `background` | `#F3F4FF` | Background layar utama |
| `surface` | `#FFFFFF` | Card putih (soal, riwayat hasil) |
| `surfaceTint` | `#EEF0FF` | Bottom nav, area input soft |
| `outline` | `#D9DBF5` | Border tipis, divider |

### 2.3 Category Colors (Pastel)

Setiap kategori punya set warna: **background card**, **accent (chip/ikon)**, dan **teks judul**.

| Kategori | Card BG | Accent | Teks Judul |
|---|---|---|---|
| Algebra | `#E3E6FA` | `#2E2FD1` | `#2E2FD1` |
| Geometry | `#FFD9D9` | `#F0605D` | `#D8423F` |
| Statistics / 3rd | `#CDF5E0` | `#2FBF71` | `#1E9B58` |
| Calculus / 4th | `#FFF1CC` | `#F5B731` | `#C98E0A` |
| Trigonometry / 5th | `#E8DDFB` | `#8E5CE6` | `#6B3FC4` |

> Tambahkan kategori baru dengan pola yang sama: BG pastel terang + accent jenuh + teks versi gelap dari accent.

### 2.4 Answer Option Colors

| Opsi | Background Row | Badge Huruf |
|---|---|---|
| A | `#E3E6FA` | `#2E2FD1` |
| B | `#FFD9D9` | `#F0605D` |
| C | `#CDF5E0` | `#2FBF71` |
| D | `#FFF1CC` | `#F5B731` |

State **selected**: border 1.5px `primary`, radio terisi `primary`.

### 2.5 Semantic / Status

| Token | Hex | Penggunaan |
|---|---|---|
| `success` | `#2FBF71` | Skor ≥ 70% |
| `warning` | `#FF9F43` | Skor 50–69% |
| `danger` | `#F0605D` | Skor < 50% |
| `info` | `#4B8DF8` | Informasi netral |

### 2.6 Text

| Token | Hex | Penggunaan |
|---|---|---|
| `textPrimary` | `#1B1C4B` | Judul, soal |
| `textSecondary` | `#5E6082` | Deskripsi, label |
| `textMuted` | `#9899B8` | Placeholder, grade non-aktif |
| `textOnDark` | `#FFFFFF` | Teks di header biru |

### 2.7 Grade Badge

| State | BG | Teks |
|---|---|---|
| Aktif | `#FFD54A` (kuning) | `#B8860B` |
| Non-aktif | `#E3E6FA` | `#9899B8` |

Label grade aktif ditulis warna `danger` (`#F0605D`), non-aktif `textMuted`.

---

## 3. Typography

**Font family:** `Outfit` (alternatif: `Urbanist`, `Plus Jakarta Sans`) via package `google_fonts`.

| Style | Size | Weight | Line Height | Penggunaan |
|---|---|---|---|---|
| `displayLarge` | 28 | 700 | 1.2 | Hero / angka skor besar |
| `headlineMedium` | 22 | 700 | 1.3 | Judul soal |
| `titleLarge` | 18 | 700 | 1.3 | Judul layar, nama user |
| `titleMedium` | 16 | 600 | 1.3 | Judul kategori / card |
| `bodyLarge` | 14 | 500 | 1.5 | Teks opsi jawaban |
| `bodyMedium` | 12 | 400 | 1.5 | Deskripsi card |
| `labelLarge` | 14 | 600 | 1.2 | Teks tombol |
| `labelMedium` | 11 | 600 | 1.2 | Chip / tag |
| `labelSmall` | 10 | 500 | 1.2 | Label bottom nav, grade, tanggal |

Aturan: judul **bold**, deskripsi **regular/light**, jangan lebih dari 3 ukuran font dalam satu card.

---

## 4. Spacing, Radius, Elevation

### 4.1 Spacing (kelipatan 4)

| Token | Nilai |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `xxl` | 32 |

- Padding layar horizontal: **20**
- Jarak antar card: **12–16**
- Padding dalam card: **16**

### 4.2 Border Radius

| Token | Nilai | Penggunaan |
|---|---|---|
| `radiusSm` | 8 | Badge huruf opsi, chip kecil |
| `radiusMd` | 12 | Opsi jawaban, input |
| `radiusLg` | 20 | Card kategori, card soal |
| `radiusXl` | 28 | Card "Recent Quiz" |
| `radiusHeader` | 32 (bawah saja) | Header melengkung |
| `radiusFull` | 999 | Chip, tombol pill, grade badge, nav highlight |

### 4.3 Elevation / Shadow

Gaya **soft shadow**, hampir tidak terlihat.

| Level | Shadow |
|---|---|
| `card` | `0 4px 16px rgba(46,47,209,0.08)` |
| `floating` | `0 8px 24px rgba(46,47,209,0.16)` |
| `button` | `0 4px 12px rgba(46,47,209,0.25)` |

---

## 5. Iconography & Illustration

- **Icon UI:** rounded, stroke 1.5–2px, ukuran 20–24. Rekomendasi: `Iconsax`, `Phosphor`, atau `Material Symbols Rounded`.
- **Ilustrasi kategori:** objek **3D clay/glossy** (pensil, penggaris, bola, topi toga, kalkulator). Sumber: 3dicons.co, Spline, Blush.
- Posisi ilustrasi: kanan-bawah card kategori, ukuran ± 72–96px, boleh sedikit keluar dari batas card (overlap) untuk kesan dinamis.
- **Logo/ikon header kanan:** kombinasi bentuk geometris (plus, lingkaran, segitiga, garis) sebagai brand mark.
- **Avatar:** karakter ilustrasi 3D bulat, ukuran 40px.

---

## 6. Components

### 6.1 Header Melengkung (Home & Profile)
- Background `primary`, radius bawah 32.
- Isi: avatar 40px, sapaan (`titleMedium` putih), subteks (`labelSmall` putih 80%), brand mark di kanan.
- Padding: top = safe area + 16, bottom 20.

### 6.2 Recent Quiz Card
- BG `primaryLight`, radius 28, padding 16.
- Chip "Recent Quiz" (BG putih 20%, teks putih, radius full).
- Judul quiz (`titleMedium` putih), skor (`bodyMedium` putih 80%).
- Ilustrasi 3D kuning di kanan.

### 6.3 Grade Selector
- Row horizontal scroll, item lingkaran 40px.
- Aktif: BG kuning `#FFD54A`, angka bold, label merah di bawah.
- Non-aktif: BG `#E3E6FA`, angka `textMuted`.
- Label: "1st Grade", "2nd Grade", dst (`labelSmall`).

### 6.4 Category Card
- Tinggi ± 120, radius 20, BG sesuai kategori.
- Kiri-atas: chip "Last 5 Success" (outline accent, BG transparan) + chip persen (BG accent, teks putih).
- Kanan-atas: ikon panah diagonal dalam kotak kecil (outline accent, radius 8).
- Kiri-bawah: judul kategori (`titleMedium`, warna teks kategori) + deskripsi 2 baris (`bodyMedium`, `textSecondary`).
- Kanan-bawah: ilustrasi 3D.

### 6.5 Chip / Tag
| Varian | Style |
|---|---|
| Outline | Border 1px accent, BG putih/transparan, teks accent, radius full, padding 8×4 |
| Filled | BG accent, teks putih, radius full |
- Teks `labelMedium`.

### 6.6 Quiz Header & Progress
- AppBar: back icon, judul "Algebra Practice Test" (`titleMedium` putih), brand mark kanan. BG `primary`, radius bawah 32.
- Progress soal: **segmented bar** (10 segmen, tinggi 4, gap 4, radius full). Terisi `primary`, kosong `outline`. Teks "10/10" kanan (`labelSmall`).

### 6.7 Question Card
- Judul soal `headlineMedium` `textPrimary`.
- Kontainer gambar/diagram: BG putih, radius 20, padding 16, shadow `card`.

### 6.8 Answer Option
- Row tinggi 48, radius 12, BG sesuai opsi (lihat 2.4).
- Kiri: badge huruf 24×24 radius 6, BG accent, teks putih.
- Tengah: teks jawaban `bodyLarge`.
- Kanan: radio button (outline `textMuted`; selected = isi `primary`).
- Selected: tambah border 1.5px `primary`.

### 6.9 Buttons
| Varian | Style |
|---|---|
| Primary | BG `primary`, teks putih, radius 14, tinggi 48, shadow `button` |
| Secondary/Soft | BG `#E3E6FA`, teks `primary`, radius 14, tinggi 48 |
- Layout kuis: **Previous (soft) kiri — Submit (primary) kanan**, lebar sama (Expanded), gap 12.
- Disabled: opacity 0.4.

### 6.10 Segmented Tab (Results / Personal Info)
- Kontainer putih radius full, padding 4.
- Tab aktif: BG putih + shadow tipis, tab tidak aktif: transparan, teks `textSecondary`.

### 6.11 Result List Item
- Card putih radius 20, di dalamnya chip "Last 5 Success" + persen, judul kategori, deskripsi.
- Tiap baris riwayat: tanggal (`labelSmall` bold), "9 out of 10 questions were right." (`labelSmall` `textSecondary`), di kanan **circular progress** 32px dengan persen di tengah.
- Warna ring: ≥70% `success`, 50–69% `warning`, <50% `danger`. Track: warna sama opacity 15%.
- Baris dibungkus BG `#F3F4FF` radius 12, padding 8×12, gap 8.

### 6.12 Bottom Navigation
- BG `surfaceTint`, radius atas 24, tinggi 64.
- 3 item: Home, Profile, Notifications (ikon + label `labelSmall`).
- Item aktif: highlight **pill** BG `#D9DBF5` radius 16, ikon & label `primary`, ada titik kecil indikator di bawah ikon.
- Item non-aktif: `textMuted`.

---

## 7. Screen Layouts

### 7.1 Home
```
[Header melengkung]
  Avatar + "Hello Anne!" + "Let's start your quiz now"          [brand mark]
  [Recent Quiz card]
[Grade selector: 1 2 3 4 5 6 →]
"Quiz Categories"  (titleMedium)
[Category card: Algebra]
[Category card: Geometry]
[Category card: ...]  (scroll)
[Bottom nav]
```

### 7.2 Quiz
```
[AppBar melengkung: ← Algebra Practice Test   [brand mark]]
[Segmented progress ........ 10/10]
"Work out the volume of the L-shaped prism:"
[Card diagram/gambar soal]
[Option A] [Option B] [Option C] [Option D]
[Previous]  [Submit]
```

### 7.3 Results / Profile
```
[Header melengkung: Avatar + nama + umur   [brand mark]]
[Segmented tab: Results | Personal Info]
[Grade selector]
[Card hasil per kategori
   chip + judul + deskripsi
   list riwayat (tanggal, ringkasan, ring persen)]
[Bottom nav]
```

---

## 8. Motion & Interaction

| Elemen | Animasi | Durasi |
|---|---|---|
| Pindah layar | Fade + slide horizontal kecil | 300ms, `easeOutCubic` |
| Tap card | Scale 0.97 | 120ms |
| Pilih opsi jawaban | Border + radio transisi halus | 150ms |
| Progress bar soal | Segmen terisi animasi lebar | 250ms |
| Ring persen | Sweep dari 0 ke nilai | 800ms, `easeOut` |
| Grade badge | Scale-up saat dipilih | 200ms |
| Hasil kuis benar | Konfeti ringan (opsional) | 1.2s |

Haptic feedback ringan saat memilih jawaban dan menekan Submit.

---

## 9. Accessibility

- Kontras teks minimal **4.5:1** (teks di atas card pastel gunakan `textPrimary`/warna teks kategori gelap).
- Jangan mengandalkan warna saja untuk status; tambahkan teks persen/ikon.
- Area sentuh minimal **48×48**.
- Dukung **text scale** hingga 1.3x tanpa overflow.
- Tambahkan `Semantics` pada opsi jawaban, ring persen, dan ikon nav.

---

## 10. Flutter Implementation

### 10.1 Struktur Folder

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_chip.dart
│       ├── category_card.dart
│       ├── answer_option.dart
│       ├── segmented_progress.dart
│       ├── score_ring.dart
│       ├── grade_selector.dart
│       └── curved_header.dart
├── features/
│   ├── home/
│   ├── quiz/
│   └── profile/
└── main.dart
```

### 10.2 Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  percent_indicator: ^4.2.3
  iconsax_flutter: ^1.0.0
  flutter_svg: ^2.0.10
```

### 10.3 `app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF2E2FD1);
  static const primaryLight = Color(0xFF4B4BE0);
  static const primaryDark = Color(0xFF2020A8);
  static const onPrimary = Colors.white;

  // Background & surface
  static const background = Color(0xFFF3F4FF);
  static const surface = Colors.white;
  static const surfaceTint = Color(0xFFEEF0FF);
  static const outline = Color(0xFFD9DBF5);

  // Text
  static const textPrimary = Color(0xFF1B1C4B);
  static const textSecondary = Color(0xFF5E6082);
  static const textMuted = Color(0xFF9899B8);

  // Semantic
  static const success = Color(0xFF2FBF71);
  static const warning = Color(0xFFFF9F43);
  static const danger = Color(0xFFF0605D);
  static const info = Color(0xFF4B8DF8);

  // Grade
  static const gradeActive = Color(0xFFFFD54A);
  static const gradeActiveText = Color(0xFFB8860B);
  static const gradeInactive = Color(0xFFE3E6FA);

  // Categories
  static const algebraBg = Color(0xFFE3E6FA);
  static const algebraAccent = Color(0xFF2E2FD1);
  static const geometryBg = Color(0xFFFFD9D9);
  static const geometryAccent = Color(0xFFF0605D);
  static const statsBg = Color(0xFFCDF5E0);
  static const statsAccent = Color(0xFF2FBF71);
  static const calculusBg = Color(0xFFFFF1CC);
  static const calculusAccent = Color(0xFFF5B731);

  static Color scoreColor(int percent) {
    if (percent >= 70) return success;
    if (percent >= 50) return warning;
    return danger;
  }
}
```

### 10.4 `app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500),
      );
}
```

### 10.5 `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`

```dart
import 'package:flutter/material.dart';

class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0, xxl = 32.0;
  static const screenH = 20.0;
}

class AppRadius {
  static const sm = 8.0, md = 12.0, lg = 20.0, xl = 28.0, full = 999.0;
  static const header = BorderRadius.only(
    bottomLeft: Radius.circular(32),
    bottomRight: Radius.circular(32),
  );
}

class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x142E2FD1), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const button = [
    BoxShadow(color: Color(0x402E2FD1), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
```

### 10.6 `app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gradeInactive,
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: AppTextStyles.textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        side: BorderSide.none,
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceTint,
        indicatorColor: AppColors.outline,
        height: 64,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStatePropertyAll(AppTextStyles.textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1),
    );
  }
}
```

### 10.7 Contoh Widget Inti

**Curved Header**

```dart
class CurvedHeader extends StatelessWidget {
  final Widget child;
  const CurvedHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.header,
      ),
      child: child,
    );
  }
}
```

**Category Card**

```dart
class CategoryCard extends StatelessWidget {
  final String title, description;
  final int percent;
  final Color bg, accent;
  final Widget illustration;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.percent,
    required this.bg,
    required this.accent,
    required this.illustration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Stack(
          children: [
            Row(children: [
              _Chip(label: 'Last 5 Success', color: accent, filled: false),
              const SizedBox(width: 6),
              _Chip(label: '$percent%', color: accent, filled: true),
            ]),
            Positioned(
              right: 0, top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: accent),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.north_east, size: 14, color: accent),
              ),
            ),
            Positioned(right: 0, bottom: 0, child: illustration),
            Positioned(
              left: 0, bottom: 0, right: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: accent)),
                  const SizedBox(height: 2),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  const _Chip({required this.label, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : Colors.white.withOpacity(0.6),
        border: filled ? null : Border.all(color: color),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: filled ? Colors.white : color,
              )),
    );
  }
}
```

**Answer Option**

```dart
class AnswerOption extends StatelessWidget {
  final String letter, text;
  final Color bg, accent;
  final bool selected;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.bg,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
            child: Text(letter,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
        ]),
      ),
    );
  }
}
```

**Segmented Progress**

```dart
class SegmentedProgress extends StatelessWidget {
  final int total, current;
  const SegmentedProgress({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Row(
          children: List.generate(total, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
              decoration: BoxDecoration(
                color: i < current ? AppColors.primary : AppColors.outline,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          )),
        ),
      ),
      const SizedBox(width: 8),
      Text('$current/$total', style: Theme.of(context).textTheme.labelSmall),
    ]);
  }
}
```

**Score Ring**

```dart
import 'package:percent_indicator/circular_percent_indicator.dart';

class ScoreRing extends StatelessWidget {
  final int percent;
  const ScoreRing({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(percent);
    return CircularPercentIndicator(
      radius: 16,
      lineWidth: 3,
      percent: percent / 100,
      animation: true,
      animationDuration: 800,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
      backgroundColor: color.withOpacity(0.15),
      center: Text('$percent%',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
```

**Grade Selector**

```dart
class GradeSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const GradeSelector({super.key, required this.selected, required this.onChanged});

  static const labels = ['1st', '2nd', '3rd', '4th', '5th', '6th'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final active = i + 1 == selected;
          return GestureDetector(
            onTap: () => onChanged(i + 1),
            child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40, height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.gradeActive : AppColors.gradeInactive,
                  shape: BoxShape.circle,
                ),
                child: Text('${i + 1}',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: active ? AppColors.gradeActiveText : AppColors.textMuted,
                    )),
              ),
              const SizedBox(height: 4),
              Text('${labels[i]} Grade',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: active ? AppColors.danger : AppColors.textMuted,
                      )),
            ]),
          );
        },
      ),
    );
  }
}
```

---

## 11. Do & Don't

| Do | Don't |
|---|---|
| Pakai radius besar konsisten (12–28) | Mencampur sudut tajam dan membulat |
| Satu warna pastel per kategori | Warna kategori yang saling bentrok |
| Soft shadow berwarna primary | Shadow hitam pekat |
| Ilustrasi 3D bergaya seragam | Campur flat icon dan 3D acak |
| Teks gelap di atas card pastel | Teks abu terang di atas pastel |
| Whitespace lega antar card | Card terlalu rapat |
| Status = warna + angka | Status hanya warna |

---

## 12. Checklist Implementasi

- [ ] Setup `AppColors`, `AppTextStyles`, `AppTheme`
- [ ] Pasang font Outfit via `google_fonts`
- [ ] Siapkan aset ilustrasi 3D (PNG/WebP, 2x/3x)
- [ ] Buat widget reusable (header, chip, category card, option, ring, progress)
- [ ] Susun layar Home, Quiz, Results
- [ ] Tambahkan animasi & haptic
- [ ] Uji kontras, text scale, dan ukuran layar kecil (360dp)
- [ ] (Opsional) Siapkan dark theme dengan token yang sama
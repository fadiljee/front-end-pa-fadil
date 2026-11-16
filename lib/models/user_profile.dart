/// Hasil login siswa yang dikembalikan oleh `POST /login`.
class LoginResult {
  const LoginResult({
    required this.token,
    required this.nama,
    required this.nisn,
    this.kelas,
  });

  final String token;
  final String nama;
  final String nisn;
  final String? kelas;
}

/// Model profil siswa dari `GET /user/profile`.
class SiswaProfile {
  const SiswaProfile({
    required this.nama,
    required this.nisn,
    this.kelas,
    this.profilePictureUrl,
    this.sekolah,
    this.alamat,
  });

  final String nama;
  final String nisn;
  final String? kelas;
  final String? profilePictureUrl;
  final String? sekolah;
  final String? alamat;

  factory SiswaProfile.fromJson(
    Map<String, dynamic> json, {
    String defaultNisn = '',
  }) {
    String? clean(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null') return null;
      return str;
    }

    return SiswaProfile(
      nama: clean(json['nama']) ?? 'Pengguna',
      nisn: clean(json['nisn']) ?? defaultNisn,
      kelas: clean(json['kelas']),
      profilePictureUrl: clean(json['profile_picture']),
      sekolah: clean(json['sekolah']),
      alamat: clean(json['alamat']),
    );
  }
}

/// Model statistik siswa dari `GET /user/stats`.
class UserStats {
  const UserStats({required this.totalSkor, this.gelar});

  final int totalSkor;
  final String? gelar;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final rawScore = json['total_skor'];
    final parsedScore =
        rawScore is int
            ? rawScore
            : int.tryParse(rawScore?.toString() ?? '0') ?? 0;
    final rawGelar = json['gelar']?.toString().trim();
    return UserStats(
      totalSkor: parsedScore,
      gelar: (rawGelar == null || rawGelar.isEmpty) ? null : rawGelar,
    );
  }
}

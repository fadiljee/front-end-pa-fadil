import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan sesi dan preferensi lokal yang menjadi satu sumber kebenaran
/// untuk identitas pengguna, progres materi, dan rekor skor permainan.
class SessionStore {
  SessionStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _tokenKey = 'token';
  static const String _userNameKey = 'userName';
  static const String _nisnKey = 'nisn';
  static const String _kelasKey = 'kelas';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Menyimpan data sesi pengguna setelah login berhasil.
  Future<void> saveSession({
    required String token,
    required String userName,
    required String nisn,
    String? kelas,
  }) async {
    final prefs = await _instance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_nisnKey, nisn);
    if (kelas != null && kelas.isNotEmpty) {
      await prefs.setString(_kelasKey, kelas);
    } else {
      await prefs.remove(_kelasKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await _instance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserName() async {
    final prefs = await _instance();
    return prefs.getString(_userNameKey);
  }

  Future<String?> getNisn() async {
    final prefs = await _instance();
    return prefs.getString(_nisnKey);
  }

  Future<String?> getKelas() async {
    final prefs = await _instance();
    return prefs.getString(_kelasKey);
  }

  /// Menghapus hanya kunci sesi agar data lain seperti `bestScore_<nisn>` tetap aman.
  Future<void> clearSession() async {
    final prefs = await _instance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_nisnKey);
    await prefs.remove(_kelasKey);
  }

  Future<List<int>> getUnlockedMateriIds(String nisn) async {
    final prefs = await _instance();
    final raw = prefs.getStringList('unlockedMateriIds_$nisn');
    if (raw == null || raw.isEmpty) return [1];
    return raw.map(int.tryParse).whereType<int>().toList();
  }

  Future<void> saveUnlockedMateriIds(String nisn, List<int> ids) async {
    final prefs = await _instance();
    await prefs.setStringList(
      'unlockedMateriIds_$nisn',
      ids.map((e) => e.toString()).toList(),
    );
  }

  Future<Set<int>> getCompletedMateriIds(String nisn) async {
    final prefs = await _instance();
    final raw = prefs.getStringList('completedMateriIds_$nisn') ?? [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> markMateriCompleted(String nisn, int materiId) async {
    final prefs = await _instance();
    final current = await getCompletedMateriIds(nisn);
    current.add(materiId);
    await prefs.setStringList(
      'completedMateriIds_$nisn',
      current.map((e) => e.toString()).toList(),
    );
  }

  Future<int> getBestScore(String nisn) async {
    final prefs = await _instance();
    return prefs.getInt('bestScore_$nisn') ?? 0;
  }

  Future<int> saveBestScoreIfBetter(String nisn, int score) async {
    final prefs = await _instance();
    final key = 'bestScore_$nisn';
    final current = prefs.getInt(key) ?? 0;
    if (current == 0 || score < current) {
      await prefs.setInt(key, score);
      return score;
    }
    return current;
  }
}

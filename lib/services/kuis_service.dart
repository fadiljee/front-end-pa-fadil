import '../models/materi.dart';
import 'api_client.dart';

export '../models/materi.dart' show UnlockMateriResult;

/// Layanan domain kuis (`GET /kuis/{id}`, `POST /hasil-kuis`, `POST /unlock-next-materi`).
class KuisService {
  KuisService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.shared;

  final ApiClient _apiClient;

  /// Mengambil daftar soal kuis. Mendukung format `kuis` berupa List maupun Map.
  Future<List<Map<String, dynamic>>> getKuis(int kuisId) async {
    final data = await _apiClient.get('/kuis/$kuisId');
    return parseKuisPayload(data);
  }

  /// Parser defensif yang menerima `data['kuis']` berbentuk `List` ataupun `Map`.
  static List<Map<String, dynamic>> parseKuisPayload(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Format data kuis tidak valid.');
    }
    final kuis = data['kuis'];
    if (kuis is List) {
      return kuis.whereType<Map<String, dynamic>>().toList();
    }
    if (kuis is Map<String, dynamic>) {
      return [kuis];
    }
    throw ApiException(message: 'Format data kuis tidak valid.');
  }

  /// Mengirimkan jawaban siswa (`a`–`d`) untuk satu soal.
  /// Mengembalikan map respons server (berguna juga untuk fase 2).
  Future<Map<String, dynamic>> submitJawaban({
    required int kuisId,
    required String jawabanUser,
  }) async {
    final normalized = jawabanUser.trim().toLowerCase();
    final data = await _apiClient.post(
      '/hasil-kuis',
      body: {'kuis_id': kuisId, 'jawaban_user': normalized},
    );
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  /// Meminta server mengevaluasi dan membuka materi berikutnya.
  Future<UnlockMateriResult> unlockNextMateri(int materiId) async {
    final data = await _apiClient.post(
      '/unlock-next-materi',
      body: {'materi_id': materiId},
    );
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ?? '';
      final unlocked =
          data['unlocked'] is bool ? data['unlocked'] as bool : true;
      return UnlockMateriResult(unlocked: unlocked, message: message);
    }
    return const UnlockMateriResult(unlocked: false, message: '');
  }
}

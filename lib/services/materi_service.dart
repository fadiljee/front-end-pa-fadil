import '../models/materi.dart';
import 'api_client.dart';

export '../models/materi.dart' show MateriDetail;

/// Layanan domain materi (`GET /materi`, `GET /materi-unlock`, `GET /materi/{id}`).
class MateriService {
  MateriService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.shared;

  final ApiClient _apiClient;

  /// Mengambil seluruh daftar materi dan mengurutkannya berdasarkan `id` menaik.
  Future<List<Map<String, dynamic>>> getMateriList() async {
    final data = await _apiClient.get('/materi');
    if (data is! List) {
      throw ApiException(message: 'Format daftar materi tidak valid.');
    }
    final list = data.whereType<Map<String, dynamic>>().toList();
    list.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    return list;
  }

  /// Mengambil daftar ID materi yang sudah terbuka untuk siswa saat ini.
  Future<List<int>> getUnlockedMateriIds() async {
    final data = await _apiClient.get('/materi-unlock');
    if (data is! Map<String, dynamic>) {
      return [1];
    }
    final raw = data['unlocked_materi_ids'];
    if (raw is! List) return [1];
    return raw.map((e) => int.tryParse(e.toString())).whereType<int>().toList();
  }

  /// Mengambil detail konten materi berdasarkan [materiId].
  Future<MateriDetail> getMateriDetail(int materiId) async {
    final data = await _apiClient.get('/materi/$materiId');
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Format detail materi tidak valid.');
    }
    return MateriDetail(
      konten: data['konten']?.toString() ?? 'Konten tidak tersedia.',
      gambarUrl: data['gambar_url']?.toString(),
    );
  }
}

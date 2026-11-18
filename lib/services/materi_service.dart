import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/session_store.dart';
import '../models/materi.dart';

export '../models/materi.dart' show MateriDetail;

/// Layanan domain materi berbasis Supabase (`materi`, `materi_unlock`).
class MateriService {
  MateriService({SupabaseClient? client, SessionStore? sessionStore})
    : _client = client,
      _sessionStore = sessionStore ?? SessionStore();

  final SupabaseClient? _client;
  final SessionStore _sessionStore;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Mengambil seluruh daftar materi dan mengurutkannya berdasarkan `id` menaik.
  Future<List<Map<String, dynamic>>> getMateriList() async {
    try {
      final rows = await _supabase
          .from('materi')
          .select('id, judul')
          .order('id', ascending: true)
          .timeout(SupabaseConfig.requestTimeout);

      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  /// Mengambil daftar ID materi yang sudah terbuka untuk siswa saat ini.
  Future<List<int>> getUnlockedMateriIds() async {
    try {
      final siswaId = await _sessionStore.getSiswaId();
      if (siswaId == null) return [1];

      final rows = await _supabase
          .from('materi_unlock')
          .select('materi_id')
          .eq('siswa_id', siswaId)
          .timeout(SupabaseConfig.requestTimeout);

      final ids =
          (rows as List)
              .map((row) => int.tryParse(row['materi_id']?.toString() ?? ''))
              .whereType<int>()
              .toSet();
      ids.add(1);
      final sorted = ids.toList()..sort();
      return sorted;
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  /// Mengambil detail konten materi berdasarkan [materiId].
  Future<MateriDetail> getMateriDetail(int materiId) async {
    try {
      final data = await _supabase
          .from('materi')
          .select('konten, gambar_url')
          .eq('id', materiId)
          .maybeSingle()
          .timeout(SupabaseConfig.requestTimeout);

      if (data == null) {
        throw const AppException(
          statusCode: 404,
          message: 'Materi tidak ditemukan.',
        );
      }

      return MateriDetail(
        konten: data['konten']?.toString() ?? 'Konten tidak tersedia.',
        gambarUrl: data['gambar_url']?.toString(),
      );
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/session_store.dart';
import '../models/user_profile.dart';

export '../models/user_profile.dart' show SiswaProfile, UserStats;

/// Layanan domain pengguna berbasis Supabase (`siswa`, `hasil_kuis`).
class UserService {
  UserService({SupabaseClient? client, SessionStore? sessionStore})
    : _client = client,
      _sessionStore = sessionStore ?? SessionStore();

  final SupabaseClient? _client;
  final SessionStore _sessionStore;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<SiswaProfile> getProfile({String defaultNisn = ''}) async {
    try {
      final storedNisn = await _sessionStore.getNisn();
      final nisn =
          (storedNisn != null && storedNisn.isNotEmpty)
              ? storedNisn
              : defaultNisn;

      final data = await _supabase
          .from('siswa')
          .select('nama, nisn, kelas, sekolah, alamat, profile_picture')
          .eq('nisn', nisn)
          .maybeSingle()
          .timeout(SupabaseConfig.requestTimeout);

      if (data == null) {
        throw const AppException(
          statusCode: 404,
          message: 'Data siswa tidak ditemukan.',
        );
      }

      return SiswaProfile.fromJson(data, defaultNisn: nisn);
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  Future<UserStats> getStats() async {
    try {
      final siswaId = await _sessionStore.getSiswaId();
      if (siswaId == null) {
        return UserStats(totalSkor: 0, gelar: UserStats.computeGelar(0));
      }

      final rows = await _supabase
          .from('hasil_kuis')
          .select('skor')
          .eq('siswa_id', siswaId)
          .timeout(SupabaseConfig.requestTimeout);

      final totalSkor = (rows as List).fold<int>(
        0,
        (sum, row) => sum + (row['skor'] as int? ?? 0),
      );

      return UserStats(
        totalSkor: totalSkor,
        gelar: UserStats.computeGelar(totalSkor),
      );
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }
}

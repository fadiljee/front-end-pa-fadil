import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/session_store.dart';
import '../models/user_profile.dart';

export '../models/user_profile.dart' show LoginResult;

/// Layanan domain autentikasi siswa berbasis Supabase (`siswa` table).
class AuthService {
  AuthService({SupabaseClient? client, SessionStore? sessionStore})
    : _client = client,
      _sessionStore = sessionStore ?? SessionStore();

  final SupabaseClient? _client;
  final SessionStore _sessionStore;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Melakukan login menggunakan NISN pada tabel `siswa` dan menyimpan sesi ke [SessionStore].
  Future<LoginResult> login(String nisn) async {
    try {
      final data = await _supabase
          .from('siswa')
          .select('id, nama, nisn, kelas')
          .eq('nisn', nisn)
          .maybeSingle()
          .timeout(SupabaseConfig.requestTimeout);

      if (data == null) {
        throw const AppException(
          statusCode: 404,
          message: 'NISN tidak terdaftar.',
        );
      }

      final siswaId = data['id'] as int?;
      final nama = data['nama']?.toString() ?? 'Siswa';
      final nisnResp = data['nisn']?.toString() ?? nisn;
      final kelas = data['kelas']?.toString();
      final token =
          _supabase.auth.currentSession?.accessToken ?? 'supabase-$nisnResp';

      await _sessionStore.saveSession(
        siswaId: siswaId,
        token: token,
        userName: nama,
        nisn: nisnResp,
        kelas: kelas,
      );

      return LoginResult(
        siswaId: siswaId,
        token: token,
        nama: nama,
        nisn: nisnResp,
        kelas: kelas,
      );
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  /// Keluar dari sesi Supabase (jika ada) dan membersihkan hanya kunci sesi lokal.
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Tetap lanjut membersihkan sesi lokal meskipun signOut auth tidak aktif.
    }
    await _sessionStore.clearSession();
  }
}

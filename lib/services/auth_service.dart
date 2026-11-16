import '../core/storage/session_store.dart';
import '../models/user_profile.dart';
import 'api_client.dart';

export '../models/user_profile.dart' show LoginResult;

/// Layanan domain autentikasi siswa (`POST /login`, `POST /logout`).
class AuthService {
  AuthService({ApiClient? apiClient, SessionStore? sessionStore})
    : _apiClient = apiClient ?? ApiClient.shared,
      _sessionStore = sessionStore ?? SessionStore();

  final ApiClient _apiClient;
  final SessionStore _sessionStore;

  /// Melakukan login menggunakan NISN dan menyimpan sesi ke [SessionStore].
  Future<LoginResult> login(String nisn) async {
    final data = await _apiClient.post(
      '/login',
      body: {'nisn': nisn},
      includeAuth: false,
    );

    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Format respons login tidak valid.');
    }

    final token = data['token']?.toString() ?? '';
    final siswa = data['data_siswa'] as Map<String, dynamic>? ?? {};
    final nama = siswa['nama']?.toString() ?? 'Siswa';
    final nisnResp = siswa['nisn']?.toString() ?? nisn;
    final kelas = siswa['kelas']?.toString();

    if (token.isEmpty) {
      throw ApiException(message: 'Token autentikasi tidak ditemukan.');
    }

    await _sessionStore.saveSession(
      token: token,
      userName: nama,
      nisn: nisnResp,
      kelas: kelas,
    );

    return LoginResult(token: token, nama: nama, nisn: nisnResp, kelas: kelas);
  }

  /// Menghapus token di server (opsional) dan membersihkan hanya kunci sesi lokal.
  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (_) {
      // Logout lokal tetap dilanjutkan meskipun endpoint logout opsional tidak tersedia.
    }
    await _sessionStore.clearSession();
  }
}

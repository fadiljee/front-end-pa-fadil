import '../models/user_profile.dart';
import 'api_client.dart';

export '../models/user_profile.dart' show SiswaProfile, UserStats;

/// Layanan domain pengguna (`GET /user/profile`, `GET /user/stats`).
class UserService {
  UserService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.shared;

  final ApiClient _apiClient;

  Future<SiswaProfile> getProfile({String defaultNisn = ''}) async {
    final data = await _apiClient.get('/user/profile');
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Format profil tidak valid.');
    }
    final payload =
        data['data_siswa'] is Map<String, dynamic>
            ? data['data_siswa'] as Map<String, dynamic>
            : data;
    return SiswaProfile.fromJson(payload, defaultNisn: defaultNisn);
  }

  Future<UserStats> getStats() async {
    final data = await _apiClient.get('/user/stats');
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Format statistik tidak valid.');
    }
    return UserStats.fromJson(data);
  }
}

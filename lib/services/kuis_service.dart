import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/session_store.dart';
import '../models/materi.dart';

export '../models/materi.dart' show UnlockMateriResult;

/// Layanan domain kuis berbasis Supabase (`kuis`, `hasil_kuis`, `materi_unlock`, `materi`).
class KuisService {
  KuisService({SupabaseClient? client, SessionStore? sessionStore})
    : _client = client,
      _sessionStore = sessionStore ?? SessionStore();

  final SupabaseClient? _client;
  final SessionStore _sessionStore;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Mengambil daftar soal kuis berdasarkan `materi_id`.
  Future<List<Map<String, dynamic>>> getKuis(int kuisId) async {
    try {
      final rows = await _supabase
          .from('kuis')
          .select()
          .eq('materi_id', kuisId)
          .order('id', ascending: true)
          .timeout(SupabaseConfig.requestTimeout);

      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  /// Parser defensif yang menerima payload berbentuk `List` ataupun `Map['kuis']`.
  static List<Map<String, dynamic>> parseKuisPayload(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final kuis = data['kuis'];
      if (kuis is List) {
        return kuis.whereType<Map<String, dynamic>>().toList();
      }
      if (kuis is Map<String, dynamic>) {
        return [kuis];
      }
    }
    throw const AppException(message: 'Format data kuis tidak valid.');
  }

  /// Menyimpan jawaban siswa (`a`–`d`) ke tabel `hasil_kuis` secara idempoten (upsert).
  Future<Map<String, dynamic>> submitJawaban({
    required int kuisId,
    required String jawabanUser,
  }) async {
    try {
      final siswaId = await _sessionStore.getSiswaId();
      if (siswaId == null) {
        throw const AppException(
          statusCode: 401,
          message: 'Sesi berakhir, silakan masuk lagi.',
          isUnauthorized: true,
        );
      }

      final normalized = jawabanUser.trim().toLowerCase();
      final soal = await _supabase
          .from('kuis')
          .select('jawaban_benar, nilai, pembahasan')
          .eq('id', kuisId)
          .maybeSingle()
          .timeout(SupabaseConfig.requestTimeout);

      final benar =
          soal?['jawaban_benar']?.toString().toLowerCase() == normalized;
      final nilai = soal?['nilai'] as int? ?? 10;
      final skor = benar ? nilai : 0;

      await _supabase
          .from('hasil_kuis')
          .upsert({
            'siswa_id': siswaId,
            'kuis_id': kuisId,
            'jawaban_user': normalized,
            'skor': skor,
          }, onConflict: 'siswa_id,kuis_id')
          .timeout(SupabaseConfig.requestTimeout);

      return {
        'benar': benar,
        'skor': skor,
        'pembahasan': soal?['pembahasan']?.toString() ?? '',
      };
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }

  /// Mengevaluasi nilai pada Supabase dan membuka materi berikutnya bila memenuhi syarat (>= 70%).
  Future<UnlockMateriResult> unlockNextMateri(int materiId) async {
    try {
      final siswaId = await _sessionStore.getSiswaId();
      if (siswaId == null) {
        return const UnlockMateriResult(unlocked: false, message: '');
      }

      final soalList = await _supabase
          .from('kuis')
          .select('id, nilai')
          .eq('materi_id', materiId)
          .timeout(SupabaseConfig.requestTimeout);

      final soalRows = List<Map<String, dynamic>>.from(soalList);
      if (soalRows.isEmpty) {
        return const UnlockMateriResult(unlocked: false, message: '');
      }

      final kuisIds = soalRows.map((e) => e['id'] as int).toList();
      final maxSkor = soalRows.fold<int>(
        0,
        (sum, item) => sum + (item['nilai'] as int? ?? 10),
      );

      final hasilList = await _supabase
          .from('hasil_kuis')
          .select('skor')
          .eq('siswa_id', siswaId)
          .inFilter('kuis_id', kuisIds)
          .timeout(SupabaseConfig.requestTimeout);

      final totalSkor = (hasilList as List).fold<int>(
        0,
        (sum, item) => sum + (item['skor'] as int? ?? 0),
      );
      final percentage = maxSkor > 0 ? (totalSkor / maxSkor) * 100 : 0.0;

      if (percentage < 70) {
        return const UnlockMateriResult(
          unlocked: false,
          message: 'Skor belum mencapai 70% untuk membuka materi berikutnya.',
        );
      }

      final nextMateri = await _supabase
          .from('materi')
          .select('id')
          .gt('id', materiId)
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle()
          .timeout(SupabaseConfig.requestTimeout);

      if (nextMateri == null) {
        return const UnlockMateriResult(
          unlocked: true,
          message: 'Selamat! Semua materi telah diselesaikan.',
        );
      }

      final nextId = nextMateri['id'] as int;
      await _supabase
          .from('materi_unlock')
          .upsert({
            'siswa_id': siswaId,
            'materi_id': nextId,
          }, onConflict: 'siswa_id,materi_id')
          .timeout(SupabaseConfig.requestTimeout);

      return const UnlockMateriResult(
        unlocked: true,
        message: 'Materi berikutnya terbuka!',
      );
    } catch (e) {
      throw await AppException.fromError(e, sessionStore: _sessionStore);
    }
  }
}

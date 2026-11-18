import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ayobitung/core/errors/app_exception.dart';
import 'package:ayobitung/core/storage/session_store.dart';
import 'package:ayobitung/features/auth/name_input_screen.dart';
import 'package:ayobitung/features/profile/profile_screen.dart';
import 'package:ayobitung/features/quiz/quiz_result_screen.dart';
import 'package:ayobitung/main.dart';
import 'package:ayobitung/services/kuis_service.dart';
import 'package:ayobitung/services/user_service.dart';

class _FailingUserService extends UserService {
  _FailingUserService();

  @override
  Future<SiswaProfile> getProfile({String defaultNisn = ''}) async {
    throw const AppException(
      message: 'Periksa koneksi internet Anda, lalu coba lagi.',
      isNetworkError: true,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Unit Tests - SessionStore', () {
    test(
      'clearSession menghapus kunci sesi namun mempertahankan bestScore_<nisn>',
      () async {
        final store = SessionStore();
        await store.saveSession(
          siswaId: 42,
          token: 'tok-123',
          userName: 'Budi',
          nisn: '1234567890',
          kelas: 'IX A',
        );
        await store.saveBestScoreIfBetter('1234567890', 7);

        expect(await store.getSiswaId(), 42);

        await store.clearSession();

        expect(await store.getSiswaId(), isNull);
        expect(await store.getToken(), isNull);
        expect(await store.getUserName(), isNull);
        expect(await store.getNisn(), isNull);
        expect(await store.getKelas(), isNull);
        expect(await store.getBestScore('1234567890'), 7);
      },
    );
  });

  group('Unit Tests - AppException (Supabase)', () {
    test(
      '401 PostgrestException membersihkan sesi dan memanggil onUnauthorized',
      () async {
        final store = SessionStore();
        await store.saveSession(
          siswaId: 1,
          token: 'expired-token',
          userName: 'Ani',
          nisn: '0987654321',
        );

        bool redirected = false;
        final ex = await AppException.fromError(
          const PostgrestException(message: 'JWT expired', code: 'PGRST301'),
          sessionStore: store,
          onUnauthorized: () => redirected = true,
        );

        expect(ex.isUnauthorized, true);
        expect(ex.statusCode, 401);
        expect(redirected, true);
        expect(await store.getToken(), isNull);
      },
    );

    test(
      'memetakan PostgrestException PGRST116, AuthException, dan TimeoutException',
      () async {
        final notFound = await AppException.fromError(
          const PostgrestException(message: 'Row not found', code: 'PGRST116'),
        );
        expect(notFound.statusCode, 404);
        expect(notFound.message, 'Data tidak ditemukan.');

        final authErr = await AppException.fromError(
          const AuthException('Invalid credentials', statusCode: '400'),
        );
        expect(authErr.statusCode, 400);
        expect(authErr.message, 'Invalid credentials');

        final timeoutErr = await AppException.fromError(
          TimeoutException('timeout'),
        );
        expect(timeoutErr.isNetworkError, true);
      },
    );
  });

  group('Unit Tests - KuisService & UserStats', () {
    test('parseKuisPayload mendukung format List maupun Map', () {
      final fromDirectList = KuisService.parseKuisPayload([
        {'id': 1, 'pertanyaan': '1+1?'},
      ]);
      expect(fromDirectList.length, 1);

      final fromList = KuisService.parseKuisPayload({
        'kuis': [
          {'id': 1, 'pertanyaan': '1+1?'},
        ],
      });
      expect(fromList.length, 1);
      expect(fromList.first['id'], 1);

      final fromMap = KuisService.parseKuisPayload({
        'kuis': {'id': 2, 'pertanyaan': '2+2?'},
      });
      expect(fromMap.length, 1);
      expect(fromMap.first['id'], 2);
    });

    test('UserStats.computeGelar mengembalikan gelar sesuai skor', () {
      expect(UserStats.computeGelar(90), 'Master Matematika');
      expect(UserStats.computeGelar(65), 'Pejuang Hebat');
      expect(UserStats.computeGelar(45), 'Pembelajar Aktif');
      expect(UserStats.computeGelar(10), 'Pemula');
    });
  });

  group('Widget Tests', () {
    testWidgets('WelcomeScreen menampilkan judul sambutan dan tombol mulai', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SELAMAT DATANG!'), findsOneWidget);
      expect(find.text('Mulai Sekarang'), findsOneWidget);
    });

    testWidgets('NameInputScreen memvalidasi NISN kosong dan < 10 digit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: NameInputScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verifikasi'));
      await tester.pump();
      expect(find.text('NISN tidak boleh kosong'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Verifikasi'));
      await tester.pump();
      expect(find.text('NISN harus minimal 10 digit'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets(
      'QuizResultScreen menampilkan kategori skor dan pesan unlock server',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuizResultScreen(
              kuisData: [
                {
                  'pertanyaan': '2 + 2 = ?',
                  'jawaban_benar': 'a',
                  'jawaban_user': 'a',
                  'skor': 10,
                  'pembahasan': '2 + 2 = 4',
                  'materi_id': 1,
                },
              ],
              unlockResult: UnlockMateriResult(
                unlocked: true,
                message: 'Materi berikutnya terbuka!',
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Luar Biasa!'), findsOneWidget);
        expect(find.text('Materi berikutnya terbuka!'), findsOneWidget);
        expect(find.text('Kembali ke Beranda'), findsOneWidget);
      },
    );

    testWidgets(
      'ProfileScreen menampilkan error state tanpa data dummy saat gagal',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProfileScreen(
              nisn: '1234567890',
              userService: _FailingUserService(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Oops! Terjadi Kesalahan'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
        expect(find.text('Siswa Contoh'), findsNothing);
        expect(find.text('Pejuang Hebat'), findsNothing);
      },
    );
  });
}

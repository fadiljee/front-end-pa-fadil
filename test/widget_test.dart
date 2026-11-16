import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ayobitung/core/storage/session_store.dart';
import 'package:ayobitung/features/auth/name_input_screen.dart';
import 'package:ayobitung/features/profile/profile_screen.dart';
import 'package:ayobitung/features/quiz/quiz_result_screen.dart';
import 'package:ayobitung/main.dart';
import 'package:ayobitung/services/api_client.dart';
import 'package:ayobitung/services/kuis_service.dart';
import 'package:ayobitung/services/user_service.dart';

class _FailingUserService extends UserService {
  _FailingUserService() : super(apiClient: ApiClient());

  @override
  Future<SiswaProfile> getProfile({String defaultNisn = ''}) async {
    throw ApiException(
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
          token: 'tok-123',
          userName: 'Budi',
          nisn: '1234567890',
          kelas: 'IX A',
        );
        await store.saveBestScoreIfBetter('1234567890', 7);

        await store.clearSession();

        expect(await store.getToken(), isNull);
        expect(await store.getUserName(), isNull);
        expect(await store.getNisn(), isNull);
        expect(await store.getKelas(), isNull);
        expect(await store.getBestScore('1234567890'), 7);
      },
    );
  });

  group('Unit Tests - ApiClient', () {
    test(
      'menyertakan header Authorization, Accept, dan X-App-Version',
      () async {
        final store = SessionStore();
        await store.saveSession(
          token: 'abc-token',
          userName: 'Ani',
          nisn: '0987654321',
        );

        late Map<String, String> capturedHeaders;
        final mockClient = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(jsonEncode({'ok': true}), 200);
        });

        final client = ApiClient(client: mockClient, sessionStore: store);
        final res = await client.get('/materi');

        expect(res['ok'], true);
        expect(capturedHeaders['Authorization'], 'Bearer abc-token');
        expect(capturedHeaders['Accept'], 'application/json');
        expect(capturedHeaders['X-App-Version'], isNotEmpty);
      },
    );

    test('401 membersihkan sesi dan memanggil onUnauthorized', () async {
      final store = SessionStore();
      await store.saveSession(
        token: 'expired-token',
        userName: 'Ani',
        nisn: '0987654321',
      );

      bool redirected = false;
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
      });

      final client = ApiClient(
        client: mockClient,
        sessionStore: store,
        onUnauthorized: () => redirected = true,
      );

      await expectLater(
        () => client.get('/user/profile'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isUnauthorized,
            'isUnauthorized',
            true,
          ),
        ),
      );
      expect(redirected, true);
      expect(await store.getToken(), isNull);
    });

    test('memetakan status 422, 404, dan 500 secara seragam', () async {
      final store = SessionStore();
      final client422 = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'errors': {
                'nisn': ['NISN tidak ditemukan'],
              },
            }),
            422,
          ),
        ),
        sessionStore: store,
      );
      await expectLater(
        () => client422.post(
          '/login',
          body: {'nisn': '0000000000'},
          includeAuth: false,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'NISN tidak ditemukan',
          ),
        ),
      );

      final client404 = ApiClient(
        client: MockClient((_) async => http.Response('', 404)),
        sessionStore: store,
      );
      await expectLater(
        () => client404.get('/materi/999'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );

      final client500 = ApiClient(
        client: MockClient((_) async => http.Response('', 500)),
        sessionStore: store,
      );
      await expectLater(
        () => client500.get('/materi'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('melakukan 1 kali retry otomatis pada GET ketika timeout', () async {
      final store = SessionStore();
      int attempts = 0;
      final mockClient = MockClient((request) async {
        attempts++;
        if (attempts == 1) {
          throw TimeoutException('timeout');
        }
        return http.Response(jsonEncode({'retried': true}), 200);
      });

      final client = ApiClient(client: mockClient, sessionStore: store);
      final res = await client.get('/materi', includeAuth: false);

      expect(attempts, 2);
      expect(res['retried'], true);
    });
  });

  group('Unit Tests - KuisService', () {
    test('parseKuisPayload mendukung format List maupun Map', () {
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

      // Bersihkan timer auto-hide error 3 detik agar tidak pending saat teardown
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets(
      'QuizResultScreen menampilkan kategori skor dan pesan unlock server',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: QuizResultScreen(
              kuisData: const [
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
                message: 'Materi berikutnya terbuka',
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(find.text('Luar Biasa!'), findsOneWidget);
        expect(find.text('Materi berikutnya terbuka'), findsOneWidget);
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

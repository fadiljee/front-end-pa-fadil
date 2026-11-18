import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../navigation/navigator_key.dart';
import '../storage/session_store.dart';
import '../../features/auth/name_input_screen.dart';

/// Exception seragam untuk seluruh error Supabase, timeout, dan jaringan.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.isNetworkError = false,
    this.isUnauthorized = false,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isUnauthorized;

  @override
  String toString() => message;

  /// Memetakan berbagai exception jaringan/Supabase ke [AppException] yang ramah pengguna.
  static Future<AppException> fromError(
    Object error, {
    SessionStore? sessionStore,
    VoidCallback? onUnauthorized,
  }) async {
    if (error is AppException) return error;

    if (error is TimeoutException || error is SocketException) {
      return const AppException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    }

    if (error is PostgrestException) {
      final code = int.tryParse(error.code ?? '');
      if (error.code == '401' || error.code == 'PGRST301') {
        await (sessionStore ?? SessionStore()).clearSession();
        _redirectToLogin(onUnauthorized);
        return const AppException(
          statusCode: 401,
          message: 'Sesi berakhir, silakan masuk lagi.',
          isUnauthorized: true,
        );
      }
      if (error.code == 'PGRST116') {
        return const AppException(
          statusCode: 404,
          message: 'Data tidak ditemukan.',
        );
      }
      return AppException(
        statusCode: code,
        message:
            error.message.isNotEmpty
                ? error.message
                : 'Terjadi kesalahan pada database Supabase.',
      );
    }

    if (error is AuthException) {
      final status = int.tryParse(error.statusCode ?? '');
      if (status == 401) {
        await (sessionStore ?? SessionStore()).clearSession();
        _redirectToLogin(onUnauthorized);
        return const AppException(
          statusCode: 401,
          message: 'Sesi berakhir, silakan masuk lagi.',
          isUnauthorized: true,
        );
      }
      return AppException(statusCode: status, message: error.message);
    }

    return AppException(message: error.toString());
  }

  static bool _isRedirecting = false;

  static void _redirectToLogin(VoidCallback? onUnauthorized) {
    if (onUnauthorized != null) {
      onUnauthorized();
      return;
    }
    final nav = appNavigatorKey.currentState;
    if (nav == null || _isRedirecting) return;
    _isRedirecting = true;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (_) => const NameInputScreen(
              initialMessage: 'Sesi berakhir, silakan masuk lagi.',
            ),
      ),
      (route) => false,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _isRedirecting = false;
    });
  }
}

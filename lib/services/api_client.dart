import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/navigation/navigator_key.dart';
import '../core/storage/session_store.dart';
import '../features/auth/name_input_screen.dart';

/// Exception seragam untuk seluruh error HTTP, timeout, dan jaringan.
class ApiException implements Exception {
  ApiException({
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
}

/// Pembungkus HTTP terpusat yang menangani header otorisasi, timeout seragam,
/// retry otomatis untuk `GET`, dan pemetaan error/401 secara konsisten.
class ApiClient {
  ApiClient({
    http.Client? client,
    SessionStore? sessionStore,
    VoidCallback? onUnauthorized,
    Duration? timeout,
  }) : _client = client ?? http.Client(),
       _sessionStore = sessionStore ?? SessionStore(),
       _onUnauthorized = onUnauthorized,
       _timeout = timeout ?? ApiConfig.requestTimeout;

  static final ApiClient shared = ApiClient();

  final http.Client _client;
  final SessionStore _sessionStore;
  final VoidCallback? _onUnauthorized;
  final Duration _timeout;

  bool _isRedirectingToLogin = false;

  Future<Map<String, String>> _buildHeaders({
    bool includeAuth = true,
    bool isJsonBody = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-App-Version': ApiConfig.appVersion,
    };
    if (isJsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (includeAuth) {
      final token = await _sessionStore.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Melakukan HTTP `GET` dengan 1 kali retry otomatis jika gagal karena jaringan/timeout.
  Future<dynamic> get(String path, {bool includeAuth = true}) async {
    final uri = ApiConfig.endpoint(path);
    final headers = await _buildHeaders(includeAuth: includeAuth);

    http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(_timeout);
    } on TimeoutException {
      response = await _retryGet(uri, headers);
    } on SocketException {
      response = await _retryGet(uri, headers);
    } on http.ClientException {
      response = await _retryGet(uri, headers);
    }

    return _handleResponse(response, handleUnauthorized: includeAuth);
  }

  Future<http.Response> _retryGet(Uri uri, Map<String, String> headers) async {
    try {
      return await _client.get(uri, headers: headers).timeout(_timeout);
    } on TimeoutException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    } on SocketException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    }
  }

  /// Melakukan HTTP `POST` dengan body JSON.
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = ApiConfig.endpoint(path);
    final headers = await _buildHeaders(
      includeAuth: includeAuth,
      isJsonBody: true,
    );

    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout);
      return _handleResponse(response, handleUnauthorized: includeAuth);
    } on TimeoutException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    } on SocketException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        isNetworkError: true,
      );
    }
  }

  Future<dynamic> _handleResponse(
    http.Response response, {
    required bool handleUnauthorized,
  }) async {
    final status = response.statusCode;
    final decoded = _tryDecodeJson(response.body);

    if (status >= 200 && status < 300) {
      return decoded;
    }

    if (status == 401) {
      if (handleUnauthorized) {
        await _sessionStore.clearSession();
        _triggerUnauthorizedRedirect();
      }
      throw ApiException(
        statusCode: 401,
        message: 'Sesi berakhir, silakan masuk lagi.',
        isUnauthorized: true,
      );
    }

    if (status == 422) {
      throw ApiException(
        statusCode: 422,
        message:
            _extractValidationMessage(decoded) ??
            'Data yang dikirim tidak valid.',
      );
    }

    if (status == 404) {
      throw ApiException(
        statusCode: 404,
        message: _extractMessage(decoded) ?? 'Data tidak ditemukan.',
      );
    }

    if (status >= 500) {
      throw ApiException(
        statusCode: status,
        message: 'Server bermasalah, coba lagi nanti.',
      );
    }

    throw ApiException(
      statusCode: status,
      message:
          _extractMessage(decoded) ?? 'Terjadi kesalahan (status $status).',
    );
  }

  dynamic _tryDecodeJson(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final msg = decoded['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
    return null;
  }

  String? _extractValidationMessage(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return null;
    final errors = decoded['errors'];
    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      final firstVal = errors.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      if (firstVal is String && firstVal.isNotEmpty) {
        return firstVal;
      }
    }
    return _extractMessage(decoded);
  }

  void _triggerUnauthorizedRedirect() {
    if (_onUnauthorized != null) {
      _onUnauthorized();
      return;
    }
    final nav = appNavigatorKey.currentState;
    if (nav == null || _isRedirectingToLogin) return;
    _isRedirectingToLogin = true;
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
      _isRedirectingToLogin = false;
    });
  }
}

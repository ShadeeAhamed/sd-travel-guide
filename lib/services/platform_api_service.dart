import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_models.dart';
import '../models/user_profile_model.dart';

class PlatformApiException implements Exception {
  final String message;
  final bool allowLocalFallback;

  const PlatformApiException(
    this.message, {
    this.allowLocalFallback = false,
  });

  @override
  String toString() => message;
}

class PlatformApiService {
  PlatformApiService._();

  static final PlatformApiService instance = PlatformApiService._();

  static const String baseUrl = String.fromEnvironment(
    'SD_PLATFORM_API_URL',
    defaultValue: '',
  );

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final json = await _sendJson(
      'POST',
      '/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return OtpChallenge.fromApiJson(json, purpose: OtpPurpose.signUp);
  }

  Future<OtpChallenge> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final json = await _sendJson(
      'POST',
      '/auth/login/email',
      body: {
        'email': email,
        'password': password,
      },
    );
    return OtpChallenge.fromApiJson(json, purpose: OtpPurpose.login);
  }

  Future<OtpChallenge> requestPhoneOtp(String phone) async {
    final json = await _sendJson(
      'POST',
      '/auth/login/phone',
      body: {'phone': phone},
    );
    return OtpChallenge.fromApiJson(json, purpose: OtpPurpose.login);
  }

  Future<AppUser> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _sendJson(
      'POST',
      '/auth/verify-otp',
      body: {
        'challengeId': challengeId,
        'code': code,
      },
    );
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw const PlatformApiException('The platform login response was incomplete.');
    }
    return AppUser.fromApiJson(user);
  }

  Future<AppUser> updatePreferences({
    required String userId,
    required TravelerPreferences preferences,
  }) async {
    final json = await _sendJson(
      'PUT',
      '/profile/preferences',
      body: {
        'userId': userId,
        'preferences': preferences.toJson(),
      },
    );
    return AppUser.fromApiJson(json);
  }

  Future<AppUser> fetchProfile(String userId) async {
    final json = await _sendJson(
      'GET',
      '/profile/me?userId=$userId',
    );
    return AppUser.fromApiJson(json);
  }

  Future<void> trackEvent({
    required String name,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    await _sendJson(
      'POST',
      '/events/track',
      body: {
        'name': name,
        'userId': userId,
        'metadata': metadata ?? const <String, dynamic>{},
      },
    );
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String route, {
    Map<String, dynamic>? body,
  }) async {
    if (!isConfigured) {
      throw const PlatformApiException(
        'The platform API URL is not configured.',
        allowLocalFallback: true,
      );
    }

    final uri = Uri.parse('${baseUrl.trim()}$route');
    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri).timeout(const Duration(seconds: 8));
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body ?? const <String, dynamic>{}),
              )
              .timeout(const Duration(seconds: 8));
          break;
        case 'POST':
        default:
          response = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body ?? const <String, dynamic>{}),
              )
              .timeout(const Duration(seconds: 8));
          break;
      }
    } catch (_) {
      throw const PlatformApiException(
        'The live platform is not reachable right now.',
        allowLocalFallback: true,
      );
    }

    final decoded = _decodeBody(response.body);
    if (response.statusCode >= 400) {
      throw PlatformApiException(
        decoded['error']?.toString() ?? 'The platform request failed.',
      );
    }
    return decoded;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const PlatformApiException('The platform returned an invalid response.');
  }
}

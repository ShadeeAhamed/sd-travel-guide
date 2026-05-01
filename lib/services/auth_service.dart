import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../database/auth_db.dart';
import '../models/auth_models.dart';
import '../models/user_profile_model.dart';
import 'platform_api_service.dart';
import 'user_preference_engine.dart';

class AuthFlowException implements Exception {
  final String message;

  const AuthFlowException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final AuthDatabase _db = AuthDatabase.instance;
  final PlatformApiService _platform = PlatformApiService.instance;
  final Random _random = Random();

  Future<AppLaunchState> loadLaunchState() async {
    final userId = await _db.currentSessionUserId();
    if (userId == null) {
      return const AppLaunchState(user: null, needsOnboarding: false);
    }

    final cachedUser = await _db.getUserById(userId);
    if (cachedUser == null) {
      await _db.clearSession();
      return const AppLaunchState(user: null, needsOnboarding: false);
    }

    final user = await _refreshRemoteProfile(cachedUser);
    return AppLaunchState(
      user: user,
      needsOnboarding: !user.isOnboardingComplete,
    );
  }

  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty ||
        cleanEmail.isEmpty ||
        cleanPhone.isEmpty ||
        cleanPassword.length < 6) {
      throw const AuthFlowException(
        'Complete all fields and use a password with at least 6 characters.',
      );
    }

    if (_platform.isConfigured) {
      try {
        return await _platform.register(
          fullName: cleanName,
          email: cleanEmail,
          phone: cleanPhone,
          password: cleanPassword,
        );
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final existingEmail = await _db.getUserByEmail(cleanEmail);
    if (existingEmail != null) {
      throw const AuthFlowException(
        'An account already exists for that email address.',
      );
    }

    final existingPhone = await _db.getUserByPhone(cleanPhone);
    if (existingPhone != null) {
      throw const AuthFlowException(
        'An account already exists for that contact number.',
      );
    }

    final now = DateTime.now();
    final user = AppUser(
      id: now.microsecondsSinceEpoch.toString(),
      fullName: cleanName,
      email: cleanEmail,
      phone: cleanPhone,
      passwordHash: _hashPassword(cleanPassword),
      preferences: const TravelerPreferences.defaultProfile(),
      travelPersonality: 'New Explorer',
      historyData: const {
        'recent_places': <String>[],
        'saved_itineraries': <String>[],
      },
      behaviorData: const {
        'logins': 0,
        'assistant_messages': 0,
        'map_searches': 0,
        'translator_uses': 0,
        'itinerary_generations': 0,
      },
      isOnboardingComplete: false,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _db.insertUser(user);
    } on DatabaseException {
      throw const AuthFlowException(
        'That account could not be created right now. Please try again.',
      );
    }

    return _createOtpChallenge(
      userId: user.id,
      destination: user.email,
      channel: 'email',
      purpose: OtpPurpose.signUp,
    );
  }

  Future<OtpChallenge> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (_platform.isConfigured) {
      try {
        return await _platform.loginWithEmail(
          email: cleanEmail,
          password: cleanPassword,
        );
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final user = await _db.getUserByEmail(cleanEmail);
    if (user == null || user.passwordHash != _hashPassword(cleanPassword)) {
      throw const AuthFlowException('Incorrect email or password.');
    }

    return _createOtpChallenge(
      userId: user.id,
      destination: user.email,
      channel: 'email',
      purpose: OtpPurpose.login,
    );
  }

  Future<OtpChallenge> requestPhoneOtp(String phone) async {
    final cleanPhone = phone.trim();
    if (_platform.isConfigured) {
      try {
        return await _platform.requestPhoneOtp(cleanPhone);
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final user = await _db.getUserByPhone(cleanPhone);
    if (user == null) {
      throw const AuthFlowException(
        'No traveler account was found for that number.',
      );
    }

    return _createOtpChallenge(
      userId: user.id,
      destination: user.phone,
      channel: 'sms',
      purpose: OtpPurpose.login,
    );
  }

  Future<OtpVerificationResult> verifyOtp({
    required String challengeId,
    required String code,
    required AuthMethod method,
  }) async {
    if (_platform.isConfigured) {
      try {
        final user = await _platform.verifyOtp(
          challengeId: challengeId,
          code: code,
        );
        await _upsertLocalUser(user);
        await _db.saveSession(userId: user.id, method: method);
        return OtpVerificationResult(
          user: user,
          needsOnboarding: !user.isOnboardingComplete,
        );
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final challenge = await _db.getOtpChallenge(challengeId);
    if (challenge == null) {
      throw const AuthFlowException('That verification code has expired.');
    }

    if (DateTime.now().isAfter(challenge.expiresAt)) {
      await _db.deleteOtpChallenge(challenge.id);
      throw const AuthFlowException('That verification code has expired.');
    }

    if (challenge.codeDebug != code.trim()) {
      throw const AuthFlowException('The verification code is not correct.');
    }

    final user = await _db.getUserById(challenge.userId);
    if (user == null) {
      throw const AuthFlowException('Traveler account not found.');
    }

    await _db.deleteOtpChallenge(challenge.id);
    await _db.saveSession(userId: user.id, method: method);
    await updateBehaviorCounter(user.id, 'logins');

    final refreshedUser = await _db.getUserById(user.id) ?? user;
    return OtpVerificationResult(
      user: refreshedUser,
      needsOnboarding: !refreshedUser.isOnboardingComplete,
    );
  }

  Future<AppUser> completeOnboarding({
    required String userId,
    required TravelerPreferences preferences,
  }) async {
    if (_platform.isConfigured) {
      try {
        final updated = await _platform.updatePreferences(
          userId: userId,
          preferences: preferences,
        );
        await _upsertLocalUser(updated);
        return updated;
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final user = await _db.getUserById(userId);
    if (user == null) {
      throw const AuthFlowException('Traveler account not found.');
    }

    final updated = user.copyWith(
      preferences: preferences,
      travelPersonality: UserPreferenceEngine.personalityLabel(preferences),
      isOnboardingComplete: true,
      updatedAt: DateTime.now(),
    );
    await _db.updateUser(updated);
    return updated;
  }

  Future<AppUser> updateMood({
    required String userId,
    required TravelMood mood,
  }) async {
    final user = await _db.getUserById(userId);
    if (user == null) {
      throw const AuthFlowException('Traveler account not found.');
    }

    final nextPreferences = user.preferences.copyWith(mood: mood);
    if (_platform.isConfigured) {
      try {
        final updated = await _platform.updatePreferences(
          userId: userId,
          preferences: nextPreferences,
        );
        await _upsertLocalUser(updated);
        return updated;
      } on PlatformApiException catch (error) {
        if (!error.allowLocalFallback) {
          throw AuthFlowException(error.message);
        }
      }
    }

    final updated = user.copyWith(
      preferences: nextPreferences,
      updatedAt: DateTime.now(),
    );
    await _db.updateUser(updated);
    return updated;
  }

  Future<void> updateBehaviorCounter(
    String userId,
    String key, {
    int delta = 1,
  }) async {
    final user = await _db.getUserById(userId);
    if (user == null) {
      return;
    }

    final nextBehavior = Map<String, dynamic>.from(user.behaviorData);
    final current = (nextBehavior[key] as num?)?.toInt() ?? 0;
    nextBehavior[key] = current + delta;

    await _db.updateUser(
      user.copyWith(
        behaviorData: nextBehavior,
        updatedAt: DateTime.now(),
      ),
    );

    if (_platform.isConfigured) {
      try {
        await _platform.trackEvent(
          name: _eventNameForBehaviorKey(key),
          userId: userId,
          metadata: {
            'delta': delta,
            'source': 'flutter-app',
          },
        );
      } on PlatformApiException {
        // Keep the local profile fast and resilient if the live platform is down.
      }
    }
  }

  Future<AppUser?> currentUser() async {
    final userId = await _db.currentSessionUserId();
    if (userId == null) {
      return null;
    }
    return _db.getUserById(userId);
  }

  Future<void> signOut() async {
    await _db.clearSession();
  }

  Future<AppUser> _refreshRemoteProfile(AppUser user) async {
    if (!_platform.isConfigured) {
      return user;
    }

    try {
      final refreshed = await _platform.fetchProfile(user.id);
      await _upsertLocalUser(refreshed);
      return refreshed;
    } on PlatformApiException {
      return user;
    }
  }

  Future<void> _upsertLocalUser(AppUser user) async {
    final existing = await _db.getUserById(user.id);
    if (existing == null) {
      await _db.insertUser(user);
      return;
    }

    await _db.updateUser(
      user.copyWith(
        passwordHash: user.passwordHash.isEmpty
            ? existing.passwordHash
            : user.passwordHash,
      ),
    );
  }

  Future<OtpChallenge> _createOtpChallenge({
    required String userId,
    required String destination,
    required String channel,
    required OtpPurpose purpose,
  }) async {
    final challenge = OtpChallenge(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      destination: destination,
      channel: channel,
      codeDebug: (100000 + _random.nextInt(899999)).toString(),
      purpose: purpose,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      deliveryStatus: 'developerPreview',
      deliveryMessage: channel == 'email'
          ? 'Developer preview is enabled, so the code is shown here. If the live email provider is configured on your server, this same code can also arrive in your inbox.'
          : 'Developer preview is enabled. A real SMS provider is not configured yet, so use the code shown here for now.',
    );
    await _db.saveOtpChallenge(challenge);
    return challenge;
  }

  String _hashPassword(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  String _eventNameForBehaviorKey(String key) {
    switch (key) {
      case 'assistant_messages':
        return 'assistant_message';
      case 'map_searches':
        return 'map_search';
      case 'translator_uses':
        return 'translator_use';
      case 'itinerary_generations':
        return 'itinerary_generation';
      case 'logins':
        return 'login';
      default:
        return key;
    }
  }
}

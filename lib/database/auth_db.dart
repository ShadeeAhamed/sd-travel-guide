import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/auth_models.dart';
import '../models/user_profile_model.dart';

class AuthDatabase {
  AuthDatabase._();

  static final AuthDatabase instance = AuthDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'sd_travel_guide_auth.db');
    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            preferences_json TEXT NOT NULL,
            travel_personality TEXT NOT NULL,
            history_json TEXT NOT NULL,
            behavior_json TEXT NOT NULL,
            is_onboarding_complete INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE otp_challenges(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            destination TEXT NOT NULL,
            channel TEXT NOT NULL,
            code TEXT NOT NULL,
            purpose TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id TEXT,
            is_verified INTEGER NOT NULL,
            login_method TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertUser(AppUser user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(AppUser user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return AppUser.fromMap(results.first);
  }

  Future<AppUser?> getUserByPhone(String phone) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return AppUser.fromMap(results.first);
  }

  Future<AppUser?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    return AppUser.fromMap(results.first);
  }

  Future<void> saveOtpChallenge(OtpChallenge challenge) async {
    final db = await database;
    await db.insert(
      'otp_challenges',
      {
        'id': challenge.id,
        'user_id': challenge.userId,
        'destination': challenge.destination,
        'channel': challenge.channel,
        'code': challenge.codeDebug,
        'purpose': challenge.purpose.name,
        'expires_at': challenge.expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<OtpChallenge?> getOtpChallenge(String id) async {
    final db = await database;
    final results = await db.query(
      'otp_challenges',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) {
      return null;
    }
    final row = results.first;
    return OtpChallenge(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      destination: row['destination'] as String,
      channel: row['channel'] as String,
      codeDebug: row['code'] as String,
      purpose: _otpPurposeFromRaw(row['purpose'] as String?),
      expiresAt: DateTime.tryParse(row['expires_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> deleteOtpChallenge(String id) async {
    final db = await database;
    await db.delete(
      'otp_challenges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveSession({
    required String userId,
    required AuthMethod method,
  }) async {
    final db = await database;
    await db.insert(
      'session',
      {
        'id': 1,
        'user_id': userId,
        'is_verified': 1,
        'login_method': method.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> currentSessionUserId() async {
    final db = await database;
    final results = await db.query('session', where: 'id = 1', limit: 1);
    if (results.isEmpty) {
      return null;
    }
    return results.first['user_id'] as String?;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('session', where: 'id = 1');
  }

  OtpPurpose _otpPurposeFromRaw(String? value) {
    switch (value) {
      case 'signUp':
        return OtpPurpose.signUp;
      case 'login':
      default:
        return OtpPurpose.login;
    }
  }
}

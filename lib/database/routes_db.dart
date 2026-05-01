import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RoutesDB {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'routes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) {
        db.execute(
          '''
          CREATE TABLE routes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fromLat REAL,
            fromLng REAL,
            toLat REAL,
            toLng REAL
          )
          ''',
        );
      },
    );
  }

  static Future<void> saveRoute(
      double fl, double fn, double tl, double tn) async {
    final db = await database;
    await db.insert('routes', {
      'fromLat': fl,
      'fromLng': fn,
      'toLat': tl,
      'toLng': tn,
    });
  }
}

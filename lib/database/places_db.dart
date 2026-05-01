import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/place_model.dart';

class PlacesDB {
  static final PlacesDB instance = PlacesDB._init();
  static Database? _database;

  PlacesDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('places.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        image TEXT,
        lat REAL,
        lng REAL,
        type TEXT,
        isFavourite INTEGER
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE places ADD COLUMN isFavourite INTEGER DEFAULT 0',
      );
    }
  }

  Future<void> insertPlace(PlaceModel place) async {
    final db = await database;
    await db.insert('places', place.toMap());
  }

  Future<void> seedPlaces(List<PlaceModel> places) async {
    final db = await database;
    final existing = await db.query('places', columns: ['name']);
    final existingNames = existing.map((row) => row['name'] as String).toSet();
    final batch = db.batch();

    for (final place in places) {
      if (existingNames.contains(place.name)) {
        batch.update(
          'places',
          {
            'description': place.description,
            'image': place.image,
            'lat': place.lat,
            'lng': place.lng,
            'type': place.type,
          },
          where: 'name = ?',
          whereArgs: [place.name],
        );
      } else {
        batch.insert('places', place.toMap());
      }
    }

    await batch.commit(noResult: true);
  }

  Future<List<PlaceModel>> getPlaces() async {
    final db = await database;
    final result = await db.query('places', orderBy: 'name COLLATE NOCASE ASC');
    return result.map((e) => PlaceModel.fromMap(e)).toList();
  }

  Future<void> toggleFavourite(int id, bool value) async {
    final db = await database;
    await db.update(
      'places',
      {'isFavourite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PlaceModel>> getFavourites() async {
    final db = await database;
    final result = await db.query('places', where: 'isFavourite = 1');
    return result.map((e) => PlaceModel.fromMap(e)).toList();
  }
}

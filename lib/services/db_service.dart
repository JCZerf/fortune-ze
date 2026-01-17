import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;
  bool _useMemory = false;
  final Map<String, String> _memoryStore = {};

  Future<Database> get database async {
    if (_db != null) return _db!;
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'fortuneze.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS account(key TEXT PRIMARY KEY, value TEXT)');
        },
      );
      return _db!;
    } catch (e) {
      // fallback to in-memory store (tests or unsupported env)
      _useMemory = true;
      return Future.error(StateError('sqflite unavailable, using in-memory fallback'));
    }
  }

  Future<void> saveValue(String key, String value) async {
    if (_useMemory) {
      _memoryStore[key] = value;
      return;
    }
    try {
      final db = await database;
      await db.insert('account', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      _memoryStore[key] = value;
      _useMemory = true;
    }
  }

  Future<String?> readValue(String key) async {
    if (_useMemory) return _memoryStore[key];
    try {
      final db = await database;
      final res = await db.query('account', where: 'key = ?', whereArgs: [key]);
      if (res.isEmpty) return null;
      return res.first['value'] as String?;
    } catch (e) {
      _useMemory = true;
      return _memoryStore[key];
    }
  }
}

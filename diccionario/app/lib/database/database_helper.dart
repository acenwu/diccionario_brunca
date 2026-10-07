import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/word.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _seedAssetPath = 'assets/data/words.json';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }

    // Get appropriate path
    String dbPath;
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDir.path, 'dicionario_brunca.db');
    } else {
      dbPath = join(await getDatabasesPath(), 'dicionario_brunca.db');
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spanish TEXT NOT NULL,
        brunca TEXT NOT NULL,
        category TEXT,
        audioFile TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    await _seedWords(db);
  }

  // Loads the word list from the bundled JSON asset and inserts it in a
  // single batch. rootBundle.loadString decodes the asset as UTF-8, so
  // Brunca's accented vowels, tone marks, or other diacritics come through
  // intact as long as the JSON file itself is saved as UTF-8 — no manual
  // encoding/escaping needed on our end.
  Future<void> _seedWords(Database db) async {
    final String jsonString = await rootBundle.loadString(_seedAssetPath);
    final List<dynamic> entries = jsonDecode(jsonString) as List<dynamic>;

    final batch = db.batch();
    for (final entry in entries) {
      final map = entry as Map<String, dynamic>;
      batch.insert('words', {
        'spanish': map['spanish'],
        'brunca': map['brunca'],
        'category': map['category'],
        'audioFile': map['audioFile'],
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    // Bidirectional: matches Spanish or Brunca, and also matches by
    // category so e.g. typing "Animales" surfaces every word in it.
    final likeQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'spanish LIKE ? OR brunca LIKE ? OR category LIKE ?',
      whereArgs: [likeQuery, likeQuery, likeQuery],
      limit: 20,
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'words',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Word>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'isFavorite = 1',
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }
}

import 'dart:io';
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

        await db.insert('words', {
      'spanish': 'Perro',
      'brunca': 'Aúj',
      'category': 'Animales',
    });
    await db.insert('words', {
      'spanish': 'Gato',
      'brunca': 'Bís',
      'category': 'Animales',
    });
    await db.insert('words', {
      'spanish': 'Pato',
      'brunca': 'Cratus',
      'category': 'Animales',
    });
    await db.insert('words', {
      'spanish': 'Vaca',
      'brunca': 'Turí',
      'category': 'Animales',
    });
    await db.insert('words', {
      'spanish': 'Caballo',
      'brunca': 'Sárocra',
      'category': 'Animales',
    });
  }

  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'spanish LIKE ?',
      whereArgs: ['%$query%'],
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

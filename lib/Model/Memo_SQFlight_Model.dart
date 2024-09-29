import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MemoDatabase {
  static final MemoDatabase instance = MemoDatabase._init();

  static Database? _database;

  MemoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('memos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE memos (
  id $idType,
  title $textType,
  content $textType
)
''');
  }

  Future<void> createMemo(String title, String content) async {
    final db = await instance.database;
    await db.insert('memos', {'title': title, 'content': content});
  }

  Future<List<Map<String, dynamic>>> readAllMemos() async {
    final db = await instance.database;
    return await db.query('memos');
  }

  Future<Map<String, dynamic>?> readMemo(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'memos',
      columns: ['id', 'title', 'content'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<int> updateMemo(int id, String title, String content) async {
    final db = await instance.database;

    return db.update(
      'memos',
      {'title': title, 'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;

    return await db.delete(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

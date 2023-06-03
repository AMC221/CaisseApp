import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';

import '../Models/Order.dart';
import '../Models/Work.dart';

class WorkDatabase {
  static final WorkDatabase instance = WorkDatabase._init();
  late Database _database;

  WorkDatabase._init() {
    sqflite_ffi.sqfliteFfiInit();
  }

  Future<void> initDatabase() async {
    _database = await _initDB('work.db');
    await _createDB(_database, 1);
  }

  Future<Database> get database async {
    if (_database.isOpen) return _database;

    _database = await _initDB('work.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await databaseFactoryFfi.openDatabase(path);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS work (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT
      )
    ''');
  }

  Future<int> insertDate(String date) async {
    final db = await database;
    final existingDates = await db.query('work', where: 'date = ?', whereArgs: [date]);

    if (existingDates.isNotEmpty) {
      // Date already exists, return 0 to indicate no new insertion
      return 0;
    }

    return await db.insert('work', {'date': date});
  }


  /*Future<List<Work>> getDates() async {
    final db = await database;
    final result = await db.query('work');

    return result.map((json) => Work.fromJson(json)).toList();
  }*/
  Future<List<String>> getDates() async {
    final db = await database;
    final result = await db.query('work');
    return List.generate(result.length, (index) => result[index]['date'] as String);
  }

  // recuperer les dates par ordre du plus recent au plus ancien
  Future<List<String>> getDatesDesc() async {
    final db = await database;
    final result = await db.query('work', orderBy: 'date DESC');
    return List.generate(result.length, (index) => result[index]['date'] as String);
  }
}

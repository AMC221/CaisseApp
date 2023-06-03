import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:youmazgestion/Models/users.dart';


class AuthDatabase {
  static final AuthDatabase instance = AuthDatabase._init();
  late Database _database;

  AuthDatabase._init() {
    sqflite_ffi.sqfliteFfiInit();
  }

  Future<void> initDatabase() async {
    _database = await _initDB('usersDb.db');
    await _createDB(_database, 1);
  }

  Future<Database> get database async {
    if (_database.isOpen) return _database;

    _database = await _initDB('usersDb.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await databaseFactoryFfi.openDatabase(path);
  }

  Future<void> _createDB(Database db, int version) async{
    final resultUsers = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'");

    if (resultUsers.isEmpty) {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        lastname TEXT,
        email TEXT,
        password TEXT,
        username TEXT,
        role TEXT
      )
    ''');
    }
  }

  Future<int> createUser(Users user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(Users user) async {
    final db = await database;
    return await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> getUserCount() async {
    final db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from users');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  // verify username and password existe
  Future<bool> verifyUser(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT COUNT (*) from users WHERE username = ? AND password = ?',
        [username, password]);
    int result = Sqflite.firstIntValue(x)!;
    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }
  //recuperer un user grace a son username
  Future<Users> getUser(String username) async {
   try {
     final db = await database;
     List<Map<String, dynamic>> x = await db.rawQuery(
         'SELECT * from users WHERE username = ?',
         [username]);
     print(x.first);
     Users user = Users.fromMap(x.first);
     print(user);
     return user;
   } catch (e) {
     print(e);
     throw e;
   }
  }

  Future<List<Users>> getAllUsers() async {
    final db = await database;
    final orderBy = 'id ASC';
    final result = await db.query('users', orderBy: orderBy);
    return result.map((json) => Users.fromMap(json)).toList();
  }

}
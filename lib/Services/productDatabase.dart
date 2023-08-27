import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../Models/produit.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  late Database _database;

  ProductDatabase._init() {
    sqflite_ffi.sqfliteFfiInit();
  }

  ProductDatabase() {}

  Future<Database> get database async {
    if (_database.isOpen) return _database;
    _database = await _initDB('products2.db');
    return _database;
  }

  Future<void> initDatabase() async {
    _database = await _initDB('products2.db');
    await _createDB(_database, 1);
  }

  Future<Database> _initDB(String filePath) async {
    // Obtenez le répertoire de stockage local de l'application
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    // Vérifiez si le fichier de base de données existe déjà dans le répertoire de stockage local
    bool dbExists = await File(path).exists();
    if (!dbExists) {
      // Si le fichier n'existe pas, copiez-le depuis le dossier assets/database
      ByteData data = await rootBundle.load('assets/database/$filePath');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    // Ouvrez la base de données
    return await databaseFactoryFfi.openDatabase(path);
  }

  Future<void> _createDB(Database db, int version) async {
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    final tableNames = tables.map((row) => row['name'] as String).toList();

    if (!tableNames.contains('products')) {
      await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        image TEXT,
        category TEXT,
        stock INTEGER,
      )
    ''');
    }
  }



  Future<int> createProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int ?id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM products');
    return List.generate(result.length, (index) => result[index]['category'] as String);
  }


  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final maps = await db.query('products', where: 'category = ?', whereArgs: [category]);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // modifier la quantité de stock
  Future<int> updateStock(int id, int stock) async {
    final db = await database;
    return await db.rawUpdate('UPDATE products SET stock = ? WHERE id = ?', [stock, id]);
  }

}

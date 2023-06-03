import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';
import '../Models/Order.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class OrderDatabase {
  static final OrderDatabase instance = OrderDatabase._init();
  late Database _database;

  OrderDatabase._init() {
    sqflite_ffi.sqfliteFfiInit();
  }

  Future<void> initDatabase() async {
    _database = await _initDB('orderdb.db');
    await _createDB(_database, 1);
  }

  Future<Database> get database async {
    if (_database.isOpen) return _database;

    _database = await _initDB('orderdb.db');
    return _database;
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
    final resultOrders = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='orders'");
    final resultOrderItems = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='order_items'");

    if (resultOrders.isEmpty) {
      await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_price REAL,
        date_time TEXT,
        start_date TEXT,
        user TEXT,
      )
    ''');
    }

    if (resultOrderItems.isEmpty) {
      await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        product_name TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');
    }
  }

  Future<int> insertOrder(
      double totalPrice,
      String dateTime,
      DateTime? startDate,
      String user,
      ) async {
    final db = await database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate!);
    print("formattedStartDate1 : $formattedStartDate");
    final orderId = await db.insert(
      'orders',
      {
        'total_price': totalPrice,
        'date_time': dateTime,
        'start_date': formattedStartDate,
        'user': user,
      },
    );
    return orderId;
  }

  Future<void> insertOrderItem(
      int orderId,
      String productName,
      int quantity,
      double price,
      ) async {
    final db = await database;
    await db.insert(
      'order_items',
      {
        'order_id': orderId,
        'product_name': productName,
        'quantity': quantity,
        'price': price,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return db.query('orders');
  }

  Future<List<Order>> getOrderHistory() async {
    final orderData = await getAllOrders();

    return orderData.map((orderMap) {
      return Order(
        id: orderMap['id'],
        totalPrice: orderMap['total_price'],
        dateTime: orderMap['date_time'],
        startDate: orderMap['start_date'] != null
            ? DateTime.parse(orderMap['start_date'])
            : null,
        user: orderMap['user'],

      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await database;
    return db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Order>> getOrdersByStartDate(DateTime startDate) async {
    final db = await database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    print("formattedStartDate dans la base: $formattedStartDate");
    final orderData = await db.query(
      'orders',
      where: 'start_date = ?',
      whereArgs: [formattedStartDate],
    );

    return orderData.map((orderMap) {
      return Order(
        id: orderMap['id'] as int,
        totalPrice: orderMap['total_price'] as double,
        dateTime: orderMap['date_time'] as String,
        startDate: orderMap['start_date'] != null
            ? DateTime.parse(orderMap['start_date'] as String)
            : null,
        user: orderMap['user'] as String,
      );
    }).toList();
  }


  Future<Map<String, int>> getProductQuantitiesByDate(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await db.rawQuery('''
    SELECT product_name, SUM(quantity) AS total_quantity
    FROM order_items
    INNER JOIN orders ON order_items.order_id = orders.id
    WHERE orders.start_date = ?
    GROUP BY product_name
  ''', [formattedDate]);

    final productQuantities = <String, int>{};
    for (final row in result) {
      final productName = row['product_name'] as String;
      final quantity = row['total_quantity'] as int;
      productQuantities[productName] = quantity;
    }

    return productQuantities;
  }

  Future<Map<String, int>> getProductQuantitiesByMonth(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM').format(date);

    final result = await db.rawQuery('''
    SELECT product_name, SUM(quantity) AS total_quantity
    FROM order_items
    INNER JOIN orders ON order_items.order_id = orders.id
    WHERE strftime('%Y-%m', orders.start_date) = ?
    GROUP BY product_name
  ''', [formattedDate]);

    final productQuantities = <String, int>{};
    for (final row in result) {
      final productName = row['product_name'] as String;
      final quantity = row['total_quantity'] as int;
      productQuantities[productName] = quantity;
    }

    return productQuantities;
  }



  Future<List<Order>> getOrdersByMonth(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM').format(date);

    final orderData = await db.rawQuery('''
    SELECT id, total_price, date_time, start_date
    FROM orders
    WHERE strftime('%Y-%m', start_date) = ?
  ''', [formattedDate]);

    return orderData.map((orderMap) {
      return Order(
        id: orderMap['id'] as int,
        totalPrice: orderMap['total_price'] as double,
        dateTime: orderMap['date_time'] as String,
        startDate: orderMap['start_date'] != null
            ? DateTime.parse(orderMap['start_date'] as String)
            : null,
        user: orderMap['user'] as String,
      );
    }).toList();
  }

  // maintenant je vais recuperer les commande par semaine en utilisant les semaines de l'année
  Future<List<Order>> getOrdersByWeekNumber(int weekNumber) async {
    final db = await database;

    final orderData = await db.rawQuery('''
    SELECT id, total_price, date_time, start_date
    FROM orders
    WHERE strftime('%W', start_date) = ?
  ''', [(weekNumber - 1).toString()]);

    return orderData.map((orderMap) {
      return Order(
        id: orderMap['id'] as int,
        totalPrice: orderMap['total_price'] as double,
        dateTime: orderMap['date_time'] as String,
        startDate: orderMap['start_date'] != null
            ? DateTime.parse(orderMap['start_date'] as String)
            : null,
        user: orderMap['user'] as String,
      );
    }).toList();
  }



  Future<List<Order>> getOrdersByYear(DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy').format(date);

    final orderData = await db.rawQuery('''
    SELECT id, total_price, date_time, start_date
    FROM orders
    WHERE strftime('%Y', start_date) = ?
  ''', [formattedDate]);

    return orderData.map((orderMap) {
      return Order(
        id: orderMap['id'] as int,
        totalPrice: orderMap['total_price'] as double,
        dateTime: orderMap['date_time'] as String,
        startDate: orderMap['start_date'] != null
            ? DateTime.parse(orderMap['start_date'] as String)
            : null,
        user: orderMap['user'] as String,
      );
    }).toList();
  }




}

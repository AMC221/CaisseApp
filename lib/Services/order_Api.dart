import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Models/Order.dart';
import 'OrderDatabase.dart';


class OrderApi {
  final Router _router = Router();
  late OrderDatabase _orderDatabase;

  OrderApi() {
    _orderDatabase = OrderDatabase.instance;
    _router.get('/orders', _getAllOrders);
    // Ajoutez d'autres routes nécessaires
  }

  Router get router => _router;

  Future<Response> _getAllOrders(Request request) async {
    await _orderDatabase.initDatabase();
    final orders = await _orderDatabase.getAllOrders();

    final ordersJson = jsonEncode(orders);

    return Response.ok(ordersJson, headers: {'content-type': 'application/json'});
  }
}

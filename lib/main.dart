import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Services/authDatabase.dart';
import 'Services/productDatabase.dart';
import 'my_app.dart';
import 'Services/OrderDatabase.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductDatabase.instance.initDatabase();
  await AuthDatabase.instance.initDatabase();

  setupLogger(); // Appel à la fonction setupLogger()

  //await OrderDatabase.instance.initDatabase();
  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

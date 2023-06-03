import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'Views/ErreurPage.dart';
import 'Views/loginPage.dart';
import 'accueil.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static bool isRegisterOpen = false;
  static DateTime? startDate;
  static late String path;


  static final Gradient primaryGradient = LinearGradient(
    colors: [
      Colors.white,
      Colors.orangeAccent,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.transparent,
      ),
      home: Builder(
        builder: (context) {
          return FutureBuilder<bool>(
            future: checkLocalDatabasesExist(), // Appel à la fonction de vérification
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Affichez un indicateur de chargement si nécessaire
                return CircularProgressIndicator();
              } else if (snapshot.hasError || !(snapshot.data ?? false)) {
                // S'il y a une erreur ou si les bases de données n'existent pas
                return ErreurPage(dbPath: path); // Redirigez vers la page d'erreur en affichant le chemin de la base de données
              } else {
                // Si les bases de données existent, affichez la page d'accueil normalement
                return Container(
                  decoration: BoxDecoration(
                    gradient: MyApp.primaryGradient,
                  ),
                  child: LoginPage(),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<bool> checkLocalDatabasesExist() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = documentsDirectory.path;
    path = dbPath;

    // Vérifier si le fichier de base de données products2.db existe
    final productsDBFile = File('$dbPath/products2.db');
    final productsDBExists = await productsDBFile.exists();

    // Vérifier si le fichier de base de données auth.db existe
    final authDBFile = File('$dbPath/usersDb.db');
    final authDBExists = await authDBFile.exists();

    // Vérifier si d'autres bases de données nécessaires existent, le cas échéant

    return productsDBExists && authDBExists;
  }
}


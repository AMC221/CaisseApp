import 'package:flutter/material.dart';

class ErreurPage extends StatelessWidget {
  final String dbPath;

  const ErreurPage({Key? key, required this.dbPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Erreur'),

      ),
      body: Center(
        child: Text('Base de données introuvable : $dbPath'),

      ),
    );
  }
}

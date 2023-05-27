import 'package:flutter/material.dart';
import 'package:youmazgestion/accueil.dart';

class DemarrerCaissePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Mettre à jour la valeur de isRegisterOpen dans le HomeController
            
          },
          child: Text('Démarrer la caisse'),
        ),
      ),
    );
  }
}

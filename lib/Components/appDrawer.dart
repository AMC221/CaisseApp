import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Views/historique.dart';

import '../Components/app_bar.dart';
import '../Views/addProduct.dart';
import '../Views/gestionProduct.dart';
import '../Views/registrationPage.dart';
import '../accueil.dart';
import '../controller/userController.dart';

class CustomDrawer extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

   CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          GetBuilder<UserController>(
            builder: (controller) => UserAccountsDrawerHeader(
              accountName: Text(controller.userName),
              accountEmail: Text(controller.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/youmaz2.png"),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            ),

          ),
          ListTile(
            leading: Icon(Icons.home),
            iconColor: Colors.lightBlueAccent,
            title: Text("Accueil"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Accueil"
              Get.to(AccueilPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            iconColor: Colors.green,
            title: Text("Ajouter un utilisateur"),
            onTap: () {
              Get.to(RegistrationPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            iconColor: Colors.orange,
            title: Text("Modifier/Supprimer un utilisateur"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Modifier/Supprimer un utilisateur"

            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            iconColor: Colors.indigoAccent,
            title: Text("Ajouter un produit"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Ajouter un produit"
              Get.to(AddProductPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            iconColor: Colors.redAccent,
            title: Text("Modifier/Supprimer un produit"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Modifier/Supprimer un produit"
              Get.to(GestionProduit());
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text("Bilan"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Bilan"
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            iconColor: Colors.blueGrey,
            title: Text("Paramètres"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Paramètres"
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            iconColor: Colors.red,
            title: Text("Déconnexion"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Déconnexion"

            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            iconColor: Colors.blue,
            title: Text("Historique"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Historique"
              Get.to(HistoryPage());
            },

          )

        ],
      ),
    );
  }
}

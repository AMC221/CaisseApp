import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Views/historique.dart';

import '../Components/app_bar.dart';
import '../Views/addProduct.dart';
import '../Views/bilanMois.dart';
import '../Views/gestionProduct.dart';
import '../Views/gestionStock.dart';
import '../Views/listUser.dart';
import '../Views/loginPage.dart';
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
              accountEmail: Text(controller.email),
              accountName: Text(controller.name),
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
              if(userController.role == "admin"){
                Get.to(RegistrationPage());
              }else{
                Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                    "Vous n'avez pas les droits pour ajouter un utilisateur");
              }

            },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            iconColor: Colors.orange,
            title: Text("Modifier/Supprimer un utilisateur"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Modifier/Supprimer un utilisateur"
              if(userController.role == "admin"){
                Get.to(ListUserPage());
              }else{
                Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                    "Vous n'avez pas les droits pour modifier/supprimer un utilisateur");
              }

            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            iconColor: Colors.indigoAccent,
            title: Text("Ajouter un produit"),
            onTap: () { if(userController.role == "admin"){
              // Action lorsque l'utilisateur clique sur "Ajouter un produit"
              Get.to(AddProductPage());
            }else{
              Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                   "Vous n'avez pas les droits pour ajouter un produit");
            }
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            iconColor: Colors.redAccent,
            title: Text("Modifier/Supprimer un produit"),
            onTap: () {
              if(userController.role == "admin"){
              // Action lorsque l'utilisateur clique sur "Modifier/Supprimer un produit"
              Get.to(GestionProduit());
            }else {
                Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                    "Vous n'avez pas les droits pour modifier/supprimer un produit");

              }
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text("Bilan"),
            onTap: () {
              if (userController.role == "admin") {
                Get.to(BilanMois());

              } else {
                Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error_outline_outlined),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                    "Vous n'avez pas les droits pour accéder au bilan");
              }

            },
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            iconColor: Colors.blueAccent,
            title: Text("Gestion de stock"),
            onTap: () {
              if(userController.role == "admin"){
                // Action lorsque l'utilisateur clique sur "Gestion de stock"
                Get.to(GestionStockPage());
              }else{
                Get.snackbar("Accés refusé",backgroundColor: Colors.red,colorText: Colors.white,icon: Icon(Icons.error),duration: Duration(seconds: 3),snackPosition: SnackPosition.TOP,
                    "Vous n'avez pas les droits pour accéder à la gestion de stock");
              }

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

          ),
          ListTile(
            leading: Icon(Icons.logout),
            iconColor: Colors.red,
            title: Text("Déconnexion"),
            onTap: () {
              // Action lorsque l'utilisateur clique sur "Déconnexion"
              // display confirmation dialog
              Get.defaultDialog(
                title: "Déconnexion",
                content: Text("Voulez-vous vraiment vous déconnecter ?"),
                actions: [
                  ElevatedButton(
                    child: Text("Oui"),
                    onPressed: () {
                      Get.offAll(LoginPage());
                    },
                  ),
                  ElevatedButton(
                    child: Text("Non"),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              );


            },
          )

        ],
      ),
    );
  }
}

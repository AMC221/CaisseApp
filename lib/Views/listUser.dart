import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:youmazgestion/Models/users.dart';
import '../Components/app_bar.dart';
import '../Services/authDatabase.dart';
import 'editUser.dart';

class ListUserPage extends StatefulWidget {
  @override
  _ListUserPageState createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<Users> userList = [];

  @override
  void initState() {
    super.initState();
    getUsersFromDatabase();
  }

  Future<void> getUsersFromDatabase() async {
    try {
      List<Users> users = await AuthDatabase.instance.getAllUsers();
      setState(() {
        userList = users;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Liste des utilisateurs'),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          Users user = userList[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.deepOrange,
            borderOnForeground: true,
            child: ListTile(
              title: Text(
                "${user.name} ${user.lastName}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text("Username: ${user.username}"),
                  SizedBox(height: 4),
                  Text("Privilège: ${user.role}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      // Action de suppression
                      // Vous pouvez appeler une méthode de suppression appropriée ici
                      // confirmation de suppression
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Supprimer"),
                            content: Text(
                                "Êtes-vous sûr de vouloir supprimer cet utilisateur?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Annuler"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await AuthDatabase.instance
                                      .deleteUser(user.id);
                                  Navigator.of(context).pop();
                                  setState(() {
                                    userList.removeAt(index);
                                  });
                                },
                                child: Text("Supprimer"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () {
                      // Action de modification
                      // Vous pouvez naviguer vers la page de modification avec les détails de l'utilisateur
                      // en utilisant Navigator.push ou showDialog, selon votre besoin
                      Get.to(() => EditUserPage(user: user));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

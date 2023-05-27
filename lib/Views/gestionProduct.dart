import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/produit.dart';
import '../Services/productDatabase.dart';
import 'editProduct.dart';
import 'dart:io';

class GestionProduit extends StatelessWidget {
  final ProductDatabase _productDatabase = ProductDatabase.instance;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des produits'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productDatabase.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur s\'est produite'),
            );
          }

          final products = snapshot.data;

          if (products == null || products.isEmpty) {
            return Center(
              child: Text('Aucun produit disponible'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: screenWidth,
                margin: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product.image != null
                        ? FileImage(File(product.image!))  as ImageProvider<Object>// Charger l'image à partir du chemin d'accès
                        : AssetImage('assets/placeholder_image.png'), // Image de substitution si le chemin d'accès est vide
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                      Text('Category: ${product.category}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _productDatabase.deleteProduct(product.id).then((value) {
                            Get.snackbar(
                              'Produit supprimé',
                              'Le produit a été supprimé avec succès',
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          });
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                      ),
                      IconButton(
                        onPressed: () {
                          Get.to(EditProductPage(product: product))?.then((result) {
                            if (result != null && result is Product) {
                              _productDatabase.updateProduct(result).then((value) {
                                Get.snackbar(
                                  'Produit mis à jour',
                                  'Le produit a été mis à jour avec succès',
                                  snackPosition: SnackPosition.TOP,
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              });
                            }
                          });
                        },
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/produit.dart';
import '../Services/productDatabase.dart';
import 'gestionProduct.dart';

class EditProductPage extends StatelessWidget {
  final Product product;
  final TextEditingController _nameController;
  final TextEditingController _priceController;
  final TextEditingController _categoryController;

  EditProductPage({required this.product})
      : _nameController = TextEditingController(text: product.name),
        _priceController = TextEditingController(text: product.price.toString()),
        _categoryController = TextEditingController(text: product.category);

  void _saveChanges() async {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final category = _categoryController.text;

    if (name.isNotEmpty && price > 0) {
      final updatedProduct = Product(
        id: product.id,
        name: name,
        price: price,
        image: product.image,
        category: category,
      );

      await ProductDatabase.instance.updateProduct(updatedProduct);

      Get.to(GestionProduit());
    } else {
      Get.snackbar(
        'Entrée invalide',
        'Veuillez entrer un nom et un prix valides',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Modifier le produit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom du produit'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Catégorie'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}

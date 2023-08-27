import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../Components/appDrawer.dart';
import '../Components/app_bar.dart';
import '../Models/produit.dart';
import '../Services/productDatabase.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final List<String> _categories = ['Sucré', 'Salé', 'Jus', 'Gateaux'];
  String? _selectedCategory;

  File? _pickedImage;

  late ProductDatabase _productDatabase;

  @override
  void initState() {
    super.initState();
    _productDatabase = ProductDatabase.instance;
    _productDatabase.initDatabase();
  }

  void _selectImage() async {
    final action = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner une image'),
          content: Text('Choisissez comment sélectionner une image'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('pick');
              },
              child: Text('Choisir depuis les fichiers'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('drop');
              },
              child: Text('Déposer une image'),
            ),
          ],
        );
      },
    );

    if (action == 'pick') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          _pickedImage = File(result.files.single.path!);
          _imageController.text = _pickedImage!.path; // Obtenir le chemin de l'image
        });
      }
    } else if (action == 'drop') {
      // Code pour gérer le dépôt de l'image
    }
  }

  Future<void> _getDatabaseLocation() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = directory.path;
    print('Emplacement de la base de données : $dbPath');
  }

  void _addProduct() {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final image = _imageController.text;
    final category = _selectedCategory;

    _getDatabaseLocation();

    if (name.isNotEmpty && price > 0 && image.isNotEmpty) {
      final product = Product(
        name: name,
        price: price,
        image: image,
        category: category!,
      );

      _productDatabase.createProduct(product).then((_) {
        Get.snackbar(
          'Succès',
          'Produit ajouté avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        setState(() {
          _nameController.clear();
          _priceController.clear();
          _imageController.clear();
          _selectedCategory = null;
          _pickedImage = null;
        });
      }).catchError((error) {
        print(error);
        Get.snackbar(
          'Erreur',
          'Impossible d\'ajouter le produit : $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } else {
      Get.snackbar(
        'Saisie invalide',
        'Veuillez entrer un nom, un prix et une image valides',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _displayImage() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          _pickedImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey[400],
          ),
          Positioned(
            bottom: 4,
            child: Text(
              'Aucune image',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Ajouter un produit'),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajouter un produit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom du produit',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Prix',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: 'Image',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Sélectionner une image'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _displayImage(), // Afficher l'image sélectionnée
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Ajouter le produit'),
            ),
          ],
        ),
      ),
    );
  }
}
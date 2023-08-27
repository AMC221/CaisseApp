import 'package:flutter/material.dart';
import 'package:youmazgestion/Components/app_bar.dart';
import '../Models/produit.dart';
import '../Services/productDatabase.dart';

class GestionStockPage extends StatefulWidget {
  @override
  _GestionStockPageState createState() => _GestionStockPageState();
}

class _GestionStockPageState extends State<GestionStockPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productDatabase = ProductDatabase.instance;
    _productsFuture = productDatabase.getProducts();
  }

  Future<void> _refreshProducts() async {
    final productDatabase = ProductDatabase.instance;
    _productsFuture = productDatabase.getProducts();
    setState(() {});
  }

  Future<void> _updateStock(int id, int stock) async {
    final productDatabase = ProductDatabase.instance;
    await productDatabase.updateStock(id, stock);
    _refreshProducts();
  }



  //popup pour modifier le stock

  Future<void> _showStockDialog(Product product) async {
    int stock = product.stock ?? 0;
    final quantityController = TextEditingController(text: stock.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product.name),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (stock > 0) {
                          stock--;
                          quantityController.text = stock.toString();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          stock = int.parse(value);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        stock++;
                        quantityController.text = stock.toString();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Enregistrer'),
              onPressed: () {
                // Enregistrer la nouvelle quantité dans la base de données
                _updateStock(product.id!, stock);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Gestion du stock'),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur s\'est produite'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucun produit trouvé'),
            );
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                Color stockColor;
                if (product.stock != null) {
                  if (product.stock! > 30) {
                    stockColor = Colors.green;
                  } else if (product.stock! > 10) {
                    stockColor = Colors.red;
                  } else {
                    stockColor = Colors.red;
                  }
                } else {
                  stockColor = Colors.red;
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.deepOrangeAccent,
                  child: ListTile(
                    leading: Icon(Icons.shopping_basket),
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${product.stock ?? 'Non disponible'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: stockColor,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showStockDialog(product);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

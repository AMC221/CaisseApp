import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quantity_input/quantity_input.dart';
import 'Components/appDrawer.dart';
import 'Components/app_bar.dart';
import 'Components/cartItem.dart';
import 'Models/produit.dart';
import 'Services/OrderDatabase.dart';
import 'Services/productDatabase.dart';
import 'Views/ticketPage.dart';
import 'controller/userController.dart';
import 'my_app.dart';
import 'Services/workDatabase.dart';

class AccueilPage extends StatefulWidget {
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final UserController userController = Get.put(UserController());
  final ProductDatabase productDatabase = ProductDatabase();
  late Future<Map<String, List<Product>>> productsFuture;
  final OrderDatabase orderDatabase = OrderDatabase.instance;
  final WorkDatabase workDatabase = WorkDatabase.instance;
  DateTime? startDate;

  int orderId = 0;
  List<CartItem> selectedProducts = [];
  int selectedQuantity = 1; // Quantité sélectionnée par défaut
  double totalCartPrice = 0;
  double amountPaid = 0;


  @override
  void initState() {
    super.initState();
    initorder();
    initwork();
    productsFuture = _initDatabaseAndFetchProducts();
  }

  Future<void> saveOrderToDatabase() async {
    final totalPrice = calculateTotalPrice();
    final dateTime = DateTime.now().toString();
    String user = userController.username;

    // Insert the order into the database
    orderId = await orderDatabase.insertOrder(totalPrice, dateTime, MyApp.startDate!, user);

    // Insert order items into the database
    for (final cartItem in selectedProducts) {
      final product = cartItem.product;
      final quantity = cartItem.quantity;
      final price = product.price * quantity;

      await orderDatabase.insertOrderItem(orderId, product.name, quantity, price);

      // Mettre à jour le stock du produit
      final updatedStock = product.stock! - quantity;
      await productDatabase.updateStock(product.id!, updatedStock);
    }
    showTicketPage();
  }

  Future<Map<String, List<Product>>> _initDatabaseAndFetchProducts() async {
    await productDatabase.initDatabase();
    final categories = await productDatabase.getCategories();
    final productsByCategory = <String, List<Product>>{};

    // Trier les catégories selon votre préférence
    categories.sort();

    for (final categoryName in categories) {
      final products = await productDatabase.getProductsByCategory(categoryName);
      productsByCategory[categoryName] = products;
    }

    return productsByCategory;
  }

  void initorder() async {
    await orderDatabase.initDatabase();
  }

  void initwork() async {
    await workDatabase.initDatabase();
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (final cartItem in selectedProducts) {
      totalPrice += cartItem.product.price * cartItem.quantity;
    }
    return totalPrice;
  }

  void addToCartWithDetails(Product product) {
    setState(() {
      final existingCartItem = selectedProducts.firstWhere(
            (cartItem) => cartItem.product == product,
        orElse: () => CartItem(product, 0),
      );
      if (existingCartItem.quantity == 0) {
        selectedProducts.add(CartItem(product, selectedQuantity));
      } else {
        existingCartItem.quantity += selectedQuantity;
      }
    });

    // Afficher une notification
    Get.snackbar(
      'Produit ajouté',
      'Le produit ${product.name} a été ajouté au panier',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    resetQuantityAfterDelay();
  }

  Future<void> resetQuantityAfterDelay() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      selectedQuantity = 1;
    });
  }

  void showTicketPage() {
    // Calculer la somme totale du panier
    final double totalCartPrice = calculateTotalPrice();

    // Vérifier si des produits sont présents dans le panier
    if (selectedProducts.isNotEmpty) {
      // Vérifier si la somme payée est suffisante et supérieure ou égale au total du panier
      if (amountPaid >= totalCartPrice) {
        // Passer les produits et les informations de l'entreprise à la page du ticket
        Get.offAll(TicketPage(
          businessName: 'Youmaz',
          businessAddress: 'quartier escale, Diourbel, Sénégal, en face de Sonatel',
          businessPhoneNumber: '77 446 92 68',
          cartItems: selectedProducts,
          totalCartPrice: totalCartPrice,
          amountPaid: amountPaid,
        ));
      } else {
        // Afficher un message d'erreur si la somme payée est insuffisante
        Get.snackbar(
          'Paiement incomplet',
          'Le montant payé est insuffisant. Veuillez payer le montant total du panier.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Afficher un message d'erreur si le panier est vide
      Get.snackbar(
        'Panier vide',
        'Le panier est vide. Veuillez ajouter des produits avant de passer commande.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Accueil"),
      drawer: CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.orangeAccent],
          ),
        ),
        child: FutureBuilder<Map<String, List<Product>>>(
          future: productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('erreur:' + snapshot.error.toString());
              return const Center(child: Text("Erreur lors du chargement des produits"));
            } else if (snapshot.hasData) {
              final Map<String, List<Product>> productsByCategory = snapshot.data!;
              final categories = productsByCategory.keys.toList();

              if (!MyApp.isRegisterOpen) {
                // Afficher le bouton "Démarrer la caisse" si la variable isRegisterOpen est false
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        MyApp.isRegisterOpen = true;
                        // mettre startDate à la date actuelle et au format yyyy-MM-dd
                        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                        startDate = DateFormat('yyyy-MM-dd').parse(formattedDate);
                        MyApp.startDate = startDate;

                        var datee = DateFormat('yyyy-MM-dd').format(startDate!).toString();
                        workDatabase.insertDate(datee);
                      });
                    },
                    child: Text('Démarrer la caisse'),
                  ),
                );
              } else {
                // Afficher le contenu de la page d'accueil
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final products = productsByCategory[category]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      decorationThickness: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];

                                  return Card(
                                    elevation: 7,
                                    shadowColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: AspectRatio(
                                                  aspectRatio: 14,
                                                  child: product.image != null
                                                      ? Image.file(
                                                    File(product.image),
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Image.asset(
                                                    'assets/placeholder_image.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${product.price.toStringAsFixed(2)} fcfa',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    if (product.isStockDefined()) ...[
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'En stock',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                    const SizedBox(height: 8),
                                                    QuantityInput(
                                                      value: selectedQuantity,
                                                      minValue: 1,
                                                      maxValue: 100,
                                                      step: 1,
                                                      inputWidth: 60,
                                                      buttonColor: Colors.redAccent,
                                                      onChanged: (String value) {
                                                        setState(() {
                                                          selectedQuantity = int.parse(value);
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        addToCartWithDetails(product);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Colors.orange,
                                                        onPrimary: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(18),
                                                        ),
                                                      ),
                                                      child: const Text('Ajouter au panier'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  ;
                                  ;
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Panier',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.red,
                                ),
                              ],
                            ),


                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: selectedProducts.length,
                                itemBuilder: (context, index) {
                                  final cartItem = selectedProducts[index];
                                  final product = cartItem.product;
                                  final quantity = cartItem.quantity;

                                  return ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(product.category),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${product.price.toStringAsFixed(2)} fcfa'),
                                        SizedBox(width: 8),
                                        Text('x $quantity'),
                                        SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete),

                                          onPressed: () {
                                            setState(() {
                                              selectedProducts.removeAt(index);
                                            });
                                          },color: Colors.redAccent,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Total: ${calculateTotalPrice().toStringAsFixed(2)} fcfa',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Montant payé',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  amountPaid = double.parse(value);
                                });
                              },
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                saveOrderToDatabase();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text('Payer'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            } else {
              return const Center(child: Text("Aucun produit disponible"));
            }
          },
        ),
      ),
    );
  }
}

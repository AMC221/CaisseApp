import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:youmazgestion/controller/userController.dart';
import '../Components/cartItem.dart';
import '../Models/produit.dart';
import '../Services/OrderDatabase.dart';
import '../Services/WorkDatabase.dart';
import '../Services/productDatabase.dart';
import '../Views/ticketPage.dart';
import '../my_app.dart';

class AccueilController extends GetxController {
  final UserController userController = Get.find();
  final ProductDatabase productDatabase = ProductDatabase();
  final Rx<Map<String, List<Product>>> productsFuture = Rx({}); // Observable
  final OrderDatabase orderDatabase = OrderDatabase.instance;
  final WorkDatabase workDatabase = WorkDatabase.instance;
  DateTime? startDate;

  final RxInt orderId = RxInt(0); // Observable
  final RxList<CartItem> selectedProducts = <CartItem>[].obs; // Observable list
  final RxInt selectedQuantity = RxInt(1); // Observable
  final RxDouble totalCartPrice = RxDouble(0.0); // Observable
  final RxDouble amountPaid = RxDouble(0.0); // Observable

  @override
  void onInit() {
    super.onInit();
    initOrder();
    initWork();
    _initDatabaseAndFetchProducts();
  }

  Future<void> saveOrderToDatabase() async {
    final totalPrice = _calculateTotalPrice();
    final dateTime = DateTime.now().toString();
    String user = userController.username;

    orderId.value = await orderDatabase.insertOrder(totalPrice, dateTime, MyApp.startDate!, user);

    for (final cartItem in selectedProducts) {
      final product = cartItem.product;
      final quantity = cartItem.quantity;
      final price = product.price * quantity;

      await orderDatabase.insertOrderItem(orderId.value, product.name, quantity, price);

      final updatedStock = product.stock! - quantity;
      await productDatabase.updateStock(product.id!, updatedStock);
    }
    showTicketPage();
  }

  Future<void> _initDatabaseAndFetchProducts() async {
    await productDatabase.initDatabase();
    final categories = await productDatabase.getCategories();
    final productsByCategory = <String, List<Product>>{};

    categories.sort();

    for (final categoryName in categories) {
      final products = await productDatabase.getProductsByCategory(categoryName);
      productsByCategory[categoryName] = products;
    }

    productsFuture.value = productsByCategory;
  }

  void initOrder() async {
    await orderDatabase.initDatabase();
  }

  void initWork() async {
    await workDatabase.initDatabase();
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;
    for (final cartItem in selectedProducts) {
      totalPrice += cartItem.product.price * cartItem.quantity;
    }
    return totalPrice;
  }

  void addToCartWithDetails(Product product) {
    final existingCartItem = selectedProducts.firstWhere(
          (cartItem) => cartItem.product == product,
      orElse: () => CartItem(product, 0),
    );
    if (existingCartItem.quantity == 0) {
      selectedProducts.add(CartItem(product, selectedQuantity.value));
    } else {
      existingCartItem.quantity += selectedQuantity.value;
    }

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
    selectedQuantity.value = 1;
  }

  void showTicketPage() {
    final double totalCartPrice = _calculateTotalPrice();

    if (selectedProducts.isNotEmpty) {
      if (amountPaid.value >= totalCartPrice) {
        Get.offAll(TicketPage(
          businessName: 'Youmaz',
          businessAddress: 'quartier escale, Diourbel, Sénégal, en face de Sonatel',
          businessPhoneNumber: '77 446 92 68',
          cartItems: selectedProducts,
          totalCartPrice: totalCartPrice,
          amountPaid: amountPaid.value,
        ));
      } else {
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
}

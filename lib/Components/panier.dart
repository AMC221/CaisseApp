import 'package:flutter/material.dart';
import 'package:quantity_input/quantity_input.dart';
import 'cartItem.dart';

class PanierPage extends StatelessWidget {
  final List<CartItem> selectedProducts;
  final Function() saveOrderToDatabase;

  const PanierPage({
    required this.selectedProducts,
    required this.saveOrderToDatabase,
  });

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (final cartItem in selectedProducts) {
      totalPrice += cartItem.product.price * cartItem.quantity;
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produits sélectionnés',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
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
                        QuantityInput(
                          value: quantity,
                          minValue: 1,
                          maxValue: 100,
                          step: 1,
                          buttonColor: Colors.orange,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveOrderToDatabase,
              child: Text('Valider la commande (${selectedProducts.length})'),
            ),
            SizedBox(height: 16),
            Text(
              'Total: ${calculateTotalPrice().toStringAsFixed(2)} fcfa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



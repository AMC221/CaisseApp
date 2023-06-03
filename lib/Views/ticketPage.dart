import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../Components/cartItem.dart';
import '../accueil.dart';

class TicketPage extends StatelessWidget {
  final String businessName;
  final String businessAddress;
  final String businessPhoneNumber;
  final List<CartItem> cartItems;
  final double totalCartPrice;
  final double amountPaid;

  const TicketPage({
    Key? key,
    required this.businessName,
    required this.businessAddress,
    required this.businessPhoneNumber,
    required this.cartItems,
    required this.totalCartPrice,
    required this.amountPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalOrderAmount = 0;

    // Calculer la somme totale de la commande
    for (final cartItem in cartItems) {
      final product = cartItem.product;
      final quantity = cartItem.quantity;
      final productTotal = product.price * quantity;
      totalOrderAmount += productTotal;
    }

    // Obtenir la date actuelle
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(currentDate);

    // Calculer la somme remise
    final double discount = totalOrderAmount - totalCartPrice;

    // Calculer la somme rendue
    final double change = amountPaid - totalOrderAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Youmaz'),
        actions: [
          IconButton(
            onPressed: () {
             Get.to(() => AccueilPage()); // Naviguez vers la page d'accueil
            },
            icon: const Icon(Icons.home),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ticket de caisse',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Entreprise : $businessName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adresse : $businessAddress',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro de téléphone : $businessPhoneNumber',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          'Produit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            'Quantité',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            'Prix unitaire',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...cartItems.map((cartItem) {
                    final product = cartItem.product;
                    final quantity = cartItem.quantity;
                    final productTotal = product.price * quantity;

                    return TableRow(
                      children: [
                        TableCell(
                          child: Text(product.name),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(quantity.toString()),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              '${product.price.toStringAsFixed(2)} fcfa',
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              '${productTotal.toStringAsFixed(2)} fcfa',
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 8,
                thickness: 1,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${totalOrderAmount.toStringAsFixed(2)} fcfa',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                height: 8,
                thickness: 0,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Somme remise :',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${amountPaid.toStringAsFixed(2)} fcfa',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Somme rendue :',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${change.toStringAsFixed(2)} fcfa',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Youmaz vous remercie pour votre achat!!!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

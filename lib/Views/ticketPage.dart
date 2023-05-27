import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Components/cartItem.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';


class TicketPage extends StatelessWidget {
  final String businessName;
  final String businessAddress;
  final String businessPhoneNumber;
  final List<CartItem> cartItems;

  const TicketPage({super.key,
    required this.businessName,
    required this.businessAddress,
    required this.businessPhoneNumber,
    required this.cartItems,
  });





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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Youmaz'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8.0),
          ),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Date : $formattedDate',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Entreprise : $businessName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Adresse : $businessAddress',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Numéro de téléphone : $businessPhoneNumber',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Table(
                columnWidths: {
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
              SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => printTicket(context,formattedDate,totalOrderAmount),
                    child: const Text('Imprimer'),
                  ),
                ],
              ),

            ],
          ),

        ),
      ),
    );
  }

  Future<void> printTicket(
      BuildContext context,
      String formattedDate,
      double totalOrderAmount,
      ) async {
    const PaperSize paper = PaperSize.mm80;

    final profile = await CapabilityProfile.load();

    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect('usb'); // Connect using USB

    if (res != PosPrintResult.success) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur d\'impression'),
            content: const Text('Impossible de se connecter à l\'imprimante.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    printer.setStyles(PosStyles(align: PosAlign.left));

    printer.text('Ticket de caisse', styles: PosStyles(bold: true, align: PosAlign.center));

    printer.feed(1);

    printer.text('Date : $formattedDate');

    printer.text('Entreprise : $businessName');
    printer.text('Adresse : $businessAddress');
    printer.text('Numéro de téléphone : $businessPhoneNumber');

    printer.feed(1);

    printer.text(
      'Produit       Quantité Prix unitaire  Total',
      styles: PosStyles(align: PosAlign.left, bold: true),
    );
    printer.text('------------------------------------------');

    for (final cartItem in cartItems) {
      final product = cartItem.product;
      final quantity = cartItem.quantity;
      final productTotal = product.price * quantity;

      final row =
          '${product.name.padRight(12)}  ${quantity.toString().padRight(9)}  ${product.price.toStringAsFixed(2).padRight(13)}  ${productTotal.toStringAsFixed(2)} fcfa';
      printer.text(row, styles: PosStyles(align: PosAlign.left));
    }

    printer.feed(1);

    printer.setStyles(PosStyles(align: PosAlign.right));
    printer.text(
      'Total : ${totalOrderAmount.toStringAsFixed(2)} fcfa',
      styles: PosStyles(bold: true),
    );

    printer.feed(2);
    printer.cut();

    printer.disconnect();
  }
}

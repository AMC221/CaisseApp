import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';

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


  Future<void> _printTicket() async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile );

    printer.text('Ticket de caisse',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.text('Entreprise : $businessName');
    printer.text('Adresse : $businessAddress');
    printer.text('Numéro de téléphone : $businessPhoneNumber');

    printer.hr();
    printer.row([
      PosColumn(
        text: 'Produit',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Quantité',
        width: 1,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Prix unitaire',
        width: 1,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 1,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
    ]);
    printer.hr();

    for (final cartItem in cartItems) {
      final product = cartItem.product;
      final quantity = cartItem.quantity;
      final productTotal = product.price * quantity;

      printer.row([
        PosColumn(
          text: product.name,
          width: 3,
        ),
        PosColumn(
          text: quantity.toString(),
          width: 1,
        ),
        PosColumn(
          text: '${product.price.toStringAsFixed(2)} fcfa',
          width: 1,
        ),
        PosColumn(
          text: '${productTotal.toStringAsFixed(2)} fcfa',
          width: 1,
        ),
      ]);
    }

    printer.hr();
    printer.row([
      PosColumn(
        text: 'Total :',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: '${totalCartPrice.toStringAsFixed(2)} fcfa',
        width: 1,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
    ]);
    printer.row([
      PosColumn(
        text: 'Somme remise :',
        width: 3,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '${amountPaid.toStringAsFixed(2)} fcfa',
        width: 1,
        styles: PosStyles(align: PosAlign.left),
      ),
    ]);
    printer.row([
      PosColumn(
        text: 'Somme rendue :',
        width: 3,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '${(amountPaid - totalCartPrice).toStringAsFixed(2)} fcfa',
        width: 1,
        styles: PosStyles(align: PosAlign.left),
      ),
    ]);
    printer.hr();
    printer.text('Youmaz vous remercie pour votre achat!!!');
    printer.feed(2);


    printer.cut();
    printer.disconnect(); // Fermez la connexion après l'impression

    Get.snackbar('Impression', 'Ticket imprimé avec succès');
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = pw.Document();

    // Ajoutez le contenu de votre ticket au document ici
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text('Ticket de caisse', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Text('Entreprise : $businessName', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Text('Adresse : $businessAddress', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text('Numéro de téléphone : $businessPhoneNumber', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 24),
              pw.Table.fromTextArray(
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['Produit', 'Quantité', 'Prix unitaire', 'Total'],
                data: [
                  ...cartItems.map((cartItem) {
                    final product = cartItem.product;
                    final quantity = cartItem.quantity;
                    final productTotal = product.price * quantity;

                    return [
                      product.name,
                      quantity.toString(),
                      '${product.price.toStringAsFixed(2)} fcfa',
                      '${productTotal.toStringAsFixed(2)} fcfa',
                    ];
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(height: 8, thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total :', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${totalCartPrice.toStringAsFixed(2)} fcfa', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(height: 8, thickness: 0, color: PdfColors.black),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Somme remise :', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('${amountPaid.toStringAsFixed(2)} fcfa', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Somme rendue :', style: pw.TextStyle(fontSize: 16)),
                  pw.Text('${(amountPaid - totalCartPrice).toStringAsFixed(2)} fcfa', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text('Youmaz vous remercie pour votre achat!!!', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),


            ],

          );


        },


      ),


    );


    // Obtenez le répertoire de documents de l'utilisateur
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/ticket.pdf';

    // Enregistrez le PDF localement
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Ouvrez le PDF après l'avoir enregistré
    final result = await OpenFile.open(path);

    if (result.type == ResultType.done) {
      Get.snackbar('Ouverture PDF', 'Ticket PDF ouvert avec succès');
    } else {
      Get.snackbar('Ouverture PDF', 'Impossible d\'ouvrir le PDF');
    }


    Get.snackbar('Enregistrement PDF', 'Ticket PDF enregistré avec succès');
  }




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
          IconButton(
            onPressed: _generateAndSavePDF,
            icon: const Icon(Icons.print),
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

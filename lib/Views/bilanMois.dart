import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Components/app_bar.dart';
import 'package:youmazgestion/controller/HistoryController.dart';

import 'bilanDesJourne.dart';


class BilanMois extends StatefulWidget {
  @override
  _BilanMoisState createState() => _BilanMoisState();
}

class _BilanMoisState extends State<BilanMois> {
  final HistoryController controller = Get.put(HistoryController());
  DateTime selectedDate = DateTime.now();

  void refreshData(DateTime selectedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      controller.refreshOrders();
      controller.getTotalSumOrdersByMonth(selectedDate);
      controller.getOrderCountByMonth(selectedDate);
      controller.getProductQuantitiesByMonth(selectedDate);
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Bilan du mois'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Redirect to BilanDesJourne page
                  Get.to(BilanDesJourne(selectedDate: selectedDate));
                },
                child: Text('Voir les jours'),
              ),

              SizedBox(height: 20),

              Obx(() => Text(
                'Chiffre réalisé : ${controller.totalSum.value.toStringAsFixed(2)} fcfa',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              )),
              SizedBox(height: 20),
              Obx(() => Text(
                'Total de commandes : ${controller.orderQuantity.value}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              )),
              SizedBox(height: 20),
              Text(
                'Detail produit :',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                child: FutureBuilder<Map<String, int>>(
                  future: controller.getProductQuantitiesByMonth(selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Erreur lors de la récupération des quantités de produits');
                    } else {
                      final quantities = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(height: 20),
                          Expanded(child:
                          ListView.builder(
                            itemCount: quantities.length,
                            itemBuilder: (context, index) {
                              final entry = quantities.entries.elementAt(index);
                              return ListTile(
                                leading: Icon(Icons.shopping_cart),
                                title: Text(
                                  entry.key,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Text('Quantité : ${entry.value}', style: TextStyle(fontSize: 16)),
                              );
                            },
                          ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => refreshData(selectedDate),
        backgroundColor: Colors.deepOrange,
        focusColor: Colors.deepOrangeAccent,
        hoverColor: Colors.deepOrangeAccent,
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime(DateTime.now().year + 5),
            );
            if (pickedDate != null) {
              refreshData(pickedDate);
            }
          },
          child: Text(
            'Changer la date',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
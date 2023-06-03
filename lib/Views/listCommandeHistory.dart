import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Components/app_bar.dart';
import 'package:youmazgestion/Views/voirPlus.dart';
import 'package:youmazgestion/controller/HistoryController.dart';
import '../Models/Order.dart';
import 'package:youmazgestion/Views/detailHistory.dart';

class HistoryDetailPage extends StatelessWidget {
  final DateTime selectedDate;
  final HistoryController controller = Get.find();
  double totalSum = 0.0;
  late Future<Map<String, int>> productQuantities;

  HistoryDetailPage({required this.selectedDate}) {
    calculateTotalSum();
    totalQuantity();
  }

  void calculateTotalSum() {
    totalSum = controller.getTotalSumOrdersByStartDate(selectedDate);
  }

  void totalQuantity() {
    productQuantities = controller.getProductQuantitiesByDate(selectedDate);
    print(productQuantities);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Historique de la journée'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        controller.refreshOrders();
                        calculateTotalSum();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Rafraîchir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FutureBuilder<Map<String, int>>(
                              future: productQuantities,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return VoirPlusPage(productQuantities: snapshot.data!);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.feed_outlined, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Voir Plus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Total Somme: $totalSum fcfa',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Order>>(
                  future: controller.getOrdersByStartDate(selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Une erreur s\'est produite',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    final orders = snapshot.data;

                    if (orders == null || orders.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune commande trouvée pour cette journée',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];

                        return Card(
                          elevation: 4.0,
                          shadowColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  'Commande #${order.id}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    'Terminé',

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),

                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('Total: ${order.totalPrice} fcfa'),
                            trailing: Text('Date: ${order.dateTime}'),
                            leading: Text('vendeur: ${order.user}'),
                            onTap: () {
                              Get.to(() => DetailPage(order: order));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
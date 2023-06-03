import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youmazgestion/Components/app_bar.dart';
import 'package:youmazgestion/Models/order.dart';
import 'package:intl/intl.dart';
import '../Components/appDrawer.dart';
import '../controller/HistoryController.dart';
import 'listCommandeHistory.dart';

class HistoryPage extends GetView<HistoryController> {
  HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Historique'),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                controller.refreshOrders();
                controller.onInit();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text(
                'Rafraîchir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
                  () {
                final distinctDates = controller.workDays;

                if (distinctDates.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune journée de travail trouvée',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: distinctDates.length,
                  itemBuilder: (context, index) {
                    final date = distinctDates[index];
                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        title: Text(
                          'Journée du $date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Colors.deepOrange,
                        ),
                        onTap: () => navigateToDetailPage(date),
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
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      print('parsedDate1: $parsedDate');
      final formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      print('formattedDate1: $formattedDate');
      return formattedDate;
    } catch (e) {
      print('Error parsing date: $date');
      return '';
    }
  }

  // transformer string en DateTime
  void navigateToDetailPage(String selectedDate) {
    print('selectedDate: $selectedDate');
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(selectedDate);
    print('parsedDate: $parsedDate');

    Get.to(() => HistoryDetailPage(selectedDate: parsedDate));
  }
}

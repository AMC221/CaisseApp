import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'listCommandeHistory.dart';

class BilanDesJourne extends StatelessWidget {
  final DateTime selectedDate;

  BilanDesJourne({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bilan des Journées'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jours du mois',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: DateTime(selectedDate.year, selectedDate.month + 1, 0).day,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date = DateTime(selectedDate.year, selectedDate.month, day);
                  final formattedDate = '${date.day}-${date.month}-${date.year}';

                  return ListTile(
                    title: Text(
                      'Jour $day',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(formattedDate, style: TextStyle(fontSize: 16)),
                    onTap: () {
                      // Handle the day selection
                      // You can navigate to a specific page or perform any action
                      navigateToDetailPage(date.toString());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void navigateToDetailPage(String selectedDate) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(selectedDate);
    Get.to(() => HistoryDetailPage(selectedDate: parsedDate));
  }
}

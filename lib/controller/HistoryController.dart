import 'package:get/get.dart';
import '../Models/Order.dart';
import '../Services/OrderDatabase.dart';
import '../Services/WorkDatabase.dart';

class HistoryController extends GetxController {
  final OrderDatabase _orderDatabase = OrderDatabase.instance;
  final WorkDatabase _workDatabase = WorkDatabase.instance;
  final RxList<Order> orders = <Order>[].obs;
  late RxList<Map<String, dynamic>> orderItems = <Map<String, dynamic>>[].obs;
  late RxList<Order> filteredOrders = <Order>[].obs;
  late RxList<String> workDays = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize databases
    _orderDatabase.initDatabase();
    _workDatabase.initDatabase();

    // Fetch orders and work days
    fetchOrders();
    fetchWorkDays();
  }

  Future<void> fetchOrders() async {
    try {
      final orderHistory = await _orderDatabase.getOrderHistory();
      orders.value = orderHistory;
    } catch (e) {
      // Handle the error
    }
  }

  Future<void> fetchOrderItems(int orderId) async {
    final items = await _orderDatabase.getOrderItems(orderId);
    orderItems.value = items;
  }

  Future<void> refreshOrders() async {
    final newOrders = await _orderDatabase.getOrderHistory();
    orders.value = newOrders;
  }

  Future<void> fetchWorkDays() async {
    try {
      final workDates = await WorkDatabase.instance.getDates();
      workDays.value = workDates;
    } catch (e) {
      print(e);
      // Handle the error
    }
  }


  List<DateTime?> getDistinctDates() {
    final currentDate = DateTime.now();
    final dates = [...orders.map((order) => order.startDate), currentDate]
        .where((date) => date != null)
        .toList();
    return dates.toSet().toList();
  }

  List<Order> filterOrdersByDateRange(DateTime startDate) {
    final filteredList = orders
        .where((order) => order.startDate != null && order.startDate!.isAtSameMomentAs(startDate))
        .toList();
    filteredOrders.value = filteredList;
    return filteredList;
  }

  Future<List<Order>> getOrdersByStartDate(DateTime startDate) async {
    try {
      final ordersByStartDate = await _orderDatabase.getOrdersByStartDate(startDate);
      return ordersByStartDate;
    } catch (e) {
      print(e);
      return [];
    }
  }

  double getTotalSumOrdersByStartDate (DateTime startDate) {
    final filteredOrders = filterOrdersByDateRange(startDate);
    double totalSum = filteredOrders.fold(0, (sum, order) => sum + order.totalPrice);
    return totalSum;
  }

  /*Future<Map<String, int>> getProductQuantitiesByDate(DateTime date) async {
    try {
      // Filter orders by the specified date
      final ordersByDate = await _orderDatabase.getOrdersByStartDate(date);

      // Retrieve order items for the filtered orders
      final orderItems = <Map<String, dynamic>>[];
      for (final order in ordersByDate) {
        final items = await _orderDatabase.getOrderItems(order.id);
        orderItems.addAll(items);
      }

      // Calculate product quantities
      final productQuantities = <String, int>{};
      for (final item in orderItems) {
        final productId = item['product_id'] as String;
        final quantity = item['quantity'] as int;
        if (productQuantities.containsKey(productId)) {
          productQuantities[productId] = productQuantities[productId]! + quantity;
        } else {
          productQuantities[productId] = quantity;
        }
      }

      return productQuantities;
    } catch (e) {
      print(e);
      return {};
    }
  }*/

  Future<Map<String, int>> getProductQuantitiesByDate(DateTime date) async {
    try {
      return await _orderDatabase.getProductQuantitiesByDate(date);
    } catch (e) {
      print(e);
      return {};
    }
  }


}

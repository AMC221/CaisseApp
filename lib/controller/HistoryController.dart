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
  RxDouble totalSum = RxDouble(0.0);
  RxInt orderQuantity = RxInt(0);

  @override
  void onInit() {
    super.onInit();

    // Initialize databases
    _orderDatabase.initDatabase();
    _workDatabase.initDatabase();

    // Fetch orders and work days
    fetchOrders();
    fetchWorkDays();
    getTotalSumOrdersByMonth(DateTime.now());
    getOrdersByMonth(DateTime.now());
    getOrderCountByMonth(DateTime.now());


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
      final workDates = await WorkDatabase.instance.getDatesDesc();
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

  Future<RxDouble> getTotalSumOrdersByMonth(DateTime date) async {
    final filteredOrders = await getOrdersByMonth(date);
    double totalsum = filteredOrders.fold(0, (sum, order) => sum + order.totalPrice);
    totalSum.value = totalsum;
    print(totalSum.value);
    return totalSum;

  }

 Future<Map<String, int>> getProductQuantitiesByDate(DateTime date) async {
    try {
      return await _orderDatabase.getProductQuantitiesByDate(date);
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map<String, int>> getProductQuantitiesByMonth(DateTime date) async {
    try {
      return await _orderDatabase.getProductQuantitiesByMonth(date);
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<List<Order>> getOrdersByMonth(DateTime date) async {
    try {
      final ordersByMonth = await _orderDatabase.getOrdersByMonth(date);
      print("ma");
      return ordersByMonth;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Order>> getOrdersByYear(DateTime date) async {
    try {
      final ordersByYear = await _orderDatabase.getOrdersByYear(date);
      return ordersByYear;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Order>> getOrdersByWeek(int week) async {
    try {
      final ordersByWeek = await _orderDatabase.getOrdersByWeekNumber(week);
      return ordersByWeek;
    } catch (e) {
      print(e);
      return [];
    }
  }



  Future<int> getOrderCountByMonth(DateTime month) async {
    List<Order> orders = await getOrdersByMonth(month);
    int orderCount = orders.length;
    orderQuantity.value = orderCount;
    return orderCount;
  }




}

class Order {
  final int id;
  final double totalPrice;
  final String dateTime;
  final DateTime? startDate;

  Order({
    required this.id,
    required this.totalPrice,
    required this.dateTime,
    this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_price': totalPrice,
      'date_time': dateTime,
      'start_date': startDate != null ? startDate!.toIso8601String() : null,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      totalPrice: map['total_price'],
      dateTime: map['date_time'],
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
    );
  }
}

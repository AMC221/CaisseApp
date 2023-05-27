class Work {
  final int? id;
  final String date;

  Work({
    this.id,
    required this.date,
  });

  Work copy({
    int? id,
    String? date,
  }) =>
      Work(
        id: id ?? this.id,
        date: date ?? this.date,
      );

  factory Work.fromJson(Map<String, dynamic> json) => Work(
        id: json['id'] as int?,
        date: json['date'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
      };
}
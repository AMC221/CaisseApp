class Product {
  final int? id;
  final String name;
  final double price;
   String image;
   final  String category;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {

      'name': name,
      'price': price,
      'image': image,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      image: map['image'],
      category: map['category'],
    );
  }
}

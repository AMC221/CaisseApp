class Product {
  final int? id;
  final String name;
  final double price;
  String image;
  final String category;
  int? stock;// Paramètre optionnel pour le stock


  Product({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.stock =0,
  });

  //verifier si le stock est défini si definie on retourne true sinon false
  bool isStockDefined(){
    if(stock != null){
      print("stock is defined : $stock ""$name");
      return true;
    }else{
      return false;
    }
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock, // Ajout du stock dans le mappage
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      image: map['image'],
      category: map['category'],
      stock: map['stock'], // Récupération du stock depuis le mappage
    );
  }
}

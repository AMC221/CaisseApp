import 'package:get/get.dart';

import '../Models/produit.dart';

class ProductController extends GetxController {
  final _products = <Product>[].obs;

  List<Product> get products => _products.toList();

  void setProducts(List<Product> productList) {
    _products.clear();
    _products.addAll(productList);
  }

  void addProduct(Product product) {
    _products.add(product);
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((product) => product.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
    }
  }

  void deleteProduct(int ?productId) {
    _products.removeWhere((product) => product.id == productId);
  }
}

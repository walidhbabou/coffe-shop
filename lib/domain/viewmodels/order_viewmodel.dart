import 'package:flutter/material.dart';
import '../../data/models/drink.dart';
import '../../data/services/product_service.dart';

class OrderViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Drink> _drinks = [];
  bool _isLoading = false;
  String? _error;

  List<Drink> get drinks => _drinks;
  List<Drink> get favorites => _drinks.where((d) => d.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderViewModel() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final products = await _productService.fetchProducts();
      _drinks = products;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}

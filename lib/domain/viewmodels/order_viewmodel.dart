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
      _drinks = products.map((drink) => Drink.fromJson(drink.toJson())..isFavorite = false).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void addFavorite(Drink drink) {
    final index = _drinks.indexWhere((d) => d.id == drink.id);
    if (index != -1) {
      _drinks[index].isFavorite = true;
      notifyListeners();
    }
  }

  void removeFavorite(Drink drink) {
    final index = _drinks.indexWhere((d) => d.id == drink.id);
    if (index != -1) {
      _drinks[index].isFavorite = false;
      notifyListeners();
    }
  }

  bool isFavorite(Drink drink) {
    final index = _drinks.indexWhere((d) => d.id == drink.id);
    return index != -1 ? _drinks[index].isFavorite : false;
  }
}

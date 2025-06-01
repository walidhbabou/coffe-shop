import 'package:flutter/material.dart';
import '../../data/models/drink.dart';
import '../../data/services/product_service.dart';
import 'package:coffee_shop/data/services/user_data_service.dart';

class OrderViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Drink> _drinks = [];
  List<String> _favorites = [];
  Map<String, int> _cart = {};
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;
  bool _isCartLocked = false;
  bool _isFirstValidation = false;

  List<Drink> get drinks => _drinks;
  List<Drink> get favorites =>
      _drinks.where((d) => _favorites.contains(d.id)).toList();
  Map<String, int> get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCartLocked => _isCartLocked;
  bool get isFirstValidation => _isFirstValidation;

  OrderViewModel() {
    fetchProducts();
    loadUserData();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final products = await _productService.fetchProducts();
      _drinks =
          products.map((drink) => Drink.fromJson(drink.toJson())).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    _favorites = await UserDataService.loadFavorites();
    _cart = await UserDataService.loadCart();
    _orders = await UserDataService.loadOrders();
    notifyListeners();
  }

  bool isFavorite(Drink drink) {
    return _favorites.contains(drink.id);
  }

  List<MapEntry<Drink, int>> get cartEntries {
    return _cart.entries.map((entry) {
      final drink = _drinks.firstWhere((d) => d.id == entry.key);
      return MapEntry(drink, entry.value);
    }).toList();
  }

  void clearCart() {
    _cart.clear();
    UserDataService.saveCart(_cart);
    notifyListeners();
  }

  void addFavorite(String drinkId) {
    if (!_favorites.contains(drinkId)) {
      _favorites.add(drinkId);
      UserDataService.saveFavorites(_favorites);
      notifyListeners();
    }
  }

  void removeFavorite(String drinkId) {
    if (_favorites.remove(drinkId)) {
      UserDataService.saveFavorites(_favorites);
      notifyListeners();
    }
  }

  void addToCart(String drinkId) {
    if (!_isCartLocked) {
      _cart.update(drinkId, (q) => q + 1, ifAbsent: () => 1);
      UserDataService.saveCart(_cart);
      notifyListeners();
    }
  }

  void removeFromCart(String drinkId) {
    if (!_isCartLocked && _cart.containsKey(drinkId)) {
      if (_cart[drinkId]! > 1) {
        _cart[drinkId] = _cart[drinkId]! - 1;
      } else {
        _cart.remove(drinkId);
      }
      UserDataService.saveCart(_cart);
      notifyListeners();
    }
  }

  void removeAllFromCart(String drinkId) {
    if (!_isCartLocked && _cart.containsKey(drinkId)) {
      _cart.remove(drinkId);
      UserDataService.saveCart(_cart);
      notifyListeners();
    }
  }

  Future<void> lockCart() async {
    _isCartLocked = true;
    notifyListeners();
  }

  Future<void> unlockCart() async {
    _isCartLocked = false;
    _isFirstValidation = false;
    notifyListeners();
  }

  Future<void> addOrder(double total) async {
    await UserDataService.addOrder(_cart, total);
    _orders = await UserDataService.loadOrders();
    _cart.clear();
    _isCartLocked = false;
    UserDataService.saveCart(_cart);
    notifyListeners();
  }

  Future<void> firstValidation() async {
    _isFirstValidation = true;
    notifyListeners();
  }

  Future<void> finalValidation() async {
    _isCartLocked = true;
    _isFirstValidation = false;
    notifyListeners();
  }
}

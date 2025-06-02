import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/drink.dart';

class ProductService {
  static const String _baseUrl = 'https://coffee-shop-api-sandy.vercel.app/api/v1/products';

  Future<List<Drink>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Drink.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Stocke la liste des produits dans Firestore, chaque produit avec son id comme document
  Future<void> storeProductsInFirestore(List<Drink> products) async {
    final collection = FirebaseFirestore.instance.collection('products');
    final batch = FirebaseFirestore.instance.batch();
    for (final product in products) {
      final docRef = collection.doc(product.id);
      batch.set(docRef, product.toJson());
    }
    await batch.commit();
  }

  /// Récupère les produits et les stocke automatiquement dans Firestore
  Future<List<Drink>> fetchAndStoreProducts() async {
    final products = await fetchProducts();
    await storeProductsInFirestore(products);
    return products;
  }

  /// Récupère les produits depuis Firestore
  Future<List<Drink>> fetchProductsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) => Drink.fromJson(doc.data())).toList();
  }
}

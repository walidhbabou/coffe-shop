import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drink.dart';

class ProductService {
  static const String _baseUrl = 'https://coffee-shop-api-sandy.vercel.app/api/v1/products';

  Future<List<Drink>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Drink.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}

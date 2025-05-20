import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://coffee-shop-api-sandy.vercel.app/api/v1/products';
  final response = await http.get(Uri.parse(url));
  print('Status: ${response.statusCode}');
  print('Body:');
  final List<dynamic> data = json.decode(response.body);
  print('Nombre de produits: ${data.length}');
  for (var item in data) {
    print('Produit: ${item['title']}');
  }
}
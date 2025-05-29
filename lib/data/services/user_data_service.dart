import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> saveFavorites(List<String> favorites) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'favorites': favorites}, SetOptions(merge: true));
    }
  }

  static Future<List<String>> loadFavorites() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return List<String>.from(doc.data()?['favorites'] ?? []);
    }
    return [];
  }

  static Future<void> saveCart(Map<String, int> cart) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'cart': cart}, SetOptions(merge: true));
    }
  }

  static Future<Map<String, int>> loadCart() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data()?['cart'] ?? {};
      return Map<String, int>.from(data);
    }
    return {};
  }

  static Future<void> addOrder(Map<String, int> cart, double total) async {
    final user = _auth.currentUser;
    if (user != null) {
      final order = {
        'date': DateTime.now().toIso8601String(),
        'items': cart,
        'total': total,
      };
      final ref = _firestore.collection('users').doc(user.uid);

      // Ensure the 'orders' field exists as an array before adding to it.
      await ref.set({'orders': []}, SetOptions(merge: true));

      await ref.update({
        'orders': FieldValue.arrayUnion([order])
      });
    }
  }

  static Future<List<Map<String, dynamic>>> loadOrders() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final orders = doc.data()?['orders'] ?? [];
      return List<Map<String, dynamic>>.from(orders);
    }
    return [];
  }
}

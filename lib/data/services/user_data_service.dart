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

  static Future<void> savePersonalInfo({
    required String displayName,
    required String phoneNumber,
    required bool emailNotifications,
    required bool pushNotifications,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Mettre à jour le profil Firebase Auth
        await user.updateDisplayName(displayName);
        
        // Mettre à jour Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName,
          'phoneNumber': phoneNumber,
          'preferences': {
            'emailNotifications': emailNotifications,
            'pushNotifications': pushNotifications,
          }
        }, SetOptions(merge: true));
      } catch (e) {
        print('Erreur lors de la sauvegarde des informations: $e');
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> loadPersonalInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data() ?? {};
    }
    return {};
  }

  static Future<void> addPaymentMethod({
    required String cardType,
    required String lastFourDigits,
    required String expiryDate,
    required bool isDefault,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment_methods')
          .add({
        'cardType': cardType,
        'lastFourDigits': lastFourDigits,
        'expiryDate': expiryDate,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> paymentMethodsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment_methods')
          .orderBy('createdAt', descending: false)
          .snapshots();
    } else {
      // Retourne un stream vide si pas connecté
      return const Stream.empty();
    }
  }

  static Future<void> deletePaymentMethod(String paymentMethodId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment_methods')
          .doc(paymentMethodId)
          .delete();
    }
  }

  static Future<void> addAddress({
    required String title,
    required String address,
    required String postalCode,
    required String city,
    required bool isDefault,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add({
        'title': title,
        'address': address,
        'postalCode': postalCode,
        'city': city,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> addressesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .orderBy('createdAt', descending: false)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }
}

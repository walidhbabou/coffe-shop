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

  static Stream<QuerySnapshot<Map<String, dynamic>>> paymentMethodsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .snapshots();
  }

  static Future<void> addPaymentMethod({
    required String cardType,
    required String lastFourDigits,
    required String expiryDate,
    required bool isDefault,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utilisateur non connecté');

    // Si c'est la carte par défaut, mettre à jour les autres cartes
    if (isDefault) {
      final batch = _firestore.batch();
      final otherCards = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .where('isDefault', isEqualTo: true)
          .get();

      for (var doc in otherCards.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }

    // Ajouter la nouvelle carte
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .add({
      'cardType': cardType,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deletePaymentMethod(String paymentMethodId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .doc(paymentMethodId)
        .delete();
  }

  static Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utilisateur non connecté');

    final batch = _firestore.batch();
    
    // Mettre à jour toutes les cartes pour les marquer comme non par défaut
    final otherCards = await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in otherCards.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    // Marquer la carte sélectionnée comme par défaut
    batch.update(
      _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_methods')
          .doc(paymentMethodId),
      {'isDefault': true},
    );

    await batch.commit();
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

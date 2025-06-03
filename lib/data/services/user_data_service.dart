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
        .orderBy('createdAt', descending: false)
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

  // Méthode pour ajouter un favori
  static Future<void> addFavorite(String drinkId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userRef = _firestore.collection('users').doc(user.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          // Créer le document utilisateur s'il n'existe pas
          await userRef.set({
            'favorites': [drinkId],
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Ajouter le favori à la liste existante
          await userRef.update({
            'favorites': FieldValue.arrayUnion([drinkId])
          });
        }
      } catch (e) {
        print('Erreur lors de l\'ajout du favori: $e');
        rethrow;
      }
    }
  }

  // Méthode pour supprimer un favori
  static Future<void> removeFavorite(String drinkId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'favorites': FieldValue.arrayRemove([drinkId])
        });
      } catch (e) {
        print('Erreur lors de la suppression du favori: $e');
        rethrow;
      }
    }
  }

  // Méthode pour vérifier si une boisson est en favori
  static Future<bool> isFavorite(String drinkId) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
        return favorites.contains(drinkId);
      } catch (e) {
        print('Erreur lors de la vérification du favori: $e');
        return false;
      }
    }
    return false;
  }

  // Méthode pour obtenir tous les favoris d'un utilisateur
  static Future<List<String>> getFavorites() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return List<String>.from(doc.data()?['favorites'] ?? []);
      } catch (e) {
        print('Erreur lors de la récupération des favoris: $e');
        return [];
      }
    }
    return [];
  }

  // Stream pour écouter les changements des favoris en temps réel
  static Stream<List<String>> favoritesStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => List<String>.from(doc.data()?['favorites'] ?? []));
    }
    return Stream.value([]);
  }

  // Méthode pour obtenir la liste de tous les utilisateurs pour l'admin
  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) =>
              doc.data() as Map<String, dynamic>..addAll({'uid': doc.id}))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de tous les utilisateurs: $e');
      return []; // Return an empty list on error
    }
  }

  // Méthode pour supprimer un utilisateur par son UID (pour l'admin)
  static Future<void> deleteUser(String uid) async {
    try {
      // Vérifier si l'utilisateur est l'admin
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['email'] == 'admin@coffeeapp.com') {
        throw Exception(
            'Impossible de supprimer le compte administrateur principal');
      }

      // Supprimer les documents des sous-collections (par exemple, payment_methods, addresses)
      // Note : Cela ne gère pas les données liées dans d'autres collections top-level ou les utilisateurs Firebase Auth (nécessite une logique côté serveur pour la sécurité).

      // Supprimer la sous-collection 'payment_methods'
      final paymentMethods = await _firestore
          .collection('users')
          .doc(uid)
          .collection('payment_methods')
          .get();
      for (var doc in paymentMethods.docs) {
        await doc.reference.delete();
      }
      print(
          'Sous-collection payment_methods pour l\'utilisateur $uid supprimée.');

      // Supprimer la sous-collection 'addresses'
      final addresses = await _firestore
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .get();
      for (var doc in addresses.docs) {
        await doc.reference.delete();
      }
      print('Sous-collection addresses pour l\'utilisateur $uid supprimée.');

      // Supprimer le document utilisateur principal
      await _firestore.collection('users').doc(uid).delete();
      print('Document utilisateur avec UID $uid supprimé de Firestore.');
    } catch (e) {
      print(
          'Erreur lors de la suppression de l\'utilisateur et de ses données liées $uid: $e');
      rethrow; // Relancer l'erreur
    }
  }
}

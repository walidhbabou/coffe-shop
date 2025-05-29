import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<void> createAdminIfNotExists() async {
  const adminEmail = 'admin@coffeeapp.com';
  const adminPassword = 'AdminPassword123';

  try {
    debugPrint('Vérification de l\'existence du compte admin...');
    
    // Hacher le mot de passe
    final hashedPassword = sha256.convert(utf8.encode(adminPassword)).toString();
    
    // Rechercher l'admin par email dans Firestore
    final existingAdminDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .limit(1)
        .get();

    if (existingAdminDoc.docs.isEmpty) {
      debugPrint('Aucun compte admin trouvé dans Firestore. Création du document...');

      final adminDocRef = FirebaseFirestore.instance.collection('users').doc(adminEmail);

      await adminDocRef.set({
        'role': 'admin',
        'email': adminEmail,
        'passwordHash': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      debugPrint('Document admin créé avec succès dans Firestore.');
      debugPrint('Email: $adminEmail');
    } else {
      debugPrint('Document admin trouvé dans Firestore.');
      final adminData = existingAdminDoc.docs.first.data();
      
      if (adminData['role'] != 'admin' || adminData['passwordHash'] == null) {
        debugPrint('Le document admin existe mais nécessite une mise à jour (rôle/mot de passe).');
        final adminDocRef = existingAdminDoc.docs.first.reference;
        await adminDocRef.update({
          'role': 'admin',
          'passwordHash': hashedPassword,
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        debugPrint('Document admin mis à jour dans Firestore.');
      } else {
        debugPrint('Document admin déjà existant et correctement configuré.');
      }
      
      await existingAdminDoc.docs.first.reference.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }

  } on FirebaseException catch (e) {
    debugPrint('Erreur Firebase lors de la création/vérification de l\'admin: ${e.code} - ${e.message}');
    rethrow; // Propager l'erreur pour la gestion au niveau supérieur
  } catch (e) {
    debugPrint('Erreur inattendue lors de la création/vérification de l\'admin: $e');
    rethrow; // Propager l'erreur pour la gestion au niveau supérieur
  }
}
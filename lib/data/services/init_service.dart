import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createAdminIfNotExists() async {
  const adminEmail = 'admin@coffeeapp.com';
  const adminPassword = 'AdminPassword123'; // Mot de passe de l'admin

  try {
    print('Vérification de l\'existence du compte admin...');
    // Rechercher l'admin par email dans Firestore
    final existingAdminDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .limit(1)
        .get();

    if (existingAdminDoc.docs.isEmpty) {

      print('Aucun compte admin trouvé dans Firestore. Création du document...');

 
      final adminDocRef = FirebaseFirestore.instance.collection('users').doc(adminEmail); // Utilisation de l'email comme ID de document

      await adminDocRef.set({
        'role': 'admin',
        'email': adminEmail,
        'password': adminPassword, // TODO: HACHER CE MOT DE PASSE AVANT DE LE STOCKER !
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      print('Document admin créé avec succès dans Firestore.');
      print('Email: $adminEmail');
      print('Mot de passe (texte clair - À HACHER!): $adminPassword');

    } else {
      // Si un document admin existe, vérifier si le mot de passe est stocké et si le rôle est correct.
      print('Document admin trouvé dans Firestore.');
      final adminData = existingAdminDoc.docs.first.data();
      
      // Mettre à jour si le rôle n'est pas 'admin' ou si le mot de passe n'est pas présent (pour la transition)
      if (adminData['role'] != 'admin' || adminData['password'] == null) {
         print('Le document admin existe mais nécessite une mise à jour (rôle/mot de passe).');
         final adminDocRef = existingAdminDoc.docs.first.reference;
         await adminDocRef.update({
            'role': 'admin',
            'password': adminPassword, // TODO: HACHER CE MOT DE PASSE LORS DE LA MISE À JOUR!
            'lastLogin': FieldValue.serverTimestamp(), // Mettre à jour la dernière connexion
            'isActive': true,
         });
          print('Document admin mis à jour dans Firestore.');
          print('Email: $adminEmail');
          print('Mot de passe (texte clair - À HACHER!): $adminPassword');
      } else {
         print('Document admin déjà existant et correctement configuré.');
      }
      
       // Mettre à jour lastLogin même si pas de changement de rôle/mdp, juste pour l'activité
       await existingAdminDoc.docs.first.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
         });
    }

  } on FirebaseException catch (e) {
    print('Erreur Firebase lors de la création/vérification de l\'admin: ${e.code} - ${e.message}');
  } catch (e) {
    print('Erreur inattendue lors de la création/vérification de l\'admin: $e');
  }
}
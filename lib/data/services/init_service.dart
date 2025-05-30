import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<void> createAdminIfNotExists() async {
  const adminEmail = 'admin@coffeeapp.com';
  const adminPassword = 'AdminPassword123';

  try {
    debugPrint('Vérification et création du compte admin si nécessaire...');

    User? firebaseAuthUser;

    try {
      // Attempt to create the user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      firebaseAuthUser = userCredential.user;
      debugPrint('Admin user created successfully in Firebase Auth.');

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User already exists in Firebase Auth, sign them in to get the User object
        debugPrint('Admin email already in use in Firebase Auth. Signing in to get user...');
        try {
           final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          firebaseAuthUser = userCredential.user;
           debugPrint('Successfully signed in existing admin user from Firebase Auth.');
        } on FirebaseAuthException catch (signInError) {
           debugPrint('Error signing in existing admin user: ${signInError.code} - ${signInError.message}');
           // If signing in fails for the existing user, we cannot proceed reliably.
           rethrow; // Rethrow the sign-in error
        }
      } else {
        // Other Firebase Auth errors during creation attempt
        debugPrint('Firebase Auth Error during admin creation: ${e.code} - ${e.message}');
        rethrow; // Rethrow other unexpected auth errors
      }
    }

    // If we successfully got a Firebase Auth user (either by creation or sign-in)
    if (firebaseAuthUser != null) {
       final adminUid = firebaseAuthUser.uid;
       debugPrint('Firebase Auth Admin UID: $adminUid');

       // Now, ensure the corresponding Firestore document exists and is correct
       final firestoreDocRef = FirebaseFirestore.instance.collection('users').doc(adminUid);
       final firestoreDoc = await firestoreDocRef.get();

       if (!firestoreDoc.exists) {
         debugPrint('Admin document not found in Firestore for UID: $adminUid. Creating document...');

         // Hash the password before storing in Firestore (optional, but good practice if you ever rely on this)
         final hashedPassword = sha256.convert(utf8.encode(adminPassword)).toString();

         await firestoreDocRef.set({
            'role': 'admin',
            'email': adminEmail, // Store email for easy lookup/reference
            'passwordHash': hashedPassword, // Store hashed password (optional)
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
          });
          debugPrint('Admin document created in Firestore for UID: $adminUid.');

       } else {
         debugPrint('Admin document found in Firestore for UID: $adminUid.');
         // Check and update the existing document if necessary
         final adminData = firestoreDoc.data() as Map<String, dynamic>?;

         if (adminData?['role'] != 'admin' || adminData?['email'] != adminEmail) {
            debugPrint('Updating existing admin document in Firestore.');
             // Re-hash password in case it was updated manually somewhere else?
             // Or rely solely on Firebase Auth for password. Sticking to updating role/email here.
             await firestoreDocRef.update({
               'role': 'admin',
               'email': adminEmail,
               'lastLogin': FieldValue.serverTimestamp(),
               'isActive': true, // Ensure isActive is true
             });
             debugPrint('Admin document updated in Firestore.');
         } else {
             // Just update last login timestamp if document is already correct
              await firestoreDocRef.update({'lastLogin': FieldValue.serverTimestamp()});
             debugPrint('Admin document already correctly configured in Firestore. Last login updated.');
         }
       }
    } else {
        // This case should ideally not be reached if Firebase Auth operations are successful
        debugPrint('Failed to obtain Firebase Auth user after creation/sign-in attempts.');
    }

  } on FirebaseException catch (e) {
    debugPrint('Erreur Firebase lors de la création/vérification de l\'admin: ${e.code} - ${e.message}');
    rethrow; // Propager l'erreur pour la gestion au niveau supérieur
  } catch (e) {
    debugPrint('Erreur inattendue lors de la création/vérification de l\'admin: $e');
    rethrow; // Propager l'erreur pour la gestion au niveau supérieur
  }
}
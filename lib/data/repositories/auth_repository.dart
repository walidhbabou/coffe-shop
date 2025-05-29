import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Removing Firebase Auth for email/password sign-in as requested
// The app will now rely on Firestore for authentication.
// WARNING: This approach is less secure than using Firebase Authentication
// directly for password management unless strong hashing is implemented.

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Still needed for Google Sign-In and auth state changes
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // Keep this to observe auth state changes from other methods (like Google Sign-In)

  // Modified method to sign in using Firestore collection
  Future<Map<String, dynamic>?> signInWithFirestore({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentative de connexion via Firestore...');
      print('Email: $email');
      
      if (email.isEmpty) {
        throw AuthException('L\'email ne peut pas être vide');
      }
      
      if (password.isEmpty) {
        throw AuthException('Le mot de passe ne peut pas être vide');
      }

      // Query Firestore for the user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Utilisateur non trouvé dans Firestore');
        throw AuthException('Aucun utilisateur trouvé avec cet email.');
      }

      final userData = querySnapshot.docs.first.data();
      final storedPasswordHash = userData['password']; // Assume password is stored (ideally as a hash)

      // TODO: Implement secure password verification here!
      // You MUST NOT store passwords in plain text. Implement a robust hashing and comparison mechanism.
      // Example (PLACEHOLDER - REPLACE WITH SECURE IMPLEMENTATION):
      // bool passwordMatches = verifyPassword(password, storedPasswordHash);
      bool passwordMatches = (password == storedPasswordHash); // DANGEROUS: Plain text password comparison - REPLACE THIS!

      if (!passwordMatches) {
        print('Mot de passe incorrect');
        throw AuthException('Mot de passe incorrect.');
      }

      print('Connexion Firestore réussie pour: $email');
      // Update last login timestamp
      await querySnapshot.docs.first.reference.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Return user data from Firestore
      return userData;
    } on AuthException catch (e) {
      print('Erreur de connexion Firestore: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erreur inattendue lors de la connexion Firestore: $e');
      throw AuthException('Une erreur inattendue est survenue lors de la connexion Firestore');
    }
  }

  // Modified method to sign up using Firestore collection
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
     try {
       print('Tentative d\'inscription via Firestore...');
       print('Email: $email');

       if (email.isEmpty) {
         throw AuthException('L\'email ne peut pas être vide');
       }

       if (password.isEmpty) {
         throw AuthException('Le mot de passe ne peut pas être vide');
       }

       // Vérifier si l\'utilisateur existe déjà
       final existingUserDoc = await _firestore
           .collection('users')
           .where('email', isEqualTo: email.trim())
           .limit(1)
           .get();

       if (existingUserDoc.docs.isNotEmpty) {
         print('Email déjà utilisé dans Firestore');
         throw AuthException('Cette adresse email est déjà utilisée.');
       }

       // TODO: HACHER LE MOT DE PASSE AVANT DE LE STOCKER !
       final hashedPassword = password; // DANGEROUS: Storing plain text password - REPLACE THIS!

       // Créer un nouveau document utilisateur dans Firestore
       // Utiliser l\'email comme ID de document est simple mais a des limitations
       // Considérer d\'utiliser un champ d\'ID unique différent de l\'email si l\'email peut changer.
       final newUserDocRef = _firestore.collection('users').doc(email.trim()); // Utilisation de l\'email comme ID

       final userData = {
         'role': 'user', // Rôle par défaut pour les nouvelles inscriptions
         'email': email.trim(),
         'password': hashedPassword, // TODO: STOCKER LE MOT DE PASSE HACHÉ !
         'createdAt': FieldValue.serverTimestamp(),
         'lastLogin': FieldValue.serverTimestamp(), // Mettre à jour lors de l\'inscription
         'isActive': true,
       };

       await newUserDocRef.set(userData);

       print('Inscription réussie dans Firestore pour: $email');
       return userData;

     } on AuthException catch (e) {
       print('Erreur d\'inscription Firestore: ${e.message}');
       rethrow;
     } catch (e) {
       print('Erreur inattendue lors de l\'inscription Firestore: $e');
       throw AuthException('Une erreur inattendue est survenue lors de l\'inscription Firestore');
     }
  }

  Future<User?> signInWithGoogle() async {
    // Keep Google Sign-In using Firebase Auth
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Connexion Google annulée');
      }
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        // Utiliser l\'UID de Firebase Auth comme ID de document Firestore pour les utilisateurs Google
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid) // Utilisation de l\'UID Firebase Auth
            .get();

        if (!userDoc.exists) {
          // Créer le document utilisateur s'il n'existe pas
          await _firestore.collection('users').doc(user.uid).set({
            'role': 'user',
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
            // TODO: Consider how to handle password for Google users if needed
            // (Not applicable if passwords are only stored for email/password users)
          });
           print('Document utilisateur Google créé dans Firestore pour UID: ${user.uid}');
        } else {
          // Mettre à jour lastLogin
          await userDoc.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
           print('Document utilisateur Google mis à jour dans Firestore pour UID: ${user.uid}');
        }
      }

      return user; // Retourne l\'utilisateur Firebase Auth pour Google Sign-In
    } on FirebaseAuthException catch (e) {
      throw AuthException('Erreur de connexion Google: ${e.message}');
    } catch (e) {
      throw AuthException('Erreur inattendue lors de la connexion Google');
    }
  }

  Future<void> signOut() async {
    // Sign out from Firebase Auth and Google Sign-In
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
       print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw AuthException('Erreur lors de la déconnexion');
    }
  }

  Future<void> resetPassword(String email) async {
    // Password reset needs manual implementation if not using Firebase Auth for passwords.
    print('Password reset via Firestore needs implementation.');
    throw UnimplementedError('Password reset not implemented for Firestore auth.');
  }

  Future<void> sendEmailVerification() async {
    // Email verification needs manual implementation if not using Firebase Auth for email/password.
     print('Email verification via Firestore needs implementation.');
     throw UnimplementedError('Email verification not implemented for Firestore auth.');
  }
  
  // Method to get user data from Firestore based on UID (or email if using email as ID)
  // This method now needs to handle both UID (for Google users) and email (for manual users)
  Future<Map<String, dynamic>?> getUserData(String identifier) async {
    try {
      // Assume identifier can be either Firebase Auth UID or email
      // If using email as doc ID for manual users, query by ID.
      // If using UID for Google users, query by ID.
      // A more robust approach might be to store UID in Firestore doc for manual users too.

       // Try getting by UID first (for Google users)
       DocumentSnapshot doc = await _firestore.collection('users').doc(identifier).get();

       if (!doc.exists) {
          // If not found by UID, try querying by email (for manual users if email is not doc ID)
          // Note: If email is used as doc ID for manual users, the previous get() call would have found it.
          // This part is mainly needed if you use different ID strategies.
          // Given our current plan to use email as doc ID for manual users, this else if might not be needed or needs adjustment.
          // For consistency, let's assume identifier is always the doc ID (either UID or email).
           print('Document utilisateur non trouvé par ID: $identifier');
           return null;
       }
       
      return doc.data() as Map<String, dynamic>?; // Cast to the expected type

    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
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
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentative de connexion via Firebase Auth...');
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If sign-in is successful, fetch user data from Firestore
      // We still need to fetch from Firestore to get the role and other data
      final user = userCredential.user;
      if (user != null) {
        final userData = await getUserData(user.uid); // Use UID to fetch user data
         print('Connexion Firebase Auth réussie pour: ${user.email}');
         // No need to update last login here, Firebase Auth handles it implicitly or you can add it to the auth state change listener
         return userData; // Return user data from Firestore
      }
      return null; // Should not happen if userCredential is not null

    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion Firebase Auth: ${e.code} - ${e.message}');
      // Translate specific Firebase Auth errors to our AuthException
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé avec cet email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format d\'email invalide.';
      } else if (e.code == 'user-disabled') {
         errorMessage = 'Cet utilisateur a été désactivé.';
      } else {
        errorMessage = 'Erreur de connexion: ${e.message}';
      }
      throw AuthException(errorMessage); // Throw our custom exception
    } catch (e) {
      print('Erreur inattendue lors de la connexion Firebase Auth: $e');
      throw AuthException('Une erreur inattendue est survenue lors de la connexion.');
    }
  }

  // Modified method to sign up using Firebase Auth
  Future<Map<String, dynamic>?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
     try {
       print('Tentative d\'inscription via Firebase Auth...');

       final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
         email: email,
         password: password,
       );

       final user = userCredential.user;

       if (user != null) {
         // Create a new user document in Firestore after successful Firebase Auth registration
         final newUserDocRef = _firestore.collection('users').doc(user.uid); // Use Firebase Auth UID as doc ID

         final userData = {
           'role': 'user', // Default role for new registrations
           'email': user.email,
           // Do NOT store password here. Firebase Auth manages it securely.
           'createdAt': FieldValue.serverTimestamp(),
           'lastLogin': FieldValue.serverTimestamp(), // Update on registration
           'isActive': true,
         };

         await newUserDocRef.set(userData);

         print('Inscription réussie dans Firebase Auth et Firestore pour: ${user.email}');
         return userData;
       }
       return null;

     } on FirebaseAuthException catch (e) {
       print('Erreur d\'inscription Firebase Auth: ${e.code} - ${e.message}');
       // Translate specific Firebase Auth errors
       String errorMessage;
       if (e.code == 'email-already-in-use') {
         errorMessage = 'Cette adresse email est déjà utilisée.';
       } else if (e.code == 'invalid-email') {
          errorMessage = 'Format d\'email invalide.';
       } else if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe est trop faible.';
       } else {
         errorMessage = 'Erreur d\'inscription: ${e.message}';
       }
       throw AuthException(errorMessage); // Throw our custom exception
     } catch (e) {
       print('Erreur inattendue lors de l\'inscription Firebase Auth: $e');
       throw AuthException('Une erreur inattendue est survenue lors de l\'inscription.');
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
  
  // Method to get user data from Firestore based on UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
       // Get by UID (this will work for both email/password and Google users now)
       DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

       if (!doc.exists) {
           print('Document utilisateur non trouvé par UID: $uid');
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
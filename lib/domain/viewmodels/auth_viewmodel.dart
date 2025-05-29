import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:coffee_shop/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/core/constants/app_routes.dart';

class AuthViewModel with ChangeNotifier {
  AuthRepository? _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _userRole;
  Map<String, dynamic>? _userData;

  String? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;
  bool get isAdmin => _userRole == 'admin';
  bool get isUser => _userRole == 'user';

  void setRepository(AuthRepository repository) {
    _authRepository = repository;
    _authRepository?.authStateChanges.listen((user) async {
      print('Auth state changed (Firebase Auth): ${user?.email}');
      if (user != null) {
        _currentUser = user;
        await fetchUserRole();
      } else {
        _currentUser = null;
        _userRole = null;
        _userData = null;
      }
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _userData != null;
  bool get isEmailVerified => false;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _userData = null;
    try {
      print('Tentative de connexion avec email (via ViewModel): $email');
      
      if (_authRepository == null) {
        throw AuthException('Le service d\'authentification n\'est pas initialisé');
      }

      final userDataFromFirestore = await _authRepository!.signInWithFirestore(
        email: email.trim(),
        password: password,
      );
      
      if (userDataFromFirestore != null) {
        print('Connexion réussie (via ViewModel) pour: $email');
        _userData = userDataFromFirestore;
        _userRole = userDataFromFirestore['role'] ?? 'user';
        print('ViewModel - isAuthenticated: $isAuthenticated, userRole: $_userRole');
      } else {
        throw AuthException('Échec de la connexion');
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur de connexion (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de la connexion';
      print('Erreur inattendue (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository?.signUpWithEmailAndPassword(email: email, password: password);
    } on UnimplementedError {
      _errorMessage = 'L\'inscription par email/mot de passe n\'est pas encore implémentée';
      print(_errorMessage);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur d\'inscription (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de l\'inscription';
      print('Erreur inattendue (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository?.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        await fetchUserRole();
        print('ViewModel Google - isAuthenticated: $isAuthenticated, userRole: $_userRole');
      } else {
        _errorMessage = 'Connexion Google annulée';
        print(_errorMessage);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur de connexion Google (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de la connexion Google';
      print('Erreur inattendue (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository?.signOut();
      _currentUser = null;
      _userRole = null;
      _userData = null;
      print('Déconnexion réussie (via ViewModel)');
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur lors de la déconnexion (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de la déconnexion';
      print('Erreur inattendue lors de la déconnexion (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository?.resetPassword(email);
    } on UnimplementedError {
      _errorMessage = 'La réinitialisation du mot de passe n\'est pas encore implémentée';
      print(_errorMessage);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur de réinitialisation (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de la réinitialisation';
      print('Erreur inattendue (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository?.sendEmailVerification();
    } on UnimplementedError {
      _errorMessage = 'La vérification d\'email n\'est pas encore implémentée';
      print(_errorMessage);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur d\'envoi de vérification (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue lors de l\'envoi de vérification';
      print('Erreur inattendue (via ViewModel): $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchUserRole() async {
    final user = _currentUser;
    if (user != null) {
      try {
        final userData = await _authRepository?.getUserData(user.uid);
            
        if (userData != null) {
          _userData = userData;
          _userRole = userData['role'] ?? 'user';
          print('Rôle utilisateur chargé depuis Firestore: $_userRole');
        } else {
          print('Aucun document utilisateur trouvé dans Firestore pour UID: ${user.uid}');
          _userRole = 'user';
          _userData = {'email': user.email, 'role': _userRole};
        }
      } catch (e) {
        print('Erreur lors de la récupération du rôle/données depuis Firestore: $e');
        _userRole = 'user';
        _userData = null;
      }
    } else if (_userData != null) {
      print('Utilisateur authentifié via Firestore, rôle: $_userRole');
    } else {
      _userRole = null;
      _userData = null;
      print('Aucun utilisateur authentifié.');
    }
    notifyListeners();
  }

  String getInitialRoute() {
    if (_userData != null) {
      print('getInitialRoute: authenticated, userRole: $_userRole, navigating to: ${_userRole == 'admin' ? AppRoutes.adminDashboard : AppRoutes.userHome}');
      return _userRole == 'admin' ? AppRoutes.adminDashboard : AppRoutes.userHome;
    } else {
      print('getInitialRoute: not authenticated, navigating to: ${AppRoutes.welcome}');
      return AppRoutes.welcome;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  String? getUserUid() {
    return _currentUser?.uid;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
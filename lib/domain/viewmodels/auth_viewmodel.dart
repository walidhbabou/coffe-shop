import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:coffee_shop/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:coffee_shop/main.dart'; // Pour accéder à navigatorKey

class AuthViewModel extends ChangeNotifier {
  AuthRepository? _authRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _userRole;
  Map<String, dynamic>? _userData;
  final AuthService _authService = AuthService();

  String? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;
  bool get isAdmin => _userRole == 'admin';
  bool get isUser => _userRole == 'user';

  AuthViewModel() {
    // Initialize current user
    _currentUser = _authService.currentUser;

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
      debugPrint('Auth state changed: ${user?.email ?? 'null'}');
    });
  }

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
  String? get userId => _currentUser?.uid ?? _userData?['uid'];
  bool get isLoggedIn => _currentUser != null;

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential != null) {
        _currentUser = userCredential.user;
        await fetchUserRole();
        notifyListeners();

        // Redirection basée sur l'email
        if (_currentUser?.email == 'admin@coffeeapp.com') {
          return true; // Redirigera vers AdminWelcomePage
        } else {
          return true; // Redirigera vers UserHomePage
        }
      }
      _setError('Failed to sign in');
      return false;
    } catch (e) {
      _setError('Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential =
          await _authService.registerWithEmailAndPassword(email, password);
      if (userCredential != null) {
        _currentUser = userCredential.user;
        notifyListeners();
        return true;
      }
      _setError('Failed to register');
      return false;
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _userRole = null;
      _userData = null;
      notifyListeners();

      // Forcer la redirection vers la page de login
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      _setError('Sign out error: $e');
    } finally {
      _setLoading(false);
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
        print(
            'ViewModel Google - isAuthenticated: $isAuthenticated, userRole: $_userRole');
      } else {
        _errorMessage = 'Connexion Google annulée';
        print(_errorMessage);
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur de connexion Google (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage =
          'Une erreur inattendue est survenue lors de la connexion Google';
      print('Erreur inattendue (via ViewModel): $e');
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
      _errorMessage =
          'La réinitialisation du mot de passe n\'est pas encore implémentée';
      print(_errorMessage);
    } on AuthException catch (e) {
      _errorMessage = e.message;
      print('Erreur de réinitialisation (via ViewModel): ${e.message}');
    } catch (e) {
      _errorMessage =
          'Une erreur inattendue est survenue lors de la réinitialisation';
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
      _errorMessage =
          'Une erreur inattendue est survenue lors de l\'envoi de vérification';
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
          print(
              'Aucun document utilisateur trouvé dans Firestore pour UID: ${user.uid}');
          _userRole = 'user';
          _userData = {'email': user.email, 'role': _userRole};
        }
      } catch (e) {
        print(
            'Erreur lors de la récupération du rôle/données depuis Firestore: $e');
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
      print('getInitialRoute: authenticated, email: ${_currentUser?.email}');
      if (_currentUser?.email == 'admin@coffeeapp.com') {
        print(
            'getInitialRoute: admin user detected, navigating to admin welcome page');
        return AppRoutes.adminWelcome;
      } else {
        print(
            'getInitialRoute: regular user detected, navigating to user home');
        return AppRoutes.userHome;
      }
    } else {
      print('getInitialRoute: not authenticated, navigating to welcome page');
      return AppRoutes.welcome;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? getUserUid() {
    return _currentUser?.uid;
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential =
          await _authService.registerWithEmailAndPassword(email, password);
      if (userCredential != null) {
        _currentUser = userCredential.user;
        notifyListeners();
        return true;
      }
      _setError('Failed to register');
      return false;
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

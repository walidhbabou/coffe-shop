import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:coffee_shop/main.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _userRole;
  Map<String, dynamic>? _userData;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;
  bool get isAdmin => _userRole == 'admin';
  bool get isUser => _userRole == 'user';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _userData != null;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;
  String? get userId => _currentUser?.uid ?? _userData?['uid'];
  bool get isLoggedIn => _currentUser != null;

  AuthViewModel() {
    _currentUser = _authService.currentUser;
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        fetchUserRole();
      } else {
        _userRole = null;
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> fetchUserRole() async {
    if (_currentUser == null) return;

    try {
      final userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _userData = userDoc.data();
        _userRole = _userData?['role'] ?? 'user';
      } else {
        _userRole = 'user';
        _userData = {
          'uid': _currentUser!.uid,
          'email': _currentUser!.email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set(_userData!);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user role: $e');
      _setError('Error fetching user data');
    }
  }

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
        return true;
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

        // Create user document in Firestore
        _userData = {
          'uid': _currentUser!.uid,
          'email': email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .set(_userData!);
        _userRole = 'user';

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

  Future<void> signOut(BuildContext context) async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _userRole = null;
      _userData = null;
      notifyListeners();

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
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
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _currentUser = userCredential.user;
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
      await _authService.resetPassword(email);
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
      await _authService.sendEmailVerification();
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

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

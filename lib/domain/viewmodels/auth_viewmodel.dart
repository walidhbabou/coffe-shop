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
  String? get userRole => _userRole;

  void setRepository(AuthRepository repository) {
    _authRepository = repository;
    _authRepository?.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        fetchUserRole();
      }
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authRepository?.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authRepository?.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authRepository?.signInWithGoogle();
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authRepository?.signOut();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authRepository?.resetPassword(email);
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    _setLoading(true);
    try {
      await _authRepository?.sendEmailVerification();
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserRole() async {
    final user = _currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _userRole = doc.data()?['role'] ?? 'user';
      notifyListeners();
    }
  }

  String getInitialRoute() {
    if (_currentUser == null) {
      return AppRoutes.welcome;
    } else {
      return _userRole == 'admin' ? AppRoutes.adminDashboard : AppRoutes.userHome;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
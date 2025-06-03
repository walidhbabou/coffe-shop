import 'package:flutter/foundation.dart';
import '../../data/services/user_data_service.dart';

class AdminUsersViewModel with ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AdminUsersViewModel() {
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await UserDataService.fetchAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Public method to fetch users
  Future<void> fetchUsers() async {
    await _fetchUsers();
  }

  // Méthode pour supprimer un utilisateur par son UID
  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await UserDataService.deleteUser(userId);
      // Remove the user from the local list after successful deletion
      _users.removeWhere((user) => user['uid'] == userId);
      print('User with UID $userId deleted from ViewModel list.');
    } catch (e) {
      _errorMessage = e.toString();
      print(_errorMessage);
      // Ne pas rafraîchir la liste en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

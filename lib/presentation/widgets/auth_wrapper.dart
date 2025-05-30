// Placeholder for AuthWrapper widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/viewmodels/auth_viewmodel.dart';
import '../pages/user/user_home_page.dart'; // Assuming user home page
import '../pages/auth/login_page.dart'; // Assuming login page
import '../pages/admin/admin_dashboard.dart'; // Import admin dashboard

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authViewModel.isLoggedIn) {
      // Navigate to user home or admin dashboard based on role
      // This is a basic example, you might need more sophisticated logic
      if (authViewModel.isAdmin) {
        return const AdminDashboard(); // Navigate to admin dashboard if user is admin
      } else {
        return const UserHomePage(); // Navigate to user home for regular users
      }
    } else {
      return const LoginPage();
    }
  }
} 
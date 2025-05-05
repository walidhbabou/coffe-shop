import 'package:flutter/material.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth/auth_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
} 
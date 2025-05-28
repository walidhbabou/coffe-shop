import 'package:flutter/material.dart';
import '../../presentation/pages/welcome/welcome_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/signup_page.dart';
import '../../presentation/pages/profile/profile_home_page.dart';
import '../../presentation/pages/scan/scan_pay_page.dart';
import '../../presentation/pages/order/order_page.dart';
import '../../presentation/pages/profile/account_page.dart';
import '../../../data/models/payment_info.dart';
import '../../presentation/pages/admin/admin_dashboard.dart';
import '../../presentation/pages/user/user_home_page.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String scanPay = '/scan_pay';
  static const String order = '/order';
  static const String account = '/account';
  static const String adminDashboard = '/admin_dashboard';
  static const String userHome = '/user_home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileHomePage());
      case scanPay:
        return MaterialPageRoute(
            builder: (_) => const ScanPayPage(
                  paymentInfo: PaymentInfo(
                    transactionId: 'DEMO',
                    total: 0.0,
                    date: '2024-01-01',
                    time: '00:00',
                  ),
                ));
      case order:
        return MaterialPageRoute(builder: (_) => const OrderPage());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHomePage());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}

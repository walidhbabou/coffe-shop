import 'package:flutter/material.dart';
import '../../presentation/pages/welcome/welcome_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/signup_page.dart';
import '../../presentation/pages/user/user_home_page.dart';
import '../../presentation/pages/scan/scan_pay_page.dart';
import '../../presentation/pages/order/order_page.dart';
import '../../presentation/pages/profile/account_page.dart';
import '../../../data/models/payment_info.dart';
import '../../presentation/pages/admin/admin_welcome_page.dart';
import '../../presentation/pages/admin/invoice_history_page.dart';
import 'package:provider/provider.dart';
import '../../domain/viewmodels/auth_viewmodel.dart';
import '../../presentation/pages/admin/admin_dashboard.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profile = '/profile';
  static const String scanPay = '/scan_pay';
  static const String order = '/order';
  static const String account = '/account';
  static const String userHome = '/user_home';
  static const String invoiceHistory = '/invoice_history';
  static const String adminDashboard = '/admin_dashboard';
  static const String adminWelcome = '/admin_welcome';

  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      signup: (context) => const SignupPage(),
      userHome: (context) => const UserHomePage(),
      account: (context) => const AccountPage(),
      adminDashboard: (context) => const AdminDashboard(),
      adminWelcome: (context) => const AdminWelcomePage(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case adminWelcome:
        return MaterialPageRoute(builder: (_) => const AdminWelcomePage());

      case profile:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = context.read<AuthViewModel>();

            print('AppRoutes: Checking authentication for profile route.');
            print(
                'AppRoutes: isAuthenticated: ${authViewModel.isAuthenticated}');
            print('AppRoutes: userRole: ${authViewModel.userRole}');

            if (!authViewModel.isAuthenticated) {
              print('AppRoutes: User not authenticated, redirecting to login.');
              return const LoginPage();
            }

            if (authViewModel.isAdmin) {
              print('AppRoutes: User is admin, navigating to admin dashboard.');
              return const AdminDashboard();
            } else {
              print('AppRoutes: User is not admin, navigating to user home.');
              return const UserHomePage();
            }
          },
        );

      case scanPay:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = context.read<AuthViewModel>();

            if (!authViewModel.isAuthenticated) {
              return const LoginPage();
            }

            // Get payment info from route arguments
            final paymentInfo = settings.arguments as PaymentInfo?;

            return ScanPayPage(
              paymentInfo: paymentInfo ??
                  PaymentInfo(
                    transactionId: 'DEMO',
                    total: 0.0,
                    date: '2024-01-01',
                    time: '00:00',
                    userId: authViewModel.currentUser?.uid ?? '',
                    invoiceId: 'DEMO',
                    items: [],
                  ),
            );
          },
        );

      case order:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = context.read<AuthViewModel>();

            if (!authViewModel.isAuthenticated) {
              return const LoginPage();
            }

            return const OrderPage();
          },
        );

      case invoiceHistory:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = context.read<AuthViewModel>();

            if (!authViewModel.isAuthenticated) {
              return const LoginPage();
            }

            return const InvoiceHistoryPage();
          },
        );

      case userHome:
        print('AppRoutes: Navigating to UserHomePage.');
        return MaterialPageRoute(builder: (_) => const UserHomePage());

      default:
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        );
    }
  }
}

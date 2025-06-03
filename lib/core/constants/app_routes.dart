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
import '../../presentation/pages/order/cart_page.dart';
import '../../presentation/pages/profile/addresses_page.dart';
import '../../presentation/pages/profile/notifications_page.dart';
import '../../presentation/pages/profile/payment_methods_page.dart';
import '../../presentation/pages/profile/personal_info_page.dart';
import '../../presentation/pages/profile/about_page.dart';

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
  static const String cart = '/cart';
  static const String personalInfo = '/personal_info';
  static const String paymentMethods = '/payment_methods';
  static const String addresses = '/addresses';
  static const String notifications = '/notifications';
  static const String about = '/about';

  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      login: (context) => const LoginPage(),
      signup: (context) => const SignupPage(),
      userHome: (context) => const UserHomePage(),
      account: (context) => const AccountPage(),
      adminDashboard: (context) => const AdminDashboard(),
      adminWelcome: (context) => const AdminWelcomePage(),
      cart: (context) => const CartPage(),
      invoiceHistory: (context) => const InvoiceHistoryPage(),
      order: (context) => const OrderPage(),
      personalInfo: (context) => const PersonalInfoPage(),
      paymentMethods: (context) => const PaymentMethodsPage(),
      addresses: (context) => const AddressesPage(),
      notifications: (context) => const NotificationsPage(),
      about: (context) => const AboutPage(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case scanPay:
        return MaterialPageRoute(
          builder: (context) {
            final authViewModel = context.read<AuthViewModel>();
            if (!authViewModel.isAuthenticated) {
              return const LoginPage();
            }
            final paymentInfo = settings.arguments as PaymentInfo?;
            return ScanPayPage(paymentInfo: paymentInfo);
          },
        );

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

      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}

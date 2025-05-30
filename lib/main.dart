import 'package:coffee_shop/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/data/repositories/auth_repository.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'package:coffee_shop/domain/viewmodels/order_viewmodel.dart';
import 'package:coffee_shop/domain/viewmodels/invoice_viewmodel.dart';
import 'firebase_options.dart';
import 'package:coffee_shop/data/services/init_service.dart';
import 'package:coffee_shop/presentation/widgets/auth_wrapper.dart';
import 'package:coffee_shop/presentation/pages/admin/admin_routes.dart';
import 'package:coffee_shop/presentation/pages/welcome/welcome_page.dart';

// Clé de navigation globale
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Attendre que Firebase soit complètement initialisé
    await Future.delayed(const Duration(seconds: 1));

    // Créer le compte admin si nécessaire
    await createAdminIfNotExists();

    // Initialize AuthViewModel with repository
    final authRepository = AuthRepository();
    final authViewModel = AuthViewModel();
    authViewModel.setRepository(authRepository);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>(create: (_) => authViewModel),
          ChangeNotifierProvider<OrderViewModel>(
            create: (_) => OrderViewModel(),
          ),
          ChangeNotifierProvider<InvoiceViewModel>(
            create: (context) => InvoiceViewModel(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
    // Afficher une page d'erreur ou un message à l'utilisateur
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de connexion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Impossible de se connecter au serveur.\nVeuillez réessayer plus tard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Redémarrer l'application
                    main();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Coffee Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      routes: {
        ...AppRoutes.generateRoutes(),
        ...AdminRoutes.getRoutes(),
      },
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/data/repositories/auth_repository.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'package:coffee_shop/presentation/pages/splash_page.dart';
import 'package:coffee_shop/presentation/pages/auth/login_page.dart';
import 'package:coffee_shop/presentation/pages/auth/register_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) {
            final viewModel = AuthViewModel();
            viewModel.setRepository(context.read<AuthRepository>());
            return viewModel;
          },
          update: (context, authRepo, authVM) {
            authVM?.setRepository(authRepo);
            return authVM!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Coffee Shop',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          scaffoldBackgroundColor: const Color(0xFFF5E3C0),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/auth': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenue dans Coffee Shop!'),
      ),
    );
  }
}


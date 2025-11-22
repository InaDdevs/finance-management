import 'package:flutter/material.dart';
import 'package:projeto01/shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'core/dart/providers/auth_provider.dart';
import 'core/dart/providers/transaction_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/transactions/transaction_form_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // Configuração das Rotas
      routes: {
        '/register': (context) => const RegisterScreen(),

        '/new-transaction': (context) => const TransactionFormScreen(),

        '/dashboard': (context) => const MainNavigationWrapper(),
      },

      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isAuthenticated) {

            return const MainNavigationWrapper();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
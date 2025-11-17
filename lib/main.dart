// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações corrigidas para sua estrutura
import 'core/dart/providers/transaction_provider.dart'; // Caminho ajustado
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/transactions/transaction_form_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Erro 'TransactionProvider' isn't defined (agora corrigido)
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Gestor Financeiro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const MainNavigationWrapper(),
          '/new-transaction': (context) => const TransactionFormScreen(),
        },
      ),
    );
  }
}
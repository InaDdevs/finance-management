// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ... controladores ...

  void _login() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... campos de email e senha ...
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () { /* ... */ },
              child: const Text('Esqueci a Senha'),
            ),
            TextButton(
              onPressed: () {
                // Navega para a tela de cadastro
                Navigator.of(context).pushNamed('/register'); //
              },
              child: const Text('Criar Conta / Cadastre-se'), //
            ),
          ],
        ),
      ),
    );
  }
}
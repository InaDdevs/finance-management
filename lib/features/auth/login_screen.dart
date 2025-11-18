// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Adicionando os controladores que faltavam no seu snippet
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // Lógica de login (autenticação)
    // ...
    // Após o sucesso, navega para o dashboard
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  void dispose() {
    // É importante fazer o dispose dos controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          // 2. Faz os filhos (como ElevatedButton) esticarem na horizontal
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // Adicionando os campos de texto que faltavam
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // Este botão será esticado para preencher a largura
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),

            // 3. Centraliza os botões de texto horizontalmente
            Center(
              child: TextButton(
                onPressed: () { /* ... */ },
                child: const Text('Esqueci a Senha'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text('Criar Conta / Cadastre-se'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil e Configurações')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Nome do Usuário',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text('admin@email.com'),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Configurações da Conta'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.blue),
              title: const Text('Gerenciar Categorias'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text('Gerenciar Contas'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Navega de volta para o login e remove todas as telas
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
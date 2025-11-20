import 'package:flutter/material.dart';
import '../reports/reports_screen.dart';

import 'account_settings_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_accounts_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color minhaCorDaBarra = Color(0xFFC0DAE5);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil e Configurações')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: minhaCorDaBarra.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 50,
                color: minhaCorDaBarra.withOpacity(0.9),
              ),
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
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Configurações da Conta'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Colors.blue),
              title: const Text('Gerenciar Categorias'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text('Gerenciar Contas'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageAccountsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
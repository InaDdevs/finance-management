// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../reports/reports_screen.dart'; // Importação da tela de Relatórios

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defina a cor aqui para reutilizar
    final Color minhaCorDaBarra = Color(0xFFC0DAE5);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil e Configurações')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- MUDANÇA NO AVATAR ---
            CircleAvatar(
              radius: 50,
              // Define um fundo mais claro
              backgroundColor: minhaCorDaBarra.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 50,
                color: minhaCorDaBarra.withOpacity(0.9), // Cor no ícone
              ),
            ),
            // --- FIM DA MUDANÇA ---
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

            // --- Bloco de Relatórios ---
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue), // <-- COR AQUI
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                );
              },
            ),

            // --- Bloco de Configurações ---
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue), // <-- COR AQUI
              title: const Text('Configurações da Conta'),
              onTap: () {},
            ),

            // --- Bloco de Gerenciar Categorias ---
            ListTile(
              leading: const Icon(Icons.category, color: Colors.blue ), // <-- COR AQUI
              title: const Text('Gerenciar Categorias'),
              onTap: () {},
            ),

            // --- Bloco de Gerenciar Contas ---
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue), // <-- COR AQUI
              title: const Text('Gerenciar Contas'),
              onTap: () {},
            ),

            // --- Bloco de Sair ---
            // (Recomendo manter este em vermelho, pois é uma ação de "Sair")
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
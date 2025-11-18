// lib/features/profile/manage_accounts_screen.dart
import 'package:flutter/material.dart';

class ManageAccountsScreen extends StatelessWidget {
  const ManageAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Contas')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aqui você poderá adicionar ou editar suas contas (ex: Conta Corrente, Poupança, Dinheiro).'),
        ),
      ),
    );
  }
}
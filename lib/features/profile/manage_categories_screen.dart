import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Categorias')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aqui você poderá adicionar, editar ou excluir suas categorias de receita e despesa.'),
        ),
      ),
    );
  }
}
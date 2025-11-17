// lib/shared/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- ADICIONADO

// Importações relativas corrigidas
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/transactions/accounts_payable_screen.dart';
import '../../features/transactions/accounts_receivable_screen.dart';
import '../../core/dart/providers/transaction_provider.dart'; // <--- ADICIONADO

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const AccountsPayableScreen(),
    const AccountsReceivableScreen(),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      _openNewTransactionForm();
      return;
    }

    int pageIndex = index > 2 ? index - 1 : index;

    setState(() {
      _currentIndex = pageIndex;
    });
  }

  void _openNewTransactionForm() {
    Navigator.of(context).pushNamed('/new-transaction').then((_) {
      // Quando o formulário fechar, atualiza os dados
      // Erros 'Provider' e 'TransactionProvider' corrigidos aqui
      Provider.of<TransactionProvider>(context, listen: false)._refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usar IndexedStack preserva o estado de rolagem de cada tela
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openNewTransactionForm,
        elevation: 2.0,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
            _buildNavItem(icon: Icons.arrow_upward, label: 'A Pagar', index: 1),
            const SizedBox(width: 48), // Espaço para o FAB
            _buildNavItem(icon: Icons.arrow_downward, label: 'A Receber', index: 3),
            _buildNavItem(icon: Icons.person, label: 'Perfil', index: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    int pageIndex = index > 2 ? index - 1 : index;
    final isSelected = (pageIndex == _currentIndex);

    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.black
      ),
      tooltip: label,
      onPressed: () => _onTap(index),
    );
  }
}

extension on TransactionProvider {
  void _refreshData() {}
}
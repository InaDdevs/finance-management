import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports das Telas
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/transactions/accounts_payable_screen.dart';
import '../../features/transactions/accounts_receivable_screen.dart';

// Import do Provider
import '../../core/dart/providers/transaction_provider.dart';

class MainNavigationWrapper extends StatefulWidget {
const MainNavigationWrapper({super.key});

@override
State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
int _currentIndex = 0;

// Lista das páginas reais (Índices: 0, 1, 2, 3)
final List<Widget> _pages = [
const DashboardScreen(),          // 0
const AccountsPayableScreen(),    // 1
const AccountsReceivableScreen(), // 2
const ProfileScreen(),            // 3
];

void _onTap(int navBarIndex) {

if (navBarIndex == 2) {
_openNewTransactionForm();
return;
}
int pageIndex = navBarIndex > 2 ? navBarIndex - 1 : navBarIndex;

setState(() {
_currentIndex = pageIndex;
});
}

void _openNewTransactionForm() {
Navigator.of(context).pushNamed('/new-transaction').then((_) {
Provider.of<TransactionProvider>(context, listen: false).fetchDashboardData();
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: IndexedStack(
index: _currentIndex,
children: _pages,
),

floatingActionButton: FloatingActionButton(
onPressed: _openNewTransactionForm,
elevation: 4.0,
backgroundColor: const Color(0xFF273238),
foregroundColor: Colors.white,
shape: const CircleBorder(), // Garante que fique redondo
child: const Icon(Icons.add),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

bottomNavigationBar: BottomAppBar(
color: const Color(0xFF273238),
shape: const CircularNotchedRectangle(), // Faz o corte para o botão
notchMargin: 8.0, // Espaço entre o corte e o botão
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 8.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
// Lado Esquerdo
_buildNavItem(icon: Icons.dashboard, label: 'Home', index: 0),
_buildNavItem(icon: Icons.arrow_upward, label: 'Pagar', index: 1),

// Espaço invisível para o botão central
const SizedBox(width: 48),

// Lado Direito
_buildNavItem(icon: Icons.arrow_downward, label: 'Receber', index: 3),
_buildNavItem(icon: Icons.person, label: 'Perfil', index: 4),
],
),
),
),
);
}

Widget _buildNavItem({required IconData icon, required String label, required int index}) {
int pageIndex = index > 2 ? index - 1 : index;
final isSelected = (pageIndex == _currentIndex);

return IconButton(
icon: Icon(
icon,
color: isSelected ? Colors.lightBlueAccent : Colors.white70,
size: 28,
),
tooltip: label,
onPressed: () => _onTap(index),
);
}
}

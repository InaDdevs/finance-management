// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Importação corrigida
import '../../core/dart/providers/transaction_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Erro 'TransactionProvider' isn't a type (agora corrigido)
      Provider.of<TransactionProvider>(context, listen: false).fetchDashboardData();
    });
  }

  Future<void> _refreshDashboard() async {
    await Provider.of<TransactionProvider>(context, listen: false).fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final balance = provider.currentBalance;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          // ... (conteúdo do dashboard) ...
        ),
      ),
    );
  }
// ... (Restante do código do DashboardScreen) ...
}
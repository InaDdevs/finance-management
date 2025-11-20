import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final income = provider.monthlyIncome;
    final expense = provider.monthlyExpense;
    final upcoming = provider.upcomingTransactions;
    final categoryData = provider.categorySummary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(balance),

              const SizedBox(height: 24),

              _buildQuickActions(context),

              const SizedBox(height: 24),

              const Text('Resumo do Mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Receitas', income, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Despesas', expense, Colors.red)),
                ],
              ),

              const SizedBox(height: 24),

              const Text('Gastos por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildChartSection(categoryData),

              const SizedBox(height: 24),

              const Text('Próximos Vencimentos (7 dias)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildUpcomingList(upcoming),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
            },
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
            label: const Text('Receita', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
            },
            icon: const Icon(Icons.arrow_downward, color: Colors.white),
            label: const Text('Despesa', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(title == 'Receitas' ? Icons.trending_up : Icons.trending_down, color: color, size: 20),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, double> data) {
    if (data.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text("Sem despesas neste mês", style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }

    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink
    ];

    int colorIndex = 0;
    final sections = data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      final total = data.values.reduce((a, b) => a + b);
      final percentage = (entry.value / total * 100).toStringAsFixed(0);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '$percentage%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final key = data.keys.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text("Nenhuma conta próxima do vencimento.")),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];

        final date = t.dueDate;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.calendar_today, color: Colors.red, size: 20),
            ),
            title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Vence em: ${dateFormat.format(date)}"),
            trailing: Text(
              currencyFormat.format(t.value),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}
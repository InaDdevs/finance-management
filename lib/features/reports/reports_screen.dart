import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportData();
    });
  }

  Future<void> _loadReportData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final inclusiveEndDate = _endDate.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    await provider.fetchStatement(_startDate, inclusiveEndDate);
    await provider.fetchCategorySummary(_startDate, inclusiveEndDate);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newRange != null) {
      setState(() {
        _startDate = newRange.start;
        _endDate = newRange.end;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final formattedStartDate = DateFormat('dd/MM/yy').format(_startDate);
    final formattedEndDate = DateFormat('dd/MM/yy').format(_endDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Selecionar Período',
            onPressed: _selectDateRange,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Column(
            children: [
              Text(
                'Período: $formattedStartDate - $formattedEndDate',
                style: const TextStyle(fontSize: 12),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt), text: 'Extrato'),
                  Tab(icon: Icon(Icons.pie_chart), text: 'Categorias'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStatementTab(provider.statementTransactions),
          _buildCategoryTab(provider.categorySummary),
        ],
      ),
    );
  }

  Widget _buildStatementTab(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Nenhuma transação no período.'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildStatementItem(
          title: transaction.description,
          date: DateFormat('dd/MM/yyyy').format(transaction.dueDate),
          value: transaction.value,
          type: transaction.type,
        );
      },
    );
  }

  Widget _buildCategoryTab(Map<String, double> categorySummary) {
    if (categorySummary.isEmpty) {
      return const Center(child: Text('Nenhuma despesa no período.'));
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: categorySummary.entries.map((entry) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.category),
            title: Text(entry.key),
            trailing: Text(
              currencyFormat.format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatementItem({
    required String title,
    required String date,
    required double value,
    required TransactionType type,
  }) {
    final color = type == TransactionType.receita ? Colors.green : Colors.red;
    final sign = type == TransactionType.receita ? '+' : '-';

    return ListTile(
      leading: Icon(
        type == TransactionType.receita ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        '$sign ${currencyFormat.format(value)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
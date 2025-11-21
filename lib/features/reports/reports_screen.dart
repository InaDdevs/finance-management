import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _secondaryColor = Color(0xFF4DD0E1);
const Color _accentColor = Color(0xFF273238);
const Color _backgroundColor = Color(0xFFFFFFFF);

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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,

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
          child: Container(
            color: _backgroundColor,
            child: Column(
              children: [
                Text(
                  'Período: $formattedStartDate - $formattedEndDate',
                  style: TextStyle(fontSize: 14, color: _accentColor.withOpacity(0.8)),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: _accentColor,
                  unselectedLabelColor: _accentColor.withOpacity(0.5),
                  indicatorColor: _secondaryColor,
                  tabs: const [
                    Tab(icon: Icon(Icons.list_alt), text: 'Extrato'),
                    Tab(icon: Icon(Icons.pie_chart), text: 'Categorias'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
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
      return const Center(child: Text('Nenhuma transação no período.', style: TextStyle(color: _accentColor)));
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
      return const Center(child: Text('Nenhuma despesa no período.', style: TextStyle(color: _accentColor)));
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: categorySummary.entries.map((entry) {
        return Card(
          color: _backgroundColor,
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.category, color: _primaryColor),
            title: Text(entry.key, style: const TextStyle(color: _accentColor)),
            trailing: Text(
              currencyFormat.format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _accentColor),
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
      title: Text(title, style: const TextStyle(color: _accentColor)),
      subtitle: Text(date, style: TextStyle(color: _accentColor.withOpacity(0.7))),
      trailing: Text(
        '$sign ${currencyFormat.format(value)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
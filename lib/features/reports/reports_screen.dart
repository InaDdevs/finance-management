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

  // --- MUDANÇA: Define as datas como estado da tela ---
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  // --- FIM DA MUDANÇA ---

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportData();
    });
  }

  // Carrega os dados com base nas datas do estado
  Future<void> _loadReportData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Mostra o loading
    // (O provider.isLoading já fará isso automaticamente)

    // Ajusta o _endDate para o fim do dia para incluir tudo
    final inclusiveEndDate = _endDate.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    await provider.fetchStatement(_startDate, inclusiveEndDate);
    await provider.fetchCategorySummary(_startDate, inclusiveEndDate);
  }

  // --- MUDANÇA: Novo método para selecionar o período ---
  Future<void> _selectDateRange() async {
    final DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2000), // Primeiro ano selecionável
      lastDate: DateTime(2101),  // Último ano selecionável
    );

    // Se o usuário selecionar um período (e não cancelar)
    if (newRange != null) {
      setState(() {
        _startDate = newRange.start;
        _endDate = newRange.end;
      });
      // Recarrega os dados com o novo período
      _loadReportData();
    }
  }
  // --- FIM DA MUDANÇA ---

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    // Formata as datas para exibição
    final formattedStartDate = DateFormat('dd/MM/yy').format(_startDate);
    final formattedEndDate = DateFormat('dd/MM/yy').format(_endDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Selecionar Período',
            // --- MUDANÇA: Chama o seletor de data ---
            onPressed: _selectDateRange,
            // --- FIM DA MUDANÇA ---
          ),
        ],
        bottom: PreferredSize(
          // Aumenta o tamanho do 'bottom' para caber o texto e as abas
          preferredSize: const Size.fromHeight(80.0),
          child: Column(
            children: [
              // --- MUDANÇA: Mostra o período selecionado ---
              Text(
                'Período: $formattedStartDate - $formattedEndDate',
                style: const TextStyle(fontSize: 12),
              ),
              // --- FIM DA MUDANÇA ---
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

  // Widget da Aba 1 (Extrato)
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

  // Widget da Aba 2 (Categorias)
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

  // Widget auxiliar para o item do extrato
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
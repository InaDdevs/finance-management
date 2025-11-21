import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _accentColor = Color(0xFF90A4AE);

class AccountsPayableScreen extends StatefulWidget {
  const AccountsPayableScreen({super.key});

  @override
  State<AccountsPayableScreen> createState() => _AccountsPayableScreenState();
}

class _AccountsPayableScreenState extends State<AccountsPayableScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  String _filterStatus = 'Pendente';
  String _filterPeriod = 'Mês Atual';

  @override
  void initState() {
    super.initState();

    if (_filterPeriod.contains('/')) {
      _filterPeriod = 'Mês Atual';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (_filterPeriod == 'Mês Atual') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0).copyWith(hour: 23, minute: 59, second: 59);

    } else if (_filterPeriod == 'Próximos 30 dias') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate.add(const Duration(days: 30)).copyWith(hour: 23, minute: 59, second: 59);

    } else if (_filterPeriod.contains(' - ')) {
      try {
        final parts = _filterPeriod.split(' - ');
        final startDateString = parts[0];
        final endDateString = parts[1];

        startDate = DateFormat('dd/MM/yy').parse(startDateString);

        endDate = DateFormat('dd/MM/yy').parse(endDateString).copyWith(hour: 23, minute: 59, second: 59);

      } catch (_) {
      }
    } else if (_filterPeriod.contains('/')) {
      try {
        final date = DateFormat('dd/MM/yy').parse(_filterPeriod);
        startDate = DateTime(date.year, date.month, date.day);
        endDate = startDate.copyWith(hour: 23, minute: 59, second: 59);
      } catch (_) {
      }
    }

    await Provider.of<TransactionProvider>(context, listen: false)
        .fetchAccountsPayable(
      status: _filterStatus.toLowerCase(),
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _markAsPaid(TransactionModel transaction) {
    transaction.status = TransactionStatus.pago;
    transaction.paymentDate = DateTime.now();

    Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(transaction);

    if (_filterStatus == 'Pendente' || _filterStatus == 'Pago' || _filterStatus == 'Todos') {
      _loadTransactions();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação marcada como paga!'), backgroundColor: Colors.green),
    );
  }

  void _deleteTransaction(int id) {
    Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(id);

    _loadTransactions();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação excluída!'), backgroundColor: Colors.red),
    );
  }

  void _showTransactionActions(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ações para ${transaction.description}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _primaryColor),
                ),
              ),
              const Divider(height: 1),
              if(transaction.status == TransactionStatus.pendente)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Marcar como Pago'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _markAsPaid(transaction);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit, color: _primaryColor),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed('/new-transaction', arguments: transaction.id)
                      .then((_) => _loadTransactions());
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _deleteTransaction(transaction.id!);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.accountsPayable;
    final totalPendente = transactions.fold(0.0, (sum, item) => sum + item.value);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contas a Pagar', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          _buildPeriodFilter(),
          const SizedBox(width: 8),
        ],
        bottom: _buildFilterBar(),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
        onRefresh: _loadTransactions,
        color: _primaryColor,
        child: Column(
          children: [
            _buildTotalSummaryCard(context, totalPendente),

            if (transactions.isEmpty)
              const Expanded(
                child: Center(child: Text('Nenhuma conta encontrada para o filtro atual.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isPending = transaction.status == TransactionStatus.pendente;
                    return _buildTransactionCard(context, transaction, isPending);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummaryCard(BuildContext context, double totalPendente) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(_filterStatus == 'Todos' ? 'Total Geral' : 'Contas ${_filterStatus}', style: const TextStyle(color: Colors.white)),
              backgroundColor: _primaryColor,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Valor Total:', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  currencyFormat.format(totalPendente),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _filterStatus == 'Pago' ? Colors.green[700] : _filterStatus == 'Pendente' ? Colors.red[700] : _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel transaction, bool isPending) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isPending ? const BorderSide(color: Colors.red, width: 1.5) : const BorderSide(color: _accentColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.red.shade100 : _accentColor.withOpacity(0.2),
          child: Icon(
            Icons.money_off,
            color: isPending ? Colors.red : _accentColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPending ? Colors.black87 : Colors.grey[600],
            decoration: isPending ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          'Venc: ${DateFormat('dd/MM/yy').format(transaction.dueDate)} | ${transaction.category}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currencyFormat.format(transaction.value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPending ? Colors.red.shade700 : Colors.green.shade700,
                fontSize: 16,
              ),
            ),
            if (!isPending)
              Text(
                'Pago: ${DateFormat('dd/MM/yy').format(transaction.paymentDate!)}',
                style: const TextStyle(fontSize: 10, color: Colors.green),
              ),
          ],
        ),
        onTap: () => _showTransactionActions(transaction),
      ),
    );
  }

  PreferredSize _buildFilterBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Container(
        color: _primaryColor,
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
        alignment: Alignment.centerLeft,
        child: SegmentedButton<String>(
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            selectedBackgroundColor: _primaryColor,
            foregroundColor: _primaryColor,
            selectedForegroundColor: Colors.white,
          ),
          segments: const <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: 'Pendente',
              label: Text('Pendente'),
              icon: Icon(Icons.warning_amber),
            ),
            ButtonSegment<String>(
              value: 'Pago',
              label: Text('Pago'),
              icon: Icon(Icons.check_circle_outline),
            ),
            ButtonSegment<String>(
              value: 'Todos',
              label: Text('Todos'),
              icon: Icon(Icons.list),
            ),
          ],
          selected: <String>{_filterStatus},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() => _filterStatus = newSelection.first);
            _loadTransactions();
          },
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    List<String> periodOptions = ['Mês Atual', 'Próximos 30 dias', 'Data Personalizada'];

    if (_filterPeriod.contains(' - ') && !periodOptions.contains(_filterPeriod)) {
      periodOptions.add(_filterPeriod);
    } else if (_filterPeriod.contains('/') && !periodOptions.contains(_filterPeriod)) {
      periodOptions.add(_filterPeriod);
    }

    return DropdownButton<String>(
      value: _filterPeriod,
      dropdownColor: _primaryColor,
      icon: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
      underline: Container(),
      style: const TextStyle(color: Colors.white),

      items: periodOptions
          .map((s) => DropdownMenuItem(
        value: s,
        child: Text(s, style: const TextStyle(color: Colors.white)),
      ))
          .toList(),

      onChanged: (value) async {
        if (value == null) return;

        if (value == 'Data Personalizada') {
          final pickedRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedRange != null) {
            setState(() {
              final formattedStart = DateFormat('dd/MM/yy').format(pickedRange.start);
              final formattedEnd = DateFormat('dd/MM/yy').format(pickedRange.end);
              _filterPeriod = '$formattedStart - $formattedEnd';
            });
          } else {
            return;
          }
        } else {
          setState(() {
            _filterPeriod = value;
          });
        }

        _loadTransactions();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _accentColor = Color(0xFF90A4AE);
const Color _incomeColor = Colors.green;

class AccountsReceivableScreen extends StatefulWidget {
  const AccountsReceivableScreen({super.key});

  @override
  State<AccountsReceivableScreen> createState() => _AccountsReceivableScreenState();
}

class _AccountsReceivableScreenState extends State<AccountsReceivableScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yy');

  String _filterStatus = 'Pendente';

  String _filterPeriodName = 'Mês Atual';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  String get _displayPeriod {
    if (_filterPeriodName == 'Data Personalizada' && _customStartDate != null && _customEndDate != null) {
      return '${dateFormat.format(_customStartDate!)} - ${dateFormat.format(_customEndDate!)}';
    }
    return _filterPeriodName;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  void _calculateDateRange(String periodName, {DateTime? start, DateTime? end}) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (periodName == 'Mês Atual') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      _customStartDate = startDate;
      _customEndDate = endDate;
    } else if (periodName == 'Próximos 30 dias') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate.add(const Duration(days: 30)).copyWith(hour: 23, minute: 59, second: 59);
      _customStartDate = startDate;
      _customEndDate = endDate;
    } else if (periodName == 'Data Personalizada' && start != null && end != null) {
      startDate = start.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      endDate = end.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);
      _customStartDate = startDate;
      _customEndDate = endDate;
    } else {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    _loadTransactions(startDate: startDate, endDate: endDate);
  }

  Future<void> _loadTransactions({DateTime? startDate, DateTime? endDate}) async {
    if (startDate == null || endDate == null) {
      _calculateDateRange(_filterPeriodName, start: _customStartDate, end: _customEndDate);
      return;
    }

    await Provider.of<TransactionProvider>(context, listen: false)
        .fetchAccountsReceivable(
      status: _filterStatus.toLowerCase(),
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _markAsReceived(TransactionModel transaction) {
    transaction.status = TransactionStatus.pago;
    transaction.paymentDate = DateTime.now();

    Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(transaction);

    if (_filterStatus == 'Pendente' || _filterStatus == 'Todos') {
      _loadTransactions(startDate: _customStartDate, endDate: _customEndDate);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação marcada como recebida!'), backgroundColor: _incomeColor),
    );
  }

  void _deleteTransaction(int id) {
    Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(id);

    _loadTransactions(startDate: _customStartDate, endDate: _customEndDate);

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
                  leading: const Icon(Icons.check_circle, color: _incomeColor),
                  title: const Text('Marcar como Recebido'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _markAsReceived(transaction);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit, color: _primaryColor),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed('/new-transaction', arguments: transaction.id)
                      .then((_) => _loadTransactions(startDate: _customStartDate, endDate: _customEndDate));
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

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime initialStart = _customStartDate ?? now.subtract(const Duration(days: 15));
    final DateTime initialEnd = _customEndDate ?? now.add(const Duration(days: 15));

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      currentDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filterPeriodName = 'Data Personalizada';
      });
      _calculateDateRange('Data Personalizada', start: picked.start, end: picked.end);
    } else {
      if (_customStartDate == null) {
        setState(() {
          _filterPeriodName = 'Mês Atual';
        });
        _calculateDateRange('Mês Atual');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.accountsReceivable;
    final totalPendente = transactions.fold(0.0, (sum, item) => sum + item.value);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contas a Receber', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          _buildDateFilter(),
        ],
        bottom: _buildFilterBar(),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
        onRefresh: () => _loadTransactions(startDate: _customStartDate, endDate: _customEndDate),
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
                    color: _filterStatus == 'Pendente' ? _incomeColor : _primaryColor,
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
        side: isPending ? const BorderSide(color: _incomeColor, width: 1.5) : const BorderSide(color: _accentColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.green.shade100! : _accentColor.withOpacity(0.2),
          child: Icon(
            Icons.arrow_downward,
            color: isPending ? _incomeColor : _accentColor,
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
          'Prev: ${DateFormat('dd/MM/yy').format(transaction.dueDate)} | ${transaction.category}',
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
                color: isPending ? _incomeColor : _accentColor,
                fontSize: 16,
              ),
            ),
            if (!isPending)
              Text(
                'Receb: ${DateFormat('dd/MM/yy').format(transaction.paymentDate!)}',
                style: const TextStyle(fontSize: 10, color: _incomeColor),
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
              label: Text('Recebido'),
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
            _loadTransactions(startDate: _customStartDate, endDate: _customEndDate);
          },
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    final List<String> staticPeriods = ['Mês Atual', 'Próximos 30 dias', 'Data Personalizada'];

    final List<String> dropdownItems = [
      ...staticPeriods,
      if (_filterPeriodName == 'Data Personalizada')
        _displayPeriod
    ];

    final String selectedValue = _displayPeriod;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedValue,
        icon: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
        hint: Text(_displayPeriod, style: const TextStyle(color: Colors.white)),
        style: const TextStyle(color: _primaryColor, fontSize: 14),
        dropdownColor: _primaryColor,
        items: dropdownItems.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
                value,
                style: TextStyle(
                  color: value == selectedValue ? Colors.white : Colors.white70,
                )
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue == 'Data Personalizada') {
            _selectDateRange();
          } else if (newValue != null && staticPeriods.contains(newValue)) {
            setState(() {
              _filterPeriodName = newValue;
            });
            _calculateDateRange(newValue);
          } else if (newValue != null && newValue.contains(' - ')) {
            setState(() {
              _filterPeriodName = 'Data Personalizada';
            });
            _loadTransactions(startDate: _customStartDate, endDate: _customEndDate);
          }
        },
      ),
    );
  }
}
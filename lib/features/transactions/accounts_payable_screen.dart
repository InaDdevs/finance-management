// lib/features/transactions/accounts_payable_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // <--- ADICIONADO

// Importações relativas
import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    // Erro 'TransactionProvider isn't a type' corrigido aqui
    await Provider.of<TransactionProvider>(context, listen: false)
        .fetchAccountsPayable(status: _filterStatus.toLowerCase());
  }

  void _markAsPaid(TransactionModel transaction) {
    transaction.status = TransactionStatus.pago;
    transaction.paymentDate = DateTime.now();

    Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação marcada como paga!'), backgroundColor: Colors.green),
    );
  }

  void _deleteTransaction(int id) {
    Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação excluída!'), backgroundColor: Colors.red),
    );
  }

  void _showTransactionActions(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: [
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
              leading: const Icon(Icons.edit, color: Colors.blue),
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
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Erro 'TransactionProvider isn't a type' corrigido aqui
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.accountsPayable;
    final totalPendente = transactions.fold(0.0, (sum, item) => sum + item.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Pagar'),
        bottom: _buildFilterBar(),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTransactions,
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total a Pagar (${_filterStatus})', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      currencyFormat.format(totalPendente),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (transactions.isEmpty)
              const Expanded(
                child: Center(child: Text('Nenhuma conta encontrada.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isPending = transaction.status == TransactionStatus.pendente;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPending ? Colors.red[100] : Colors.grey[200],
                          child: Icon(
                            Icons.arrow_upward,
                            color: isPending ? Colors.red : Colors.grey,
                          ),
                        ),
                        title: Text(transaction.description),
                        subtitle: Text(
                            'Venc: ${DateFormat('dd/MM/yy').format(transaction.dueDate)} - ${transaction.category}'),
                        trailing: Text(
                          currencyFormat.format(transaction.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPending ? Colors.red : Colors.grey,
                          ),
                        ),
                        onTap: () => _showTransactionActions(transaction),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSize _buildFilterBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<String>(
              value: _filterStatus,
              items: ['Pendente', 'Pago', 'Todos']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterStatus = value);
                  _loadTransactions();
                }
              },
            ),
            DropdownButton<String>(
              value: _filterPeriod,
              items: ['Mês Atual', 'Próximos 30 dias', 'Data Personalizada']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterPeriod = value);
                  // _loadTransactions(); // (Lógica de filtro de data precisa ser implementada)
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
// lib/features/transactions/transaction_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Importações relativas
import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.despesa;
  DateTime _dueDate = DateTime.now();
  DateTime? _paymentDate;
  String _category = 'Alimentação';

  // --- MUDANÇA AQUI ---
  // O valor inicial DEVE existir na lista _accounts
  String _account = 'Conta Corrente (Banco A)'; // <-- MUDANÇA AQUI
  // --- FIM DA MUDANÇA ---

  TransactionStatus _status = TransactionStatus.pendente;

  final List<String> _expenseCategories = ['Alimentação', 'Moradia', 'Transporte', 'Saúde'];
  final List<String> _revenueCategories = ['Salário', 'Vendas', 'Serviços'];
  final List<String> _accounts = ['Conta Corrente (Banco A)', 'Dinheiro', 'Poupança']; // A lista de opções

  Future<void> _selectDate(BuildContext context, {bool isPaymentDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPaymentDate ? _paymentDate ?? DateTime.now() : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentDate) {
          _paymentDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;

      final newTransaction = TransactionModel(
        type: _type,
        value: value,
        description: _descriptionController.text,
        dueDate: _dueDate,
        paymentDate: _paymentDate,
        category: _category,
        account: _account,
        status: _paymentDate != null ? TransactionStatus.pago : _status,
      );

      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação salva com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Transação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.despesa, label: Text('Despesa'), icon: Icon(Icons.remove)),
                ButtonSegment(value: TransactionType.receita, label: Text('Receita'), icon: Icon(Icons.add)),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _category = _type == TransactionType.despesa ? _expenseCategories[0] : _revenueCategories[0];
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: (_type == TransactionType.despesa ? _expenseCategories : _revenueCategories)
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _account, // Agora este valor 'Conta Corrente (Banco A)'
              decoration: const InputDecoration(labelText: 'Conta'),
              items: _accounts // E a lista ['Conta Corrente (Banco A)', ...]
                  .map((acc) => DropdownMenuItem(value: acc, child: Text(acc)))
                  .toList(), // Correspondem perfeitamente
              onChanged: (value) => setState(() => _account = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data de Vencimento/Previsão'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Data de Pagamento (Opcional)'),
              subtitle: Text(_paymentDate == null
                  ? 'Pendente'
                  : DateFormat('dd/MM/yyyy').format(_paymentDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isPaymentDate: true),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Salvar Transação'),
            ),
          ],
        ),
      ),
    );
  }
}
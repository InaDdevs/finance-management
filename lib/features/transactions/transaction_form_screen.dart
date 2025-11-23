
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _secondaryColor = Color(0xFF4DD0E1);
const Color _accentColor = Color(0xFF273238);
const Color _backgroundColor = Color(0xFFFFFFFF);

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

  String _account = 'Conta Corrente';

  final TransactionStatus _status = TransactionStatus.pendente;

  final List<String> _expenseCategories = ['Alimentação', 'Moradia', 'Transporte', 'Saúde', 'Educação',
    'Lazer','Serviços','Dívidas','Investimentos','Outros'];
  final List<String> _revenueCategories = ['Salário', 'Vendas', 'Serviços','Reembolsos','Renda Extra','Outros'];
  final List<String> _accounts = ['Conta Corrente', 'Dinheiro', 'Poupança','Conta Digital','Tesouro Direto'];

  Future<void> _selectDate(BuildContext context, {bool isPaymentDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPaymentDate ? _paymentDate ?? DateTime.now() : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _backgroundColor,
              onSurface: _accentColor,
            ), dialogTheme: const DialogThemeData(backgroundColor: _backgroundColor),
          ),
          child: child!,
        );
      },
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

  InputDecoration _customInputDecoration({required String labelText, String? prefixText}) {
    return InputDecoration(
      labelText: labelText,
      prefixText: prefixText,
      labelStyle: TextStyle(color: _accentColor.withOpacity(0.8)),
      floatingLabelStyle: const TextStyle(color: _secondaryColor),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: _accentColor.withOpacity(0.5)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _secondaryColor, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Registrar Transação', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.despesa,
                  label: Text('Despesa'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: TransactionType.receita,
                  label: Text('Receita'),
                  icon: Icon(Icons.add),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _category = _type == TransactionType.despesa ? _expenseCategories[0] : _revenueCategories[0];
                });
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return _type == TransactionType.despesa ? Colors.red : Colors.green;
                  }
                  return _accentColor.withOpacity(0.7);
                }),
                backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return _secondaryColor.withOpacity(0.3);
                  }
                  return _backgroundColor;
                }),
                side: WidgetStateProperty.all(BorderSide(color: _secondaryColor.withOpacity(0.5))),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: _customInputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: _accentColor),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: _customInputDecoration(labelText: 'Descrição'),
              style: const TextStyle(color: _accentColor),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _customInputDecoration(labelText: 'Categoria'),
              dropdownColor: _backgroundColor,
              style: const TextStyle(color: _accentColor),
              items: (_type == TransactionType.despesa ? _expenseCategories : _revenueCategories)
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: _accentColor))))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _account,
              decoration: _customInputDecoration(labelText: 'Conta'),
              dropdownColor: _backgroundColor,
              style: const TextStyle(color: _accentColor),
              items: _accounts
                  .map((acc) => DropdownMenuItem(value: acc, child: Text(acc, style: const TextStyle(color: _accentColor))))
                  .toList(),
              onChanged: (value) => setState(() => _account = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data de Vencimento/Previsão', style: TextStyle(color: _accentColor)),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dueDate), style: TextStyle(color: _accentColor.withOpacity(0.7))),
              trailing: const Icon(Icons.calendar_today, color: _primaryColor),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Data de Pagamento (Opcional)', style: TextStyle(color: _accentColor)),
              subtitle: Text(_paymentDate == null
                  ? 'Pendente'
                  : DateFormat('dd/MM/yyyy').format(_paymentDate!),
                  style: TextStyle(color: _paymentDate == null ? Colors.redAccent : _accentColor.withOpacity(0.7))),
              trailing: const Icon(Icons.calendar_today, color: _primaryColor),
              onTap: () => _selectDate(context, isPaymentDate: true),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Salvar Transação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

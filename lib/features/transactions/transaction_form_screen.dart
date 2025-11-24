import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/dart/providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

const Color _primaryColor = Color(0xFF273238);
const Color _secondaryColor = Color(0xFF4DD0E1);
const Color _accentColor = Color(0xFF90A4AE);
const Color _backgroundColor = Color(0xFFFFFFFF);

const Color _expenseColor = Colors.redAccent;
const Color _incomeColor = Colors.greenAccent;

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
              onSurface: _primaryColor,
            ),
            dialogTheme: DialogThemeData(backgroundColor: _backgroundColor),
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

  InputDecoration _customInputDecoration({
    required String labelText,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    const Color borderColor = Color(0xFFE0E0E0);

    return InputDecoration(
      labelText: labelText,
      prefixText: prefixText,
      labelStyle: const TextStyle(color: _accentColor, fontWeight: FontWeight.w500),
      floatingLabelStyle: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _secondaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  ButtonStyle _getSegmentedButtonStyle(TransactionType currentType) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return currentType == TransactionType.despesa ? _expenseColor : _incomeColor;
        }
        return _primaryColor;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return currentType == TransactionType.despesa ? _expenseColor.withOpacity(0.1) : _incomeColor.withOpacity(0.1);
        }
        return Colors.white;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: currentType == TransactionType.despesa ? _expenseColor : _incomeColor, width: 1.5);
        }
        return const BorderSide(color: Color(0xFFE0E0E0), width: 1.0);
      }),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSegmentStyle = _getSegmentedButtonStyle(_type);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Registrar Transação', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
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
              style: currentSegmentStyle,
              emptySelectionAllowed: false,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _customInputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              style: const TextStyle(color: _primaryColor, fontSize: 16),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: _customInputDecoration(labelText: 'Descrição'),
              style: const TextStyle(color: _primaryColor, fontSize: 16),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: _customInputDecoration(labelText: 'Categoria'),
              dropdownColor: _backgroundColor,
              style: const TextStyle(color: _primaryColor, fontSize: 16),
              items: (_type == TransactionType.despesa ? _expenseCategories : _revenueCategories)
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: _primaryColor))))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _account,
              decoration: _customInputDecoration(labelText: 'Conta'),
              dropdownColor: _backgroundColor,
              style: const TextStyle(color: _primaryColor, fontSize: 16),
              items: _accounts
                  .map((acc) => DropdownMenuItem(value: acc, child: Text(acc, style: const TextStyle(color: _primaryColor))))
                  .toList(),
              onChanged: (value) => setState(() => _account = value!),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Data de Vencimento/Previsão', style: TextStyle(color: _primaryColor.withOpacity(0.8))),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dueDate), style: const TextStyle(color: _primaryColor, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: _primaryColor),
              onTap: () => _selectDate(context),
            ),
            const Divider(height: 1),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Data de Pagamento (Opcional)', style: TextStyle(color: _primaryColor.withOpacity(0.8))),
              subtitle: Text(_paymentDate == null
                  ? 'Pendente'
                  : DateFormat('dd/MM/yyyy').format(_paymentDate!),
                  style: TextStyle(color: _paymentDate == null ? _expenseColor : _primaryColor, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: _primaryColor),
              onTap: () => _selectDate(context, isPaymentDate: true),
            ),
            const Divider(height: 1),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: Colors.black,
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
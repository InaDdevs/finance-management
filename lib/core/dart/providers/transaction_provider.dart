// lib/core/dart/providers/transaction_provider.dart
import 'package:flutter/material.dart';

// Importações corrigidas
import '../database/database_helper.dart'; // Sobe 1 nível
import '../../../models/transaction_model.dart'; // Sobe 3 níveis

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Erros 'TransactionModel not found' (agora corrigidos)
  List<TransactionModel> _accountsPayable = [];
  List<TransactionModel> _accountsReceivable = [];
  double _currentBalance = 0.0;
  bool _isLoading = false;

  List<TransactionModel> get accountsPayable => _accountsPayable;
  List<TransactionModel> get accountsReceivable => _accountsReceivable;
  double get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    _currentBalance = await _dbHelper.getCurrentBalance();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAccountsPayable({String status = 'pendente'}) async {
    _isLoading = true;
    notifyListeners();
    _accountsPayable = await _dbHelper.getAccountsPayable(status: status);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAccountsReceivable({String status = 'pendente'}) async {
    _isLoading = true;
    notifyListeners();
    _accountsReceivable = await _dbHelper.getAccountsReceivable(status: status);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbHelper.create(transaction);
    await _refreshData(); // 'await' adicionado
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dbHelper.update(transaction);
    await _refreshData(); // 'await' adicionado
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.delete(id);
    await _refreshData(); // 'await' adicionado
  }

  Future<void> _refreshData() async {
    // Adicionado 'await' para garantir que os dados sejam buscados
    // antes de o provider notificar (o que já acontece dentro dos fetches)
    await fetchDashboardData();
    await fetchAccountsPayable();
    await fetchAccountsReceivable();
  }
}
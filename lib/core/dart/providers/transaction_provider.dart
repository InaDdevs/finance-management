// lib/core/dart/providers/transaction_provider.dart
import 'package:flutter/material.dart';

// Importações corrigidas
import '../database/database_helper.dart'; // Sobe 1 nível
import '../../../models/transaction_model.dart'; // Sobe 3 níveis
class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- Estado do App Principal ---
  List<TransactionModel> _accountsPayable = [];
  List<TransactionModel> _accountsReceivable = [];
  double _currentBalance = 0.0;
  bool _isLoading = false;

  // --- Estado dos Relatórios (NOVOS) ---
  List<TransactionModel> _statementTransactions = [];
  Map<String, double> _categorySummary = {};

  // --- Getters do App Principal ---
  List<TransactionModel> get accountsPayable => _accountsPayable;
  List<TransactionModel> get accountsReceivable => _accountsReceivable;
  double get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;

  // --- Getters dos Relatórios (NOVOS) ---
  List<TransactionModel> get statementTransactions => _statementTransactions;
  Map<String, double> get categorySummary => _categorySummary;

  // --- Métodos de Busca (App Principal) ---
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

  // --- MÉTODOS DE BUSCA (Relatórios - NOVOS) ---
  // (Lembre-se de adicionar os métodos no database_helper também)

  Future<void> fetchStatement(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    // Você precisa adicionar 'getAllTransactionsByDate' no database_helper
    _statementTransactions = await _dbHelper.getAllTransactionsByDate(start, end); // <-- CORRIGIDO
    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchCategorySummary(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    // Você precisa adicionar 'getExpenseSummaryByCategory' no database_helper
    _categorySummary = await _dbHelper.getExpenseSummaryByCategory(start, end);
    _isLoading = false;
    notifyListeners();
  }

  // --- Métodos de Escrita (CRUD) ---
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

  // Atualiza apenas os dados principais (Dashboard, Contas)
  Future<void> _refreshData() async {
    await fetchDashboardData();
    await fetchAccountsPayable();
    await fetchAccountsReceivable();
  }
}
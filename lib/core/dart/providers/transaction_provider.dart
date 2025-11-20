import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../../../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<TransactionModel> _accountsPayable = [];
  List<TransactionModel> _accountsReceivable = [];
  double _currentBalance = 0.0;

  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  List<TransactionModel> _upcomingTransactions = [];

  bool _isLoading = false;

  List<TransactionModel> _statementTransactions = [];
  Map<String, double> _categorySummary = {};

  List<TransactionModel> get accountsPayable => _accountsPayable;
  List<TransactionModel> get accountsReceivable => _accountsReceivable;
  double get currentBalance => _currentBalance;

  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  List<TransactionModel> get upcomingTransactions => _upcomingTransactions;

  bool get isLoading => _isLoading;

  List<TransactionModel> get statementTransactions => _statementTransactions;
  Map<String, double> get categorySummary => _categorySummary;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dbHelper.getCurrentBalance(),
        _dbHelper.getMonthlyTotal(isIncome: true),
        _dbHelper.getMonthlyTotal(isIncome: false),
        _dbHelper.getUpcomingTransactions(days: 7),
        _dbHelper.getMonthlyCategorySummary(),
      ]);

      _currentBalance = results[0] as double;
      _monthlyIncome = results[1] as double;
      _monthlyExpense = results[2] as double;
      _upcomingTransactions = results[3] as List<TransactionModel>;
      _categorySummary = results[4] as Map<String, double>;

    } catch (e) {
      debugPrint("Erro ao carregar dashboard: $e");
    }

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

  Future<void> fetchStatement(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    _statementTransactions = await _dbHelper.getAllTransactionsByDate(start, end);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategorySummary(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();
    _categorySummary = await _dbHelper.getExpenseSummaryByCategory(start, end);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbHelper.create(transaction);
    await _refreshData();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dbHelper.update(transaction);
    await _refreshData();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.delete(id);
    await _refreshData();
  }

  Future<void> _refreshData() async {
    await fetchDashboardData();
    await fetchAccountsPayable();
    await fetchAccountsReceivable();
  }
}
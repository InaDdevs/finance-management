import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static Database? _database;
  static Completer<Database>? _dbCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_dbCompleter != null) return _dbCompleter!.future;

    _dbCompleter = Completer<Database>();
    try {
      final db = await _initDB('transactions.db');
      _database = db;
      _dbCompleter!.complete(db);
    } catch (e) {
      _dbCompleter!.completeError(e);
    }

    return _dbCompleter!.future;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const textTypeNull = 'TEXT NULL';

    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      type $textType,
      value $realType,
      description $textType,
      dueDate $textType,
      paymentDate $textTypeNull,
      category $textType,
      account $textType,
      status $textType,
      recurrence $textTypeNull,
      attachmentPath $textTypeNull
    )
    ''');
  }

  Future<Map<String, double>> getExpenseSummaryByCategory(DateTime start, DateTime end) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category, SUM(value) as total
      FROM transactions
      WHERE type = 'despesa' AND status = 'pago' AND dueDate BETWEEN ? AND ?
      GROUP BY category
      ORDER BY total DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return { for (var item in maps) item['category'] : (item['total'] as num).toDouble() };
  }

  Future<List<TransactionModel>> getAllTransactionsByDate(DateTime start, DateTime end) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'dueDate BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dueDate DESC',
    );
    return maps.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> create(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAccountsPayable({String status = 'pendente'}) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ? AND status LIKE ?',
      whereArgs: ['despesa', status == 'todos' ? '%' : status],
      orderBy: 'dueDate ASC',
    );
    return maps.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> getAccountsReceivable({String status = 'pendente'}) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ? AND status LIKE ?',
      whereArgs: ['receita', status == 'todos' ? '%' : status],
      orderBy: 'dueDate ASC',
    );
    return maps.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<double> getCurrentBalance() async {
    final db = await instance.database;
    final sumReceitas = await db.rawQuery(
        "SELECT SUM(value) as total FROM transactions WHERE type = 'receita' AND status = 'pago'");
    final sumDespesas = await db.rawQuery(
        "SELECT SUM(value) as total FROM transactions WHERE type = 'despesa' AND status = 'pago'");

    double receitas = (sumReceitas.first['total'] as num?)?.toDouble() ?? 0.0;
    double despesas = (sumDespesas.first['total'] as num?)?.toDouble() ?? 0.0;

    return receitas - despesas;
  }

  Future<int> update(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getMonthlyTotal({required bool isIncome}) async {
    final db = await instance.database;
    final now = DateTime.now();

    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    final String type = isIncome ? 'receita' : 'despesa';

    final result = await db.rawQuery('''
      SELECT SUM(value) as total 
      FROM transactions 
      WHERE type = ? AND dueDate BETWEEN ? AND ?
    ''', [type, startOfMonth, endOfMonth]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return double.tryParse(result.first['total'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  Future<List<TransactionModel>> getUpcomingTransactions({int days = 7}) async {
    final db = await instance.database;
    final now = DateTime.now();

    final startOfToday = DateTime(now.year, now.month, now.day);
    final futureDate = startOfToday.add(Duration(days: days));

    final result = await db.query(
      'transactions',
      where: 'type = ? AND status = ? AND dueDate BETWEEN ? AND ?',
      whereArgs: [
        'despesa',
        'pendente',
        startOfToday.toIso8601String(),
        futureDate.toIso8601String()
      ],
      orderBy: 'dueDate ASC',
    );

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<Map<String, double>> getMonthlyCategorySummary() async {
    final db = await instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category, SUM(value) as total
      FROM transactions
      WHERE type = 'despesa' AND dueDate BETWEEN ? AND ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startOfMonth, endOfMonth]);

    return { for (var item in maps) item['category'] : (item['total'] as num).toDouble() };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
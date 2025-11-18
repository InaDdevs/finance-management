// lib/core/dart/database/database_helper.dart
import 'dart:async'; // <--- ADICIONE ESTA IMPORTAÇÃO

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // --- MUDANÇA AQUI ---
  // Vamos usar um 'Completer' para gerenciar a inicialização
  static Database? _database;
  static Completer<Database>? _dbCompleter;

  Future<Database> get database async {
    // Se o banco de dados já foi inicializado, retorne-o
    if (_database != null) return _database!;

    // Se o banco de dados ESTÁ inicializando, espere pelo 'completer'
    if (_dbCompleter != null) {
      return _dbCompleter!.future;
    }

    // Se formos os primeiros, iniciamos o completer e a inicialização
    _dbCompleter = Completer<Database>();
    try {
      final db = await _initDB('transactions.db');
      _database = db;
      _dbCompleter!.complete(db); // Libera todos que estavam esperando
    } catch (e) {
      _dbCompleter!.completeError(e); // Em caso de erro
    }

    return _dbCompleter!.future;
  }
  // --- FIM DA MUDANÇA ---


  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // ... (Seu código de _createDB não muda) ...
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

  // --- OPERAÇÕES CRUD (Não mudam) ---

  // Retorna um resumo de despesas por categoria
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
      where: 'dueDate BETWEEN ? AND ?', // Correto (sem status)
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
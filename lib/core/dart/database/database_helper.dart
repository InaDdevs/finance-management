// lib/core/dart/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importação corrigida: Sobe 3 níveis (de database/dart/core para lib/)
import '../../../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db'); // Agora _initDB existe
    return _database!;
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

  // --- OPERAÇÕES CRUD ---

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
    // Erro 'TransactionModel' not found (agora corrigido pela importação)
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

    // Adicionado .toDouble() para segurança de tipo
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
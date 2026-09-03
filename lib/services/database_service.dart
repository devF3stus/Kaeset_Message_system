import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        transaction_code TEXT NOT NULL UNIQUE,
        timestamp INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        phone_number TEXT,
        raw_message TEXT
      )
    ''');

    // Indexes for fast searching and sorting
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_name ON ${AppConstants.tableName}(name COLLATE NOCASE);'
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_code ON ${AppConstants.tableName}(transaction_code);'
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON ${AppConstants.tableName}(timestamp DESC);'
    );
  }

  /// Batch insert transactions, ignoring existing transaction codes (no duplicates)
  /// Returns the number of newly inserted records.
  Future<int> insertBatch(List<Transaction> transactions) async {
    if (transactions.isEmpty) return 0;

    final db = await database;
    final batch = db.batch();

    for (final tx in transactions) {
      batch.insert(
        AppConstants.tableName,
        tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final results = await batch.commit(noResult: false);
    // Count successful non-null and non-zero row id inserts
    int insertedCount = 0;
    for (final res in results) {
      if (res is int && res > 0) {
        insertedCount++;
      }
    }
    return insertedCount;
  }

  /// Insert a single transaction
  Future<int> insertTransaction(Transaction tx) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableName,
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Search transactions by customer name or transaction code with filters and sorting
  Future<List<Transaction>> searchTransactions({
    String? query,
    TransactionType? filterType,
    String sortBy = 'date_desc',
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (query != null && query.trim().isNotEmpty) {
      final sanitizedQuery = '%${query.trim()}%';
      whereClauses.add('(name LIKE ? OR transaction_code LIKE ? OR phone_number LIKE ?)');
      whereArgs.addAll([sanitizedQuery, sanitizedQuery, sanitizedQuery]);
    }

    if (filterType != null) {
      whereClauses.add('transaction_type = ?');
      whereArgs.add(filterType.name);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    String orderBy;
    switch (sortBy) {
      case 'date_asc':
        orderBy = 'timestamp ASC';
        break;
      case 'amount_desc':
        orderBy = 'amount DESC';
        break;
      case 'amount_asc':
        orderBy = 'amount ASC';
        break;
      case 'name_asc':
        orderBy = 'name COLLATE NOCASE ASC';
        break;
      case 'date_desc':
      default:
        orderBy = 'timestamp DESC';
        break;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableName,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  /// Get total count of transactions
  Future<int> getTransactionCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableName}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total amount received in KES
  Future<double> getTotalReceived() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableName} WHERE transaction_type = 'received'"
    );
    final val = result.first['total'];
    return (val as num?)?.toDouble() ?? 0.0;
  }

  /// Get total amount sent in KES
  Future<double> getTotalSent() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ${AppConstants.tableName} WHERE transaction_type = 'sent'"
    );
    final val = result.first['total'];
    return (val as num?)?.toDouble() ?? 0.0;
  }

  /// Get all transactions for CSV export
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableName,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  /// Clear all transaction data
  Future<int> clearAllTransactions() async {
    final db = await database;
    return await db.delete(AppConstants.tableName);
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

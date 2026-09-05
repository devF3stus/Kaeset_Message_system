import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart' as app_models;
import '../services/database_service.dart';
import '../services/preference_service.dart';
import '../services/sms_service.dart';
import '../utils/helpers.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  List<app_models.Transaction> _transactions = [];
  List<app_models.Transaction> _searchResults = [];

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _syncError;
  DateTime? _lastSyncTime;

  // Stats
  int _totalCount = 0;
  double _totalReceived = 0.0;
  double _totalSent = 0.0;

  // Search & Filter State
  String _searchQuery = '';
  app_models.TransactionType? _filterType;
  String _sortBy = 'date_desc';

  // Getters
  List<app_models.Transaction> get transactions => _transactions;
  List<app_models.Transaction> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;
  DateTime? get lastSyncTime => _lastSyncTime;

  int get totalCount => _totalCount;
  double get totalReceived => _totalReceived;
  double get totalSent => _totalSent;

  String get searchQuery => _searchQuery;
  app_models.TransactionType? get filterType => _filterType;
  String get sortBy => _sortBy;

  TransactionProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await PreferenceService.getInstance();
    _lastSyncTime = prefs.getLastSyncTime();

    await refreshDashboard();

    _isLoading = false;
    notifyListeners();
  }

  /// Reload dashboard data and stats
  Future<void> refreshDashboard() async {
    _totalCount = await _dbService.getTransactionCount();
    _totalReceived = await _dbService.getTotalReceived();
    _totalSent = await _dbService.getTotalSent();

    // Load recent 100 transactions for the dashboard
    _transactions = await _dbService.searchTransactions(
      limit: 100,
      sortBy: 'date_desc',
    );

    // Also run search query if present
    await executeSearch();

    notifyListeners();
  }

  /// Execute search query with active filters
  Future<void> executeSearch() async {
    _searchResults = await _dbService.searchTransactions(
      query: _searchQuery,
      filterType: _filterType,
      sortBy: _sortBy,
      limit: 200,
    );
    notifyListeners();
  }

  /// Real-time search query updated by user
  void setSearchQuery(String query) {
    _searchQuery = query;
    executeSearch();
  }

  /// Change filter type (All, Received, Sent)
  void setFilterType(app_models.TransactionType? type) {
    _filterType = type;
    executeSearch();
  }

  /// Change sort ordering
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    executeSearch();
  }

  /// Clear active search
  void clearSearch() {
    _searchQuery = '';
    _filterType = null;
    _sortBy = 'date_desc';
    executeSearch();
  }

  /// Sync M-Pesa SMS messages from device
  Future<int> syncMessages() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    int newInserted = 0;
    try {
      final messages = await SmsService.readAndParseMpesaMessages();
      if (messages.isNotEmpty) {
        newInserted = await _dbService.insertBatch(messages);
      }

      final now = DateTime.now();
      _lastSyncTime = now;
      final prefs = await PreferenceService.getInstance();
      await prefs.saveLastSyncTime(now);

      await refreshDashboard();
    } catch (e) {
      _syncError = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }

    return newInserted;
  }

  /// Load realistic mock M-Pesa data for testing & instant preview
  Future<int> loadMockData() async {
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    int inserted = 0;
    try {
      final mockMessages = SmsService.getMockMessages();
      final List<app_models.Transaction> mockTxs = [];

      for (final msg in mockMessages) {
        final tx = SmsService.parseMpesaMessage(msg);
        if (tx != null) {
          mockTxs.add(tx);
        }
      }

      inserted = await _dbService.insertBatch(mockTxs);
      final now = DateTime.now();
      _lastSyncTime = now;
      final prefs = await PreferenceService.getInstance();
      await prefs.saveLastSyncTime(now);

      await refreshDashboard();
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }

    return inserted;
  }

  /// Clear all transaction records from SQLite database
  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    await _dbService.clearAllTransactions();
    _transactions = [];
    _searchResults = [];
    _totalCount = 0;
    _totalReceived = 0.0;
    _totalSent = 0.0;

    _isLoading = false;
    notifyListeners();
  }

  /// Export transactions to CSV file and return the saved file path
  Future<String> exportToCsv() async {
    final allTxs = await _dbService.getAllTransactions();
    final csvContent = AppHelpers.generateCsv(allTxs);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'kaeset_mpesa_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);

    return file.path;
  }
}

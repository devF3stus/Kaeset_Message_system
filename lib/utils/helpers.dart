import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../models/transaction.dart';

class AppHelpers {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: 'KES ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.currency(
    symbol: 'KES ',
    decimalDigits: 0,
  );

  /// Formats amount into KES 1,500.00
  static String formatCurrency(double amount, {bool compact = false}) {
    if (compact && amount >= 10000) {
      return _compactCurrency.format(amount);
    }
    return _currencyFormatter.format(amount);
  }

  /// Formats timestamp into readable representation
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (msgDate == today) {
      return 'Today, $timeStr';
    } else if (msgDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else if (now.year == dateTime.year) {
      return '${DateFormat('dd MMM').format(dateTime)}, $timeStr';
    } else {
      return '${DateFormat('dd MMM yyyy').format(dateTime)}, $timeStr';
    }
  }

  /// Detailed timestamp format for CSV and exports
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// Converts transactions to CSV formatted string
  static String generateCsv(List<Transaction> transactions) {
    final List<List<dynamic>> rows = [
      [
        'ID',
        'Transaction Code',
        'Customer Name',
        'Phone Number',
        'Amount (KES)',
        'Transaction Type',
        'Date and Time',
        'Raw SMS'
      ]
    ];

    for (final t in transactions) {
      rows.add([
        t.id ?? '',
        t.transactionCode,
        t.name,
        t.phoneNumber ?? '',
        t.amount,
        t.type.displayName,
        formatFullDateTime(t.timestamp),
        t.rawMessage ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}

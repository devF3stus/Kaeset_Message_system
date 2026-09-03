import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('com.kaeset.messagesystem/sms');

  /// Request READ_SMS permission
  static Future<PermissionStatus> requestPermission() async {
    return await Permission.sms.request();
  }

  /// Check if SMS permission is granted
  static Future<bool> hasPermission() async {
    return await Permission.sms.isGranted;
  }

  /// Read SMS from Android device and parse all M-Pesa transactions
  static Future<List<Transaction>> readAndParseMpesaMessages() async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final status = await requestPermission();
      if (!status.isGranted) {
        throw Exception('SMS permission not granted');
      }
    }

    try {
      final List<dynamic>? rawMessages = await _channel.invokeMethod<List<dynamic>>('getSmsMessages');
      if (rawMessages == null || rawMessages.isEmpty) {
        return [];
      }

      final List<Transaction> transactions = [];

      for (final item in rawMessages) {
        if (item is Map) {
          final body = item['body'] as String? ?? '';
          final dateMillis = item['date'] as int?;
          final envelopeDate = dateMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(dateMillis)
              : DateTime.now();

          final parsedTx = parseMpesaMessage(body, defaultDate: envelopeDate);
          if (parsedTx != null) {
            transactions.add(parsedTx);
          }
        }
      }

      return transactions;
    } on PlatformException catch (e) {
      throw Exception('Failed to read SMS: ${e.message}');
    }
  }

  /// Parses a single M-Pesa SMS message string into a Transaction object.
  /// Returns null if the SMS is not an M-Pesa transaction or fails to parse.
  static Transaction? parseMpesaMessage(String body, {DateTime? defaultDate}) {
    if (body.isEmpty) return null;

    final trimmed = body.trim();

    // 1. Extract Transaction Reference Code (e.g. QL9KJ3X or QA12BC34DE)
    // Safaricom M-Pesa codes are alphanumeric, typically 8 to 12 chars followed by "Confirmed"
    final codeMatch = RegExp(r'^([A-Z0-9]{8,12})\s*Confirmed', caseSensitive: false).firstMatch(trimmed);
    if (codeMatch == null) {
      return null;
    }
    final code = codeMatch.group(1)!.toUpperCase();

    // 2. Determine Transaction Type & extract details
    final isReceived = RegExp(r'received\s+Ksh', caseSensitive: false).hasMatch(trimmed) ||
                       RegExp(r'give\s+Ksh', caseSensitive: false).hasMatch(trimmed);
    final isSent = RegExp(r'sent\s+to|paid\s+to', caseSensitive: false).hasMatch(trimmed);

    if (!isReceived && !isSent) {
      return null;
    }

    final TransactionType type = isReceived ? TransactionType.received : TransactionType.sent;

    // 3. Extract Amount
    // Matches e.g. "Ksh1,500.00" or "Ksh 500"
    final amountMatch = RegExp(r'Ksh\s*([0-9,]+(?:\.[0-9]{1,2})?)', caseSensitive: false).firstMatch(trimmed);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) return null;

    // 4. Extract Date and Time from SMS body
    // Format in SMS is typically: "on 3/9/26 at 2:30 PM" or "on 03/09/2026 at 10:15 AM"
    DateTime timestamp = defaultDate ?? DateTime.now();
    final dateTimeMatch = RegExp(
      r'on\s+(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})\s+at\s+(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (dateTimeMatch != null) {
      final datePart = dateTimeMatch.group(1)!;
      final timePart = dateTimeMatch.group(2)!.trim();
      final parsedDate = _parseDateString(datePart, timePart);
      if (parsedDate != null) {
        timestamp = parsedDate;
      }
    }

    // 5. Extract Customer/Sender/Merchant Name and optional Phone Number
    String name = 'Unknown';
    String? phone;

    if (isReceived) {
      // Example: "You have received Ksh1,500.00 from JOHN MWANGI 0712345678 on 3/9/26"
      final receivedPattern = RegExp(
        r'from\s+([A-Za-z0-9\s\.\'\-]+?)(?:\s+(07\d{8}|01\d{8}|\+?254\d{9}))?\s+on\s+\d',
        caseSensitive: false,
      );
      final match = receivedPattern.firstMatch(trimmed);
      if (match != null) {
        name = _cleanName(match.group(1) ?? 'Unknown');
        phone = match.group(2);
      }
    } else {
      // Sent or Paid to:
      // "sent to MARY WANJIRU 0723456789 on 3/9/26"
      // "paid to KPLC PREPAID. on 3/9/26"
      final sentPattern = RegExp(
        r'(?:sent\s+to|paid\s+to)\s+([A-Za-z0-9\s\.\'\-]+?)(?:\s+(07\d{8}|01\d{8}|\+?254\d{9}))?\s+on\s+\d',
        caseSensitive: false,
      );
      final match = sentPattern.firstMatch(trimmed);
      if (match != null) {
        name = _cleanName(match.group(1) ?? 'Unknown');
        phone = match.group(2);
      }
    }

    return Transaction(
      name: name,
      amount: amount,
      transactionCode: code,
      timestamp: timestamp,
      type: type,
      phoneNumber: phone,
      rawMessage: trimmed,
    );
  }

  static String _cleanName(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'[\.\,\:\;]+$'), '').trim();
    // Normalize multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'Unknown';
    return cleaned;
  }

  static DateTime? _parseDateString(String dateStr, String timeStr) {
    final formats = [
      'd/M/yy h:mm a',
      'd/M/yyyy h:mm a',
      'dd/MM/yy h:mm a',
      'dd/MM/yyyy h:mm a',
      'd-M-yy h:mm a',
      'd-M-yyyy h:mm a',
    ];

    final cleanTime = timeStr.toUpperCase();
    final combined = '$dateStr $cleanTime';

    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(combined);
      } catch (_) {}
    }
    return null;
  }

  /// Sample realistic M-Pesa messages for instant demonstration/testing
  static List<String> getMockMessages() {
    return [
      "QA12BC34DE Confirmed. You have received Ksh2,500.00 from JOHN MWANGI 0712345678 on 3/9/26 at 10:15 AM. New M-PESA balance is Ksh15,200.00. Separate personal and business funds with Pochi La Biashara.",
      "QA12BC34DF Confirmed. Ksh1,200.00 sent to MARY WANJIRU 0723456789 on 2/9/26 at 4:30 PM. New M-PESA balance is Ksh12,700.00. Transaction cost, Ksh0.00.",
      "QA12BC34DG Confirmed. You have received Ksh7,850.00 from PETER KAMAU 0734567890 on 2/9/26 at 1:45 PM. New M-PESA balance is Ksh13,900.00.",
      "QA12BC34DH Confirmed. Ksh3,400.00 paid to KPLC PREPAID on 1/9/26 at 6:10 PM. New M-PESA balance is Ksh6,050.00. Transaction cost, Ksh23.00.",
      "QA12BC34DI Confirmed. You have received Ksh15,000.00 from ALICE OTIENO 0745678901 on 1/9/26 at 11:20 AM. New M-PESA balance is Ksh9,450.00.",
      "QA12BC34DJ Confirmed. Ksh4,500.00 sent to KEVIN KIPROP 0756789012 on 31/8/26 at 9:05 AM. New M-PESA balance is Ksh24,450.00.",
      "QA12BC34DK Confirmed. You have received Ksh1,800.00 from GRACE WANJIKU 0767890123 on 30/8/26 at 3:15 PM. New M-PESA balance is Ksh28,950.00.",
      "QA12BC34DL Confirmed. Ksh950.00 paid to TOTAL SERVICE STATION on 30/8/26 at 8:40 AM. New M-PESA balance is Ksh27,150.00.",
      "QA12BC34DM Confirmed. You have received Ksh6,200.00 from BRIAN MUTUA 0778901234 on 29/8/26 at 5:50 PM. New M-PESA balance is Ksh28,100.00.",
      "QA12BC34DN Confirmed. Ksh5,000.00 sent to FAITH CHEBET 0789012345 on 28/8/26 at 2:10 PM. New M-PESA balance is Ksh21,900.00.",
      "QA12BC34DO Confirmed. You have received Ksh3,100.00 from JOHN MWANGI 0712345678 on 27/8/26 at 12:30 PM. New M-PESA balance is Ksh26,900.00.",
      "QA12BC34DP Confirmed. You have received Ksh4,700.00 from DANIEL NJOROGE 0790123456 on 26/8/26 at 4:25 PM. New M-PESA balance is Ksh23,800.00.",
      "QA12BC34DQ Confirmed. Ksh2,100.00 paid to NAIVAS SUPERMARKET on 25/8/26 at 7:15 PM. New M-PESA balance is Ksh19,100.00.",
      "QA12BC34DR Confirmed. You have received Ksh8,500.00 from MERCY ACHIENG 0701234567 on 24/8/26 at 10:00 AM. New M-PESA balance is Ksh21,200.00.",
      "QA12BC34DS Confirmed. Ksh1,500.00 sent to SAMUEL KARIUKI 0711122233 on 23/8/26 at 1:40 PM. New M-PESA balance is Ksh12,700.00.",
    ];
  }
}

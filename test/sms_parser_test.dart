import 'package:flutter_test/flutter_test.dart';
import 'package:kaeset_message_system/models/transaction.dart';
import 'package:kaeset_message_system/services/sms_service.dart';

void main() {
  group('SmsService M-Pesa Parsing Tests', () {
    test('Parses Money Received SMS correctly', () {
      const sms = 'QA12BC34DE Confirmed. You have received Ksh2,500.00 from JOHN MWANGI 0712345678 on 3/9/26 at 10:15 AM. New M-PESA balance is Ksh15,200.00.';
      final tx = SmsService.parseMpesaMessage(sms);

      expect(tx, isNotNull);
      expect(tx!.transactionCode, 'QA12BC34DE');
      expect(tx.name, 'JOHN MWANGI');
      expect(tx.phoneNumber, '0712345678');
      expect(tx.amount, 2500.00);
      expect(tx.type, TransactionType.received);
    });

    test('Parses Money Sent SMS correctly', () {
      const sms = 'QA12BC34DF Confirmed. Ksh1,200.00 sent to MARY WANJIRU 0723456789 on 2/9/26 at 4:30 PM. New M-PESA balance is Ksh12,700.00. Transaction cost, Ksh0.00.';
      final tx = SmsService.parseMpesaMessage(sms);

      expect(tx, isNotNull);
      expect(tx!.transactionCode, 'QA12BC34DF');
      expect(tx.name, 'MARY WANJIRU');
      expect(tx.phoneNumber, '0723456789');
      expect(tx.amount, 1200.00);
      expect(tx.type, TransactionType.sent);
    });

    test('Parses Paybill / Paid To transaction correctly', () {
      const sms = 'QA12BC34DH Confirmed. Ksh3,400.00 paid to KPLC PREPAID on 1/9/26 at 6:10 PM. New M-PESA balance is Ksh6,050.00.';
      final tx = SmsService.parseMpesaMessage(sms);

      expect(tx, isNotNull);
      expect(tx!.transactionCode, 'QA12BC34DH');
      expect(tx.name, 'KPLC PREPAID');
      expect(tx.amount, 3400.00);
      expect(tx.type, TransactionType.sent);
    });

    test('Rejects non-M-Pesa SMS gracefully', () {
      const spam = 'Dear customer, your airtime recharge of Ksh 50 was successful.';
      final tx = SmsService.parseMpesaMessage(spam);
      expect(tx, isNull);
    });

    test('Rejects empty or random strings', () {
      expect(SmsService.parseMpesaMessage(''), isNull);
      expect(SmsService.parseMpesaMessage('Hello world!'), isNull);
    });

    test('Parses received SMS without phone number', () {
      const sms = 'QA12BC34DX Confirmed. You have received Ksh3,000.00 from ALICE NJERI on 5/9/26 at 2:00 PM. New M-PESA balance is Ksh8,000.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, 'ALICE NJERI');
      expect(tx.phoneNumber, isNull);
    });

    test('Parses sent SMS without phone number', () {
      const sms = 'QA12BC34DY Confirmed. Ksh500.00 paid to KPLC PREPAID. on 5/9/26 at 3:00 PM. New M-PESA balance is Ksh7,500.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, 'KPLC PREPAID');
    });

    test('Parses received SMS with name containing special characters', () {
      const sms = 'QA12BC34DZ Confirmed. You have received Ksh1,000.00 from O\'BRIEN 0711122233 on 5/9/26 at 4:00 PM. New M-PESA balance is Ksh9,000.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, contains('BRIEN'));
    });

    test('Parses received SMS where name is followed by period not "on"', () {
      const sms = 'QA12BC34EA Confirmed. You have received Ksh2,000.00 from SAFARICOM. New M-PESA balance is Ksh10,000.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, isNot('Unknown'));
    });

    test('All 15 mock messages parse with non-Unknown names', () {
      final messages = SmsService.getMockMessages();
      for (final msg in messages) {
        final tx = SmsService.parseMpesaMessage(msg);
        expect(tx, isNotNull, reason: 'Failed to parse: $msg');
        expect(tx!.name, isNot('Unknown'), reason: 'Name is Unknown for: $msg');
      }
    });

    test('Parses "Ksh received from" format (alt M-Pesa format)', () {
      const sms = 'QA12BC34EB Confirmed. Ksh2,500.00 received from JOHN MWANGI 0712345678 on 5/9/26 at 10:15 AM. New M-PESA balance is Ksh15,200.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, 'JOHN MWANGI');
      expect(tx.phoneNumber, '0712345678');
      expect(tx.type, TransactionType.received);
    });

    test('Parses received SMS with name followed by period (no "on")', () {
      const sms = 'QA12BC34EC Confirmed. You have received Ksh500.00 from SUPERMARKET LTD. New M-PESA balance is Ksh9,500.00.';
      final tx = SmsService.parseMpesaMessage(sms);
      expect(tx, isNotNull);
      expect(tx!.name, isNot('Unknown'));
    });
  });
}

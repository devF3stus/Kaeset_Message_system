import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/font_size_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final isReceived = transaction.type == TransactionType.received;

    final primaryColor = isReceived ? AppColors.received : AppColors.sent;
    final bgColor = isReceived ? AppColors.receivedLight : AppColors.sentLight;
    final typeIcon = isReceived ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final prefix = isReceived ? '+' : '-';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailsDialog(context, fontProvider),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Name and Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type icon badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      typeIcon,
                      color: primaryColor,
                      size: fontProvider.scale(18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Customer Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.name,
                          style: TextStyle(
                            fontSize: fontProvider.scale(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (transaction.phoneNumber != null)
                          Text(
                            transaction.phoneNumber!,
                            style: TextStyle(
                              fontSize: fontProvider.scale(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$prefix ${AppHelpers.formatCurrency(transaction.amount)}',
                        style: TextStyle(
                          fontSize: fontProvider.scale(16),
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.type.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: fontProvider.scale(10),
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Row 2: Code & Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Transaction Code
                  Row(
                    children: [
                      Icon(
                        Icons.tag,
                        size: fontProvider.scale(14),
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transaction.transactionCode,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: fontProvider.scale(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: fontProvider.scale(13),
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppHelpers.formatDateTime(transaction.timestamp),
                        style: TextStyle(
                          fontSize: fontProvider.scale(12),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, FontSizeProvider fontProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              transaction.type == TransactionType.received
                  ? Icons.check_circle_rounded
                  : Icons.outbox_rounded,
              color: transaction.type == TransactionType.received
                  ? AppColors.received
                  : AppColors.sent,
            ),
            const SizedBox(width: 8),
            Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: fontProvider.scale(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Customer / Party', transaction.name, fontProvider),
              if (transaction.phoneNumber != null)
                _detailRow('Phone Number', transaction.phoneNumber!, fontProvider),
              _detailRow('Amount', AppHelpers.formatCurrency(transaction.amount), fontProvider),
              _detailRow('Transaction Code', transaction.transactionCode, fontProvider),
              _detailRow('Type', transaction.type.displayName, fontProvider),
              _detailRow('Timestamp', AppHelpers.formatFullDateTime(transaction.timestamp), fontProvider),
              if (transaction.rawMessage != null && transaction.rawMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Original SMS Message:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontProvider.scale(13),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    transaction.rawMessage!,
                    style: TextStyle(
                      fontSize: fontProvider.scale(12),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Code'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: transaction.transactionCode));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code ${transaction.transactionCode} copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, FontSizeProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: fontProvider.scale(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontProvider.scale(13),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

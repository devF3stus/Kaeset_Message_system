enum TransactionType {
  received,
  sent;

  String get displayName {
    switch (this) {
      case TransactionType.received:
        return 'Received';
      case TransactionType.sent:
        return 'Sent';
    }
  }

  static TransactionType fromString(String val) {
    if (val.toLowerCase() == 'received') {
      return TransactionType.received;
    }
    return TransactionType.sent;
  }
}

class Transaction {
  final int? id;
  final String name;
  final double amount;
  final String transactionCode;
  final DateTime timestamp;
  final TransactionType type;
  final String? phoneNumber;
  final String? rawMessage;

  const Transaction({
    this.id,
    required this.name,
    required this.amount,
    required this.transactionCode,
    required this.timestamp,
    required this.type,
    this.phoneNumber,
    this.rawMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'transaction_code': transactionCode,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'transaction_type': type.name,
      'phone_number': phoneNumber,
      'raw_message': rawMessage,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Unknown',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      transactionCode: map['transaction_code'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      type: TransactionType.fromString(map['transaction_type'] as String? ?? 'received'),
      phoneNumber: map['phone_number'] as String?,
      rawMessage: map['raw_message'] as String?,
    );
  }

  Transaction copyWith({
    int? id,
    String? name,
    double? amount,
    String? transactionCode,
    DateTime? timestamp,
    TransactionType? type,
    String? phoneNumber,
    String? rawMessage,
  }) {
    return Transaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      transactionCode: transactionCode ?? this.transactionCode,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rawMessage: rawMessage ?? this.rawMessage,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, name: $name, amount: $amount, code: $transactionCode, type: ${type.name}, date: $timestamp)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          transactionCode == other.transactionCode;

  @override
  int get hashCode => transactionCode.hashCode;
}

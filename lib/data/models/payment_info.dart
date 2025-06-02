class PaymentInfo {
  final String transactionId;
  final double total;
  final String date;
  final String time;
  final String userId;
  final String invoiceId;
  final List<Map<String, dynamic>> items;

  const PaymentInfo({
    required this.transactionId,
    required this.total,
    required this.date,
    required this.time,
    required this.userId,
    required this.invoiceId,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'total': total,
      'date': date,
      'time': time,
      'userId': userId,
      'invoiceId': invoiceId,
      'items': items,
    };
  }

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      transactionId: map['transactionId'] ?? '',
      total: (map['total'] ?? 0.0).toDouble(),
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      userId: map['userId'] ?? '',
      invoiceId: map['invoiceId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
    );
  }
} 
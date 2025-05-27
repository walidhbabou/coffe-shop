class PaymentInfo {
  final String transactionId;
  final double total;
  final String date;
  final String time;

  const PaymentInfo({
    required this.transactionId,
    required this.total,
    required this.date,
    required this.time,
  });
} 
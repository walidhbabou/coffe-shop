// Placeholder for InvoiceModel
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String userId;
  final String transactionId;
  final double total;
  final String date;
  final String time;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;
  final String status;
  final String? paymentMethod;

  Invoice({
    required this.userId,
    required this.transactionId,
    required this.total,
    required this.date,
    required this.time,
    required this.items,
    required this.createdAt,
    required this.status,
    this.paymentMethod,
    String? id,
  }) : this.id = id ?? '';

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transactionId': transactionId,
      'total': total,
      'date': date,
      'time': time,
      'items': items,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Invoice(
      id: doc.id,
      userId: data['userId'] ?? '',
      transactionId: data['transactionId'] ?? '',
      total: (data['total'] ?? 0.0).toDouble(),
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      paymentMethod: data['paymentMethod'],
    );
  }
} 
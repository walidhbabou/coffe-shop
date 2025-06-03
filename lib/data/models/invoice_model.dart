// Placeholder for InvoiceModel
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Invoice {
  final String id;
  final String userId;
  final String transactionId;
  final double total;
  final String date;
  final String time;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;
  final String status; // 'paid', 'pending', 'cancelled'
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
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'],
    );
  }

  // Méthode pour mettre à jour le statut dans Firestore
  static Future<void> updateStatus(String invoiceId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoiceId)
          .update({'status': newStatus});
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      throw e;
    }
  }

  // Obtenir la couleur en fonction du statut
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtenir le texte d'affichage du statut
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
} 
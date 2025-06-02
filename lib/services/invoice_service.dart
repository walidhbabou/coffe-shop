import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/invoice_model.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'invoices';

  // Créer une nouvelle facture
  Future<String> createInvoice(Invoice invoice) async {
    try {
      final docRef = await _firestore.collection(_collection).add(invoice.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  // Obtenir la dernière facture d'un utilisateur
  Future<Invoice?> getLatestInvoice(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return Invoice.fromFirestore(doc);
    } catch (e) {
      print('Error getting latest invoice: $e');
      return null;
    }
  }

  // Obtenir les factures récentes d'un utilisateur
  Future<List<Invoice>> getRecentInvoices(String userId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Invoice.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting recent invoices: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'une facture
  Future<void> updateInvoiceStatus(String invoiceId, String status, {String? paymentMethod}) async {
    try {
      print('Début de la mise à jour de la facture $invoiceId');
      print('Nouveau statut: $status');
      print('Mode de paiement: $paymentMethod');

      Map<String, dynamic> updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentMethod != null) {
        updateData['paymentMethod'] = paymentMethod;
      }

      print('Données à mettre à jour: $updateData');

      // Vérifier si la facture existe
      final docSnapshot = await _firestore.collection(_collection).doc(invoiceId).get();
      if (!docSnapshot.exists) {
        throw Exception('La facture $invoiceId n\'existe pas');
      }

      print('Facture trouvée, état actuel: ${docSnapshot.data()?['status']}');

      await _firestore
          .collection(_collection)
          .doc(invoiceId)
          .update(updateData);

      print('Mise à jour réussie dans Firestore');

      // Vérifier la mise à jour
      final updatedDoc = await _firestore.collection(_collection).doc(invoiceId).get();
      print('Nouvel état dans Firestore: ${updatedDoc.data()?['status']}');

    } catch (e) {
      print('❌ Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }

  // Get all invoices for a specific user
  Stream<List<Invoice>> getUserInvoices(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    });
  }

  // Get all invoices (for admin) with pagination
  Stream<List<Invoice>> getAllInvoices({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    });
  }

  // Get more invoices for pagination
  Future<List<Invoice>> getMoreInvoices(DocumentSnapshot lastDocument, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting more invoices: $e');
      rethrow;
    }
  }

  // Get a specific invoice by ID
  Future<Invoice?> getInvoiceById(String invoiceId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(invoiceId).get();
      if (doc.exists) {
        return Invoice.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting invoice: $e');
      rethrow;
    }
  }

  // Delete an invoice (if needed)
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestore.collection(_collection).doc(invoiceId).delete();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  // Get invoices by status
  Stream<List<Invoice>> getInvoicesByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
    });
  }

  // Get total amount of invoices for a specific period
  Future<double> getTotalAmountForPeriod(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .where('status', isEqualTo: 'paid')
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['total'] ?? 0.0).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total amount: $e');
      rethrow;
    }
  }
} 
import 'package:flutter/material.dart';
import '../services/invoice_service.dart';
import '../models/invoice_model.dart';

class InvoiceHistoryPage extends StatelessWidget {
  final bool isAdmin;
  final String? userId;

  const InvoiceHistoryPage({
    Key? key,
    this.isAdmin = false,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoiceService = InvoiceService();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Toutes les Factures' : 'Mes Factures'),
        backgroundColor: Colors.brown[900],
      ),
      body: StreamBuilder<List<Invoice>>(
        stream: isAdmin
            ? invoiceService.getAllInvoices()
            : invoiceService.getUserInvoices(userId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final invoices = snapshot.data ?? [];

          if (invoices.isEmpty) {
            return const Center(
              child: Text('Aucune facture trouvée'),
            );
          }

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: Icon(
                    _getStatusIcon(invoice.status),
                    color: _getStatusColor(invoice.status),
                  ),
                  title: Text('Facture #${invoice.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${invoice.date}'),
                      Text('Heure: ${invoice.time}'),
                      Text('Statut: ${_getStatusText(invoice.status)}'),
                    ],
                  ),
                  trailing: Text(
                    '${invoice.total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // Afficher les détails de la facture
                    _showInvoiceDetails(context, invoice);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusText(String status) {
    switch (status) {
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

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Détails de la Facture',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('ID', invoice.id),
                    _buildDetailRow('Email', invoice.userEmail),
                    _buildDetailRow('Date', invoice.date),
                    _buildDetailRow('Heure', invoice.time),
                    _buildDetailRow('Statut', _getStatusText(invoice.status)),
                    _buildDetailRow('Méthode de paiement', invoice.paymentMethod ?? 'Non spécifiée'),
                    const SizedBox(height: 16),
                    const Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...invoice.items.map((item) => ListTile(
                          title: Text(item['name'] ?? ''),
                          trailing: Text('${item['price']?.toStringAsFixed(2)} €'),
                        )),
                    const Divider(),
                    _buildDetailRow(
                      'Total',
                      '${invoice.total.toStringAsFixed(2)} €',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              if (isAdmin && invoice.status == 'pending')
                ElevatedButton(
                  onPressed: () {
                    // Mettre à jour le statut de la facture
                    InvoiceService().updateInvoiceStatus(invoice.id, 'paid');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Marquer comme payée'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 
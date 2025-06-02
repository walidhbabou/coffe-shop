import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/payment_info.dart';

class QRCodeSection extends StatelessWidget {
  final PaymentInfo info;

  const QRCodeSection({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Code QR de Paiement',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.brown.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: QrImageView(
              data: 'InvoiceID: ${info.invoiceId}\n'
                  'Transaction: ${info.transactionId}\n'
                  'Total: ${info.total.toStringAsFixed(2)} €',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.transparent,
              errorStateBuilder: (context, error) => Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Erreur de génération\ndu QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
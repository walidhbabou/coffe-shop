import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/payment_info.dart';
import '../../data/models/invoice_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../domain/viewmodels/auth_viewmodel.dart';
import '../../domain/viewmodels/invoice_viewmodel.dart';

class ScanPayPage extends StatelessWidget {
  final PaymentInfo? paymentInfo;
  final bool showOnlyInfo;

  const ScanPayPage({
    Key? key,
    this.paymentInfo,
    this.showOnlyInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        title: Text(
          isAdmin ? 'Scanner une facture' : 'Paiement',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[900],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: isAdmin
            ? _buildQrScanner(context)
            : (paymentInfo != null
                ? _buildPaymentInfo(context)
                : _buildInitialState(context)),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Appuyez sur le bouton ci-dessous pour commencer à scanner ou à payer.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la logique de scan
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    if (paymentInfo == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la facture',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.brown,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildInfoRow('Transaction ID', paymentInfo!.transactionId),
                _buildInfoRow('Date', paymentInfo!.date),
                _buildInfoRow('Heure', paymentInfo!.time),
                const Divider(height: 32),
                _buildInfoRow(
                  'Total',
                  '${paymentInfo!.total.toStringAsFixed(2)} €',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: QrImageView(
              data: 'Transaction: ${paymentInfo!.transactionId}\n'
                  'Date: ${paymentInfo!.date}\n'
                  'Heure: ${paymentInfo!.time}\n'
                  'Total: ${paymentInfo!.total.toStringAsFixed(2)} €',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              errorStateBuilder: (context, error) => const Center(
                child: Text(
                  'Erreur de génération du QR code',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions de paiement',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInstructionStep(
                  '1',
                  'Présentez votre code QR à la caisse',
                ),
                _buildInstructionStep(
                  '2',
                  'Le caissier scannera votre code',
                ),
                _buildInstructionStep(
                  '3',
                  'Confirmez le paiement sur votre téléphone',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrScanner(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Scanner une facture',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Barcode found! ${barcode.rawValue}');
                
                try {
                  final data = barcode.rawValue?.split('\n');
                  if (data != null && data.length >= 4) {
                    final transactionId = data[0].replaceAll('Transaction: ', '');
                    final date = data[1].replaceAll('Date: ', '');
                    final time = data[2].replaceAll('Heure: ', '');
                    final total = double.parse(data[3].replaceAll('Total: ', '').replaceAll(' €', ''));

                    final invoiceViewModel = context.read<InvoiceViewModel>();
                    final invoice = await invoiceViewModel.getInvoiceById(transactionId);

                    if (invoice != null && context.mounted) {
                      // Mettre à jour le statut de la facture
                      await invoiceViewModel.updateInvoiceStatus(transactionId, 'paid');
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Facture marquée comme payée'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Facture non trouvée'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('Error parsing QR code: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la lecture du QR code: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.brown : Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.brown : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
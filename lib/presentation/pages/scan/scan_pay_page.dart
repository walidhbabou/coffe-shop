import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPayPage extends StatelessWidget {
  final PaymentInfo? paymentInfo; // Rendre nullable pour l'état scan
  final bool showOnlyInfo;

  const ScanPayPage({
    Key? key,
    this.paymentInfo, // Ne plus être required
    this.showOnlyInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: SafeArea(
        child: showOnlyInfo && paymentInfo != null
            ? _buildPaymentInfo(context) // Méthode pour afficher les infos de paiement
            : _buildQrScanner(context), // Méthode pour afficher le scanner
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    // Assurez-vous que paymentInfo n'est pas null ici
    if (paymentInfo == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bouton retour
          Text(
            'Détails de la facture',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Carte principale avec les détails
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
                // Logo ou icône ou QR Code
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

                // Informations de transaction
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

          // QR Code
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

          // Instructions de paiement
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
          const SizedBox(height: 32),

          // Bouton de paiement (affiché seulement si showOnlyInfo est faux)
          if (!showOnlyInfo)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logique de paiement à implémenter
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logique de paiement à implémenter ici'),
                      backgroundColor: Colors.brown,
                    ),
                  );
                  // Après un paiement réussi, vous pourriez vouloir:
                  // - Appeler un service de paiement
                  // - Mettre à jour l'état de la commande
                  // - Naviguer vers une page de confirmation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E342E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Payer maintenant',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQrScanner(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Barcode found! ${barcode.rawValue}');
                // TODO: Traiter le code QR scanné (ex: naviguer vers une page de confirmation avec les données)
                // Pour éviter de scanner en continu, vous pouvez arrêter le scanner
                // ou naviguer immédiatement.
                // Par exemple:
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(builder: (_) => ConfirmationPage(data: barcode.rawValue!)),
                // );
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

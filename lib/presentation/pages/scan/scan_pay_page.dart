import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Remove MobileScanner import
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../domain/viewmodels/auth_viewmodel.dart';
import '../../../services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
// import '../../../data/services/user_data_service.dart'; // UserDataService might not be needed here

// Import kDebugMode
import 'package:flutter/foundation.dart';
// import '../../user/user_home_page.dart'; // Already imported in CartPage, not needed here for navigation

class ScanPayPage extends StatefulWidget {
  final PaymentInfo? paymentInfo;
  // final bool showOnlyInfo; // Remove this

  const ScanPayPage({
    Key? key,
    this.paymentInfo,
    // this.showOnlyInfo = false, // Remove this
  }) : super(key: key);

  @override
  State<ScanPayPage> createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage> {
  Invoice? _latestInvoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestInvoice();
  }

  Future<void> _loadLatestInvoice() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthViewModel>().currentUser?.uid;
      if (userId != null) {
        final invoice = await InvoiceService().getLatestInvoice(userId);
        setState(() {
          _latestInvoice = invoice;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading latest invoice: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.paymentInfo != null
                ? _buildPaymentInfo(context)
                : _buildLatestInvoiceOrEmpty(context),
      ),
    );
  }

  Widget _buildLatestInvoiceOrEmpty(BuildContext context) {
    if (_latestInvoice == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.brown,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune facture en attente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre panier est vide',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.brown[300],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Retour',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Convertir Invoice en PaymentInfo pour réutiliser _buildPaymentInfo
    final paymentInfo = PaymentInfo(
      transactionId: _latestInvoice!.transactionId,
      total: _latestInvoice!.total,
      date: _latestInvoice!.date,
      time: _latestInvoice!.time,
      userId: _latestInvoice!.userId,
      invoiceId: _latestInvoice!.id,
      items: _latestInvoice!.items,
    );

    return _buildPaymentInfo(context, paymentInfo: paymentInfo);
  }

  Widget _buildPaymentInfo(BuildContext context, {PaymentInfo? paymentInfo}) {
    final info = paymentInfo ?? widget.paymentInfo!;
    final orderViewModel = context.read<OrderViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec bouton retour
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Détails de la facture',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                _buildInfoRow('Transaction ID', info.transactionId),
                _buildInfoRow('Date', info.date),
                _buildInfoRow('Heure', info.time),
                const Divider(height: 32),
                _buildInfoRow(
                  'Total',
                  '${info.total.toStringAsFixed(2)} €',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // QR Code
          Center(
            child: QrImageView(
              data: 'InvoiceID: ${info.invoiceId}\n'
                  'Transaction: ${info.transactionId}\n'
                  'Total: ${info.total.toStringAsFixed(2)} €',
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
                  'Instructions pour le caissier',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInstructionStep(
                  '1',
                  'Présentez ce code QR à la caisse',
                ),
                _buildInstructionStep(
                  '2',
                  'Le caissier scannera le code et confirmera le paiement',
                ),
                _buildInstructionStep(
                  '3',
                  'Votre commande sera alors marquée comme payée et votre panier sera vidé.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Button to simulate cashier confirmation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  // 1. Update invoice status
                  await InvoiceService().updateInvoiceStatus(info.invoiceId, 'paid');
                  
                  // 2. Clear the user's cart
                  orderViewModel.clearCart();
                  
                  // 3. Navigate back to user home
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/user_home');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paiement confirmé et panier vidé!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la confirmation du paiement: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8C6A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Confirmer le paiement (pour test)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Back button
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.brown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrScanner(BuildContext context) {
    // This method is no longer used for the user's flow
    return const Center(child: Text('QR Scanner functionality is disabled for users.'));
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

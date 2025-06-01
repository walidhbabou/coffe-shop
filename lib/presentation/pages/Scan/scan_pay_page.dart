import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../domain/viewmodels/auth_viewmodel.dart';
import '../../../services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
import 'package:flutter/foundation.dart';

class ScanPayPage extends StatefulWidget {
  final PaymentInfo? paymentInfo;

  const ScanPayPage({
    Key? key,
    this.paymentInfo,
  }) : super(key: key);

  @override
  State<ScanPayPage> createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage> with TickerProviderStateMixin {
  Invoice? _latestInvoice;
  bool _isLoading = true;
  String? _selectedPaymentMethod;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadLatestInvoice();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _animationController.forward();
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
            ? _buildLoadingState()
            : widget.paymentInfo != null
                ? _buildPaymentInfo(context)
                : _buildLatestInvoiceOrEmpty(context),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement de votre facture...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.brown[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestInvoiceOrEmpty(BuildContext context) {
    if (_latestInvoice == null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucune facture en attente',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre panier est vide',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.brown[400],
                  ),
                ),
                const SizedBox(height: 32),
                _buildStyledButton(
                  text: 'Retour',
                  color: Colors.brown,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête moderne avec gradient
              _buildHeader(),
              const SizedBox(height: 32),

              // Carte principale redesignée
              _buildMainCard(info),
              const SizedBox(height: 24),

              // QR Code avec design amélioré
              _buildQRCodeSection(info),
              const SizedBox(height: 24),

              // Instructions stylisées
              _buildInstructionsCard(),
              const SizedBox(height: 24),

              // Sélection de méthode de paiement moderne
              _buildPaymentMethodCard(context),
              const SizedBox(height: 24),

              // Boutons d'action modernisés
              _buildActionButtons(context, info, orderViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade600, Colors.brown.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Détails de la facture',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(PaymentInfo info) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Transaction ID', info.transactionId),
          const SizedBox(height: 12),
          _buildInfoRow('Date', info.date),
          const SizedBox(height: 12),
          _buildInfoRow('Heure', info.time),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.brown.withOpacity(0.1),
                  Colors.brown.withOpacity(0.3),
                  Colors.brown.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Total',
            '${info.total.toStringAsFixed(2)} €',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(PaymentInfo info) {
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

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade50, Colors.brown.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.brown.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Instructions pour le caissier',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInstructionStep('1', 'Présentez ce code QR à la caisse'),
          _buildInstructionStep('2', 'Le caissier scannera le code et confirmera le paiement'),
          _buildInstructionStep('3', 'Votre commande sera alors marquée comme payée et votre panier sera vidé'),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Méthode de paiement',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showPaymentMethodSelection(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPaymentMethod != null 
                      ? Colors.green 
                      : Colors.brown.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _selectedPaymentMethod != null 
                    ? Colors.green.shade50 
                    : Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedPaymentMethod != null 
                        ? Icons.check_circle 
                        : Icons.payment,
                    color: _selectedPaymentMethod != null 
                        ? Colors.green 
                        : Colors.brown,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPaymentMethod ?? 'Choisir une méthode de paiement',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedPaymentMethod != null 
                            ? Colors.green.shade700 
                            : Colors.brown.shade600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.brown.shade400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PaymentInfo info, OrderViewModel orderViewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _buildStyledButton(
            text: 'Confirmer le paiement',
            color: const Color(0xFF5B8C6A),
            isEnabled: _selectedPaymentMethod != null,
            onPressed: _selectedPaymentMethod == null ? null : () async {
              await _handlePaymentConfirmation(context, info, orderViewModel);
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildStyledButton(
            text: 'Annuler',
            color: Colors.red,
            isOutlined: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    bool isEnabled = true,
    bool isOutlined = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isEnabled && !isOutlined ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: color, width: 2),
              ),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled ? color : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Future<void> _handlePaymentConfirmation(BuildContext context, PaymentInfo info, OrderViewModel orderViewModel) async {
    try {
      if (_selectedPaymentMethod == null) {
        throw Exception('Veuillez sélectionner une méthode de paiement');
      }

      await InvoiceService().updateInvoiceStatus(
        info.invoiceId,
        'paid',
        paymentMethod: _selectedPaymentMethod,
      );
      
      orderViewModel.clearCart();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/user_home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Paiement confirmé et panier vidé!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur lors de la confirmation du paiement: $e',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.brown.shade700 : Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTotal ? 12 : 0,
            vertical: isTotal ? 6 : 0,
          ),
          decoration: isTotal ? BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.withOpacity(0.3)),
          ) : null,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.brown.shade700 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade600, Colors.brown.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.brown.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Choisir une méthode de paiement',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
              const SizedBox(height: 24),
              _buildPaymentOption(
                context,
                icon: Icons.credit_card,
                title: 'Paiement en ligne',
                subtitle: 'Carte bancaire, PayPal...',
                value: 'Online',
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                context,
                icon: Icons.payments,
                title: 'Espèces',
                subtitle: 'Paiement en liquide',
                value: 'Cash',
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.brown : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.brown.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.brown.shade700 : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.brown,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
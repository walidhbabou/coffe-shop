import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../domain/viewmodels/auth_viewmodel.dart';
import '../../../services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
import 'package:flutter/foundation.dart';
import '../../../data/services/user_data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/payment_option.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/instruction_step.dart';
import '../../widgets/payment_header.dart';
import '../../widgets/payment_info_card.dart';
import '../../widgets/qr_code_section.dart';

class ScanPayPage extends StatefulWidget {
  final PaymentInfo? paymentInfo;

  const ScanPayPage({
    Key? key,
    this.paymentInfo,
  }) : super(key: key);

  @override
  State<ScanPayPage> createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage>
    with TickerProviderStateMixin {
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
                StyledButton(
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

    // Debugging print statement
    debugPrint('ScanPayPage - PaymentInfo: ${info.toMap()}');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PaymentHeader(),
              const SizedBox(height: 32),
              PaymentInfoCard(info: info),
              const SizedBox(height: 24),
              QRCodeSection(info: info),
              const SizedBox(height: 24),
              _buildInstructionsCard(),
              const SizedBox(height: 24),
              _buildPaymentMethodCard(context),
              const SizedBox(height: 24),
              _buildActionButtons(context, info, orderViewModel),
            ],
          ),
        ),
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
          InstructionStep(
            number: '1',
            text: 'Présentez ce code QR à la caisse',
          ),
          InstructionStep(
            number: '2',
            text: 'Le caissier scannera le code et confirmera le paiement',
          ),
          InstructionStep(
            number: '3',
            text:
                'Votre commande sera alors marquée comme payée et votre panier sera vidé',
          ),
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
                      _selectedPaymentMethod ??
                          'Choisir une méthode de paiement',
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

  Widget _buildActionButtons(
      BuildContext context, PaymentInfo info, OrderViewModel orderViewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: StyledButton(
            text: 'Confirmer le paiement',
            color: const Color(0xFF5B8C6A),
            isEnabled: _selectedPaymentMethod != null,
            onPressed: _selectedPaymentMethod == null
                ? null
                : () async {
                    await _handlePaymentConfirmation(
                        context, info, orderViewModel);
                  },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: StyledButton(
            text: 'Annuler',
            color: Colors.red,
            isOutlined: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePaymentConfirmation(BuildContext context,
      PaymentInfo info, OrderViewModel orderViewModel) async {
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
              PaymentOption(
                icon: Icons.credit_card,
                title: 'Paiement en ligne',
                subtitle: 'Carte bancaire, PayPal...',
                isSelected: _selectedPaymentMethod == 'Online',
                onTap: () {
                  Navigator.pop(context);
                  _showOnlinePaymentOptions(context);
                },
              ),
              const SizedBox(height: 12),
              PaymentOption(
                icon: Icons.payments,
                title: 'Espèces',
                subtitle: 'Paiement en liquide',
                isSelected: _selectedPaymentMethod == 'Cash',
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = 'Cash';
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showOnlinePaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vos cartes de paiement',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/payment_methods');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: UserDataService.paymentMethodsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune carte enregistrée',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            StyledButton(
                              text: 'Ajouter une carte',
                              color: Colors.brown,
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                    context, '/payment_methods');
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final cards = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index].data();
                        return PaymentMethodCard(
                          card: card,
                          onDelete: () => _showDeleteConfirmationDialog(
                              context, cards[index].id),
                          onSelect: () {
                            setState(() {
                              _selectedPaymentMethod = 'Online';
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String paymentMethodId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Supprimer cette méthode de paiement',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette méthode de paiement?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.brown.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeletePaymentMethod(paymentMethodId);
              },
              child: Text(
                'Supprimer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeletePaymentMethod(String paymentMethodId) async {
    try {
      await UserDataService.deletePaymentMethod(paymentMethodId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Méthode de paiement supprimée avec succès!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Erreur lors de la suppression de la méthode de paiement: $e',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

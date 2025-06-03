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
import '../../widgets/payment_widgets.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/payment_info_card.dart';
import '../../widgets/qr_code_section.dart';
import '../../widgets/payment_option.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/instruction_step.dart';
import '../../widgets/payment_header.dart';

class ScanPayPage extends StatefulWidget {
  final PaymentInfo? paymentInfo;
  const ScanPayPage({Key? key, this.paymentInfo}) : super(key: key);

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

  // Constantes de style
  static const _backgroundColor = Color(0xFFF7F4EF);
  static const _primaryColor = Colors.brown;
  static const _successColor = Color(0xFF5B8C6A);
  
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
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
      debugPrint('Error loading latest invoice: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingContainer(),
          const SizedBox(height: 24),
          _buildText('Chargement de votre facture...', fontSize: 16, color: _primaryColor.shade600),
        ],
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return buildLoadingContainer(
      primaryColor: _primaryColor,
    );
  }

  Widget _buildContent() {
    return widget.paymentInfo != null
        ? _buildPaymentInfo(widget.paymentInfo!)
        : _buildLatestInvoiceOrEmpty();
  }

  Widget _buildLatestInvoiceOrEmpty() {
    if (_latestInvoice == null) return _buildEmptyState();
    
    final paymentInfo = PaymentInfo(
      transactionId: _latestInvoice!.transactionId,
      total: _latestInvoice!.total,
      date: _latestInvoice!.date,
      time: _latestInvoice!.time,
      userId: _latestInvoice!.userId,
      invoiceId: _latestInvoice!.id,
      items: _latestInvoice!.items,
    );
    return _buildPaymentInfo(paymentInfo);
  }

  Widget _buildEmptyState() {
    return _buildAnimatedContent(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(Icons.shopping_cart_outlined),
            const SizedBox(height: 24),
            _buildText('Aucune facture en attente', fontSize: 20, isBold: true),
            const SizedBox(height: 8),
            _buildText('Votre panier est vide', color: _primaryColor.shade400),
            const SizedBox(height: 32),
            StyledButton(
              text: 'Retour',
              color: _primaryColor,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(PaymentInfo info) {
    debugPrint('ScanPayPage - PaymentInfo: ${info.toMap()}');
    
    // Si le panier est vide, afficher un message et ne pas permettre le paiement
    if (info.items.isEmpty) {
      return _buildAnimatedContent(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconContainer(Icons.shopping_cart_outlined),
              const SizedBox(height: 24),
              _buildText('Panier vide', fontSize: 20, isBold: true),
              const SizedBox(height: 8),
              _buildText('Vous ne pouvez pas effectuer de paiement avec un panier vide', color: Colors.red),
              const SizedBox(height: 32),
              StyledButton(
                text: 'Retour',
                color: _primaryColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }
    
    return _buildAnimatedContent(
      SingleChildScrollView(
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
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),
            _buildActionButtons(info),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: child),
    );
  }

  Widget _buildIconContainer(IconData icon, {double size = 64}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildBoxDecoration(_primaryColor.shade50, isCircle: true, hasElevation: true),
      child: Icon(icon, size: size, color: _primaryColor),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildBoxDecoration(
        Colors.white,
        gradient: LinearGradient(
          colors: [_primaryColor.shade50, _primaryColor.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        hasBorder: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionHeader(),
          const SizedBox(height: 20),
          ...['Présentez ce code QR à la caisse',
             'Le caissier scannera le code et confirmera le paiement',
             'Votre commande sera alors marquée comme payée et votre panier sera vidé']
              .asMap().entries.map((entry) => 
                InstructionStep(number: '${entry.key + 1}', text: entry.value)),
        ],
      ),
    );
  }

  Widget _buildInstructionHeader() {
    return buildInstructionHeader(
      primaryColor: _primaryColor,
      title: 'Instructions pour le caissier',
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildBoxDecoration(Colors.white, hasElevation: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText('Méthode de paiement', fontSize: 18, isBold: true, color: _primaryColor.shade700),
          const SizedBox(height: 16),
          _buildPaymentMethodSelector(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return buildPaymentMethodSelector(
      selectedPaymentMethod: _selectedPaymentMethod,
      onTap: _showPaymentMethodSelection,
      primaryColor: _primaryColor,
    );
  }

  Widget _buildActionButtons(PaymentInfo info) {
    return Column(
      children: [
        StyledButton(
          text: 'Confirmer le paiement',
          color: _successColor,
          isEnabled: _selectedPaymentMethod != null,
          onPressed: _selectedPaymentMethod == null ? null : () => _processPayment(_selectedPaymentMethod!),
        ),
        const SizedBox(height: 16),
        StyledButton(
          text: 'Annuler',
          color: Colors.red,
          isOutlined: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // Méthodes utilitaires pour le style
  Widget _buildText(String text, {
    double fontSize = 16,
    Color? color,
    bool isBold = false,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return buildStyledText(
      text: text,
      primaryColor: _primaryColor,
      fontSize: fontSize,
      color: color,
      isBold: isBold,
      fontWeight: fontWeight,
    );
  }

  BoxDecoration _buildBoxDecoration(
    Color color, {
    Gradient? gradient,
    bool isCircle = false,
    bool hasElevation = false,
    bool hasBorder = false,
  }) {
    return buildBoxDecoration(
      color: color,
      gradient: gradient,
      isCircle: isCircle,
      hasElevation: hasElevation,
      hasBorder: hasBorder,
    );
  }

  // Méthodes pour les modales (simplifiées)
  Future<void> _processPayment(String paymentMethod) async {
    try {
      final invoiceService = InvoiceService();
      final orderViewModel = context.read<OrderViewModel>();

      final invoice = Invoice(
        id: widget.paymentInfo!.invoiceId,
        transactionId: widget.paymentInfo!.transactionId,
        total: widget.paymentInfo!.total,
        date: widget.paymentInfo!.date,
        time: widget.paymentInfo!.time,
        userId: widget.paymentInfo!.userId,
        items: widget.paymentInfo!.items,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final firestoreInvoiceId = await invoiceService.createInvoice(invoice);
      await invoiceService.updateInvoiceStatus(firestoreInvoiceId, 'paid', paymentMethod: paymentMethod);

      orderViewModel.clearCart();
      orderViewModel.unlockCart();

      if (mounted) {
        _showSnackBar('Paiement effectué avec succès !', Colors.green);
        Navigator.pushReplacementNamed(context, '/user_home');
      }
    } catch (e) {
      debugPrint('Error processing payment: $e');
      if (mounted) {
        _showSnackBar('Erreur lors du paiement: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showPaymentMethodSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildModalContent(
        'Choisir une méthode de paiement',
        Column(
          children: [
            PaymentOption(
              icon: Icons.credit_card,
              title: 'Paiement en ligne',
              subtitle: 'Carte bancaire, PayPal...',
              isSelected: _selectedPaymentMethod == 'Online',
              onTap: () {
                Navigator.pop(context);
                _showOnlinePaymentOptions();
              },
            ),
            const SizedBox(height: 12),
            PaymentOption(
              icon: Icons.payments,
              title: 'Espèces',
              subtitle: 'Paiement en liquide',
              isSelected: _selectedPaymentMethod == 'Cash',
              onTap: () {
                setState(() => _selectedPaymentMethod = 'Cash');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOnlinePaymentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildModalContent(
          'Vos cartes de paiement',
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: UserDataService.paymentMethodsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyCardsState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final card = snapshot.data!.docs[index];
                  return PaymentMethodCard(
                    card: card.data(),
                    onDelete: () => _showDeleteConfirmation(card.id),
                    onSelect: () {
                      setState(() => _selectedPaymentMethod = 'Online');
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
          hasAddButton: true,
        ),
      ),
    );
  }

  Widget _buildModalContent(String title, Widget content, {bool hasAddButton = false}) {
    return buildModalContent(
      title: title,
      content: content,
      primaryColor: _primaryColor,
      hasAddButton: hasAddButton,
      onAdd: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/payment_methods');
      },
    );
  }

  Widget _buildDeleteConfirmation(String paymentMethodId) {
    return buildDeleteConfirmation(
      context: context,
      primaryColor: _primaryColor,
      paymentMethodId: paymentMethodId,
      onDelete: () => _handleDeletePaymentMethod(paymentMethodId),
    );
  }

  Future<void> _handleDeletePaymentMethod(String paymentMethodId) async {
    try {
      await UserDataService.deletePaymentMethod(paymentMethodId);
      if (mounted) {
        _showSnackBar('Méthode de paiement supprimée avec succès!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de la suppression: $e', Colors.red);
      }
    }
  }

  Widget _buildEmptyCardsState() {
    return buildEmptyCardsState(
      primaryColor: _primaryColor,
      onAdd: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/payment_methods');
      },
    );
  }

  void _showDeleteConfirmation(String paymentMethodId) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmation(paymentMethodId),
    );
  }
}
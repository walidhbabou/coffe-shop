import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../data/models/drink.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'cart_page.dart';
import '../user/user_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
import '../../../domain/viewmodels/auth_viewmodel.dart';
import '../Scan/scan_pay_page.dart';

class CartPage extends StatefulWidget {
  final void Function(PaymentInfo)? onPay;
  const CartPage({Key? key, this.onPay}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String transactionId = 'V' + DateTime.now().millisecondsSinceEpoch.toString();
  String date = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    context.read<OrderViewModel>().unlockCart();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final total = orderViewModel.cartEntries.fold<double>(
        0, (sum, entry) => sum + (entry.key.price ?? 0) * entry.value);
    final isLocked = orderViewModel.isCartLocked;

    debugPrint('=== CartPage Debug Info ===');
    debugPrint('isCartLocked: ${orderViewModel.isCartLocked}');
    debugPrint('authViewModel.currentUser: ${authViewModel.currentUser}');
    debugPrint('authViewModel.isLoggedIn: ${authViewModel.isLoggedIn}');
    debugPrint('Firebase current user: ${FirebaseAuth.instance.currentUser}');
    debugPrint('Cart is empty: ${orderViewModel.cartEntries.isEmpty}');
    debugPrint('========================');

    return Scaffold(
      appBar: AppBar(
        title: Text('Votre Panier',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            orderViewModel.unlockCart();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: orderViewModel.cartEntries.isEmpty
                ? Center(
                    child: Text('Votre panier est vide',
                        style: GoogleFonts.poppins(fontSize: 18)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tracking order',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22)),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  _buildStep('Order has been received', 0),
                                  _buildStep('Prepare your order', 1),
                                  _buildStep(
                                      'Your order is complete!\nMeet us at the pickup area.',
                                      2,
                                      isLast: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ...orderViewModel.cartEntries.map((entry) {
                          final drink = entry.key;
                          final quantity = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: drink.imagePath.startsWith('http')
                                      ? Image.network(
                                          drink.imagePath,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(Icons.coffee_maker_outlined,
                                                  size: 60,
                                                  color: Colors.brown[300]),
                                        )
                                      : Image.asset(drink.imagePath,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(drink.name,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      if (drink.price != null)
                                        Text(
                                            '${drink.price!.toStringAsFixed(2)} €',
                                            style: GoogleFonts.poppins(
                                                color: Colors.brown,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.brown),
                                      onPressed: isLocked
                                          ? null
                                          : () => orderViewModel
                                              .removeFromCart(drink.id),
                                    ),
                                    Text('$quantity',
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: Colors.brown),
                                      onPressed: isLocked
                                          ? null
                                          : () => orderViewModel
                                              .addToCart(drink.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: isLocked
                                          ? null
                                          : () => orderViewModel
                                              .removeAllFromCart(drink.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        // Total
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                Text('${total.toStringAsFixed(2)} €',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          // Boutons de validation et paiement (uniquement si le panier n'est pas vide)
          if (!orderViewModel.cartEntries.isEmpty) ...[
            // Bouton de validation
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderViewModel.isCartLocked
                        ? Colors.grey
                        : orderViewModel.isFirstValidation
                            ? Colors.orange
                            : Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 6,
                  ),
                  onPressed: orderViewModel.isCartLocked
                      ? null
                      : () async {
                          if (orderViewModel.cartEntries.isNotEmpty) {
                            if (orderViewModel.isFirstValidation) {
                              await orderViewModel.finalValidation();
                            } else {
                              await orderViewModel.firstValidation();
                            }
                          }
                        },
                  child: Text(
                    orderViewModel.isCartLocked
                        ? 'Commande Validée'
                        : orderViewModel.isFirstValidation
                            ? 'Confirmer la Validation'
                            : 'Valider la Commande',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Bouton de paiement
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: orderViewModel.isCartLocked &&
                          orderViewModel.cartEntries.isNotEmpty
                      ? () {
                          // Vider le panier et le déverrouiller avant d'aller à la page de paiement
                          orderViewModel.addOrder(
                              total); // Cette méthode vide le panier et déverrouille isCartLocked

                          // Logique de paiement ici (appel de la fonction passée via widget.onPay)
                          if (widget.onPay != null) {
                            final items = orderViewModel.cartEntries
                                .map((entry) => {
                                      'id': entry.key.id,
                                      'name': entry.key.name,
                                      'price': entry.key.price,
                                      'quantity': entry.value,
                                    })
                                .toList();

                            final paymentInfo = PaymentInfo(
                              transactionId: transactionId,
                              total: total,
                              date: date,
                              time: time,
                              userId: authViewModel.currentUser?.uid ?? '',
                              invoiceId:
                                  'INV-${DateTime.now().millisecondsSinceEpoch}',
                              items: items,
                            );

                            widget.onPay!(paymentInfo);
                            
                            // Redirection vers la page de paiement
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanPayPage(
                                  paymentInfo: paymentInfo,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderViewModel.isCartLocked
                        ? Colors.green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Payer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(String text, int step, {bool isLast = false}) {
    final orderViewModel = context.watch<OrderViewModel>();

    bool isActive = false;
    bool isCompleted = false;

    if (step == 0) {
      // 'Order has been received' - always completed if cart is not empty
      isCompleted = !orderViewModel.cartEntries.isEmpty;
      isActive = !orderViewModel.cartEntries.isEmpty;
    } else if (step == 1) {
      // 'Prepare your order' - completed after first validation
      isCompleted =
          orderViewModel.isFirstValidation || orderViewModel.isCartLocked;
      isActive =
          orderViewModel.isFirstValidation || orderViewModel.isCartLocked;
    } else if (step == 2) {
      // 'Your order is complete!' - completed after final validation (cart locked)
      isCompleted = orderViewModel.isCartLocked;
      isActive = orderViewModel.isCartLocked;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? Colors.brown
                      : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.brown : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.only(left: 16),
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
        ],
      ),
    );
  }
}

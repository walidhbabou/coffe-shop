import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../data/models/drink.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_page.dart';
import '../../pages/profile/scan_pay_page.dart';
import '../../pages/profile/profile_home_page.dart';

class CartPage extends StatefulWidget {
  final void Function(PaymentInfo)? onPay;
  const CartPage({Key? key, this.onPay}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int orderStep = 0; // 0: modifiable, 1: validé, 2: prêt à payer
  bool isValidated = false;
  bool isPayEnabled = false;
  String transactionId = 'V278439380';
  String date = 'Nov 21 2023';
  String time = '03:04 PM';

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final total = orderViewModel.cartEntries.fold<double>(
        0, (sum, entry) => sum + (entry.key.price ?? 0) * entry.value);
    final isLocked = orderStep >= 2;
    // Date et heure actuelles formatées
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.brown, size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
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
                        // Suivi de commande
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
                        // Liste des produits du panier
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
                                      ? Image.network(drink.imagePath,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.18,
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          drink.imagePath,
                                          width:
                                              MediaQuery.of(context)
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
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.brown),
                                      onPressed: isLocked
                                          ? null
                                          : () {
                                              orderViewModel
                                                  .removeFromCart(drink);
                                            },
                                    ),
                                    Text('$quantity',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: Colors.brown),
                                      onPressed: isLocked
                                          ? null
                                          : () {
                                              orderViewModel.addToCart(drink);
                                            },
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
                                        fontSize: 20,
                                        color: Colors.brown)),
                              ],
                            ),
                          ),
                        ),
                        // Bouton Valider
                        ElevatedButton(
                          onPressed: isLocked
                              ? null
                              : () {
                                  setState(() {
                                    orderStep++;
                                    if (orderStep >= 2) {
                                      isPayEnabled = true;
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B8C6A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.7, 50),
                          ),
                          child: Text(
                            orderStep < 2 ? 'Valider' : 'Commande validée',
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Infos transaction
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Transaction ID',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                  Text(transactionId,
                                      style: GoogleFonts.poppins()),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                  Text(date, style: GoogleFonts.poppins()),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                  Text(time, style: GoogleFonts.poppins()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bouton Pay (remplace Review Receipt)
                        ElevatedButton(
                          onPressed: isPayEnabled
                              ? () {
                                  final snackBar = SnackBar(
                                    content: Text(
                                        'Paiement en cours...\nTransaction: $transactionId\nTotal: ${total.toStringAsFixed(2)} €\nDate: $formattedDate $formattedTime'),
                                    backgroundColor: Colors.brown,
                                    duration: const Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    orderViewModel.clearCart();
                                    if (widget.onPay != null) {
                                      widget.onPay!(PaymentInfo(
                                        transactionId: transactionId,
                                        total: total,
                                        date: formattedDate,
                                        time: formattedTime,
                                      ));
                                    }
                                    Navigator.of(context).pop();
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E342E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.7, 48),
                          ),
                          child: Text('Pay',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text, int step, {bool isLast = false}) {
    final isActive = orderStep >= step;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF5B8C6A) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isLast && isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 4,
                height: 36,
                color: isActive ? const Color(0xFF5B8C6A) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isActive ? const Color(0xFF222222) : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

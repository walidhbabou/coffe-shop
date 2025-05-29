import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../../data/models/drink.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import 'cart_page.dart';
// import '../Scan/scan_pay_page.dart'; // Removed for user flow
import '../user/user_home_page.dart';
// import 'payment_page.dart'; // Might not be needed for user flow anymore
// import '../scan/qr_transaction_page.dart'; // Might not be needed
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../../services/invoice_service.dart'; // Import InvoiceService
import '../../../data/models/invoice_model.dart'; // Import Invoice model
import '../../../domain/viewmodels/auth_viewmodel.dart'; // Import AuthViewModel

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
  String transactionId = 'V'+DateTime.now().millisecondsSinceEpoch.toString(); // Generate dynamic transaction ID
  String date = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final total = orderViewModel.cartEntries.fold<double>(
        0, (sum, entry) => sum + (entry.key.price ?? 0) * entry.value);
    final isLocked = orderStep >= 2;

    // Enhanced debugging (Optional - can be removed later)
    debugPrint('=== CartPage Debug Info ===');
    debugPrint('orderStep: $orderStep');
    debugPrint('isPayEnabled: $isPayEnabled');
    debugPrint('authViewModel.currentUser: ${authViewModel.currentUser}');
    debugPrint('authViewModel.isLoggedIn: ${authViewModel.isLoggedIn}');
    debugPrint('Firebase current user: ${FirebaseAuth.instance.currentUser}');
    debugPrint('Pay button enabled: ${isPayEnabled && authViewModel.isLoggedIn}');
    debugPrint('========================');

    return Scaffold(
      appBar: AppBar(
        title: Text('Votre Panier', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.coffee_maker_outlined, size: 60, color: Colors.brown[300]),
                                        )
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
                                const SizedBox(width: 12.0),
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
                                                  .removeFromCart(drink.id);
                                            },
                                    ),
                                    Text('$quantity',
                                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: Colors.brown),
                                      onPressed: isLocked
                                          ? null
                                          : () {
                                              orderViewModel
                                                  .addToCart(drink.id);
                                            },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        orderViewModel.removeAllFromCart(drink.id);
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
                        // Integration of provided Pay button enhancements and invoice saving logic
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 0), // Adjusted padding
                          child: Column(
                            children: [
                              // Debug info card (remove in production)
                              // if (kDebugMode) // kDebugMode requires import 'package:flutter/foundation.dart';
                              //   Card(
                              //     color: Colors.yellow[100],
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                              //           Text('Order Step: $orderStep'),
                              //           Text('Pay Enabled: $isPayEnabled'),
                              //           Text('User Logged In: ${authViewModel.isLoggedIn}'),
                              //           Text('Current User: ${authViewModel.currentUser?.email ?? 'null'}'),
                              //           Text('Button Should Be Enabled: ${isPayEnabled && authViewModel.isLoggedIn}'),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              const SizedBox(height: 16),

                              // Pay button with better feedback
                              ElevatedButton(
                                onPressed: (isPayEnabled && authViewModel.isLoggedIn)
                                    ? () async {
                                        // Your existing payment logic here
                                        // final paymentInfo = PaymentInfo(
                                        //   transactionId: transactionId,
                                        //   total: total,
                                        //   date: formattedDate,
                                        //   time: formattedTime,
                                        // );

                                        // Get current user ID
                                        final userId = authViewModel.currentUser?.uid;
                                        if (userId == null) {
                                           print('Error: User not logged in. Cannot save invoice.');
                                           // Show an error to the user
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             const SnackBar(
                                               content: Text('Veuillez vous connecter pour passer commande.'),
                                               backgroundColor: Colors.red,
                                             ),
                                           );
                                           return;
                                        }

                                        // Get cart items and total
                                        final cartItems = orderViewModel.cartEntries.map((entry) => {
                                          'drinkId': entry.key.id,
                                          'quantity': entry.value,
                                          'price': entry.key.price,
                                          'name': entry.key.name,
                                        }).toList();

                                        // Create Invoice object
                                        final invoice = Invoice(
                                          userId: userId,
                                          transactionId: transactionId, // Use the generated transactionId
                                          total: total,
                                          date: date, // Use the formatted date
                                          time: time, // Use the formatted time
                                          items: cartItems,
                                          createdAt: DateTime.now(),
                                          status: 'pending', // Set initial status
                                        );

                                        try {
                                          // Save invoice to Firestore
                                          final invoiceId = await InvoiceService().createInvoice(invoice);
                                          print('Invoice saved with ID: $invoiceId');

                                          // Create PaymentInfo object to pass to ScanPayPage
                                          final paymentInfo = PaymentInfo(
                                             transactionId: transactionId,
                                             total: total,
                                             date: date,
                                             time: time,
                                             userId: userId, // Pass userId
                                             invoiceId: invoiceId, // Pass the created invoice ID
                                             items: cartItems, // Pass cart items
                                          );

                                          // Navigate to ScanPayPage, passing paymentInfo
                                          Navigator.of(context).pushNamed('/scan_pay', arguments: paymentInfo);

                                        } catch (e) {
                                           print('Error saving invoice: $e');
                                           // Show an error to the user
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                               content: Text('Erreur lors de l\'enregistrement de la facture: ${e.toString()}'),
                                               backgroundColor: Colors.red,
                                             ),
                                           );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E342E),
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 48), // Adjusted size
                                ),
                                child: Text(
                                  _getPayButtonText(authViewModel.isLoggedIn, isPayEnabled, orderViewModel.cartEntries.isNotEmpty), // Pass cart empty state
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: (isPayEnabled && authViewModel.isLoggedIn) ? Colors.white : Colors.grey[600],
                                  ),
                                ),
                              ),

                              // Login prompt if not logged in
                              if (!authViewModel.isLoggedIn)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigate to login page
                                      // Use pushNamed to keep CartPage in stack, or pushReplacementNamed if desired
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      'Se connecter pour payer',
                                      style: GoogleFonts.poppins(
                                        color: Colors.brown,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

   String _getPayButtonText(bool isLoggedIn, bool isPayEnabled, bool isCartEmpty) {
    if (isCartEmpty) {
      return 'Payer facture';
    }
    if (!isLoggedIn) {
      return 'Connectez-vous pour payer';
    }
    if (!isPayEnabled) {
      return 'Validez votre commande d\'abord';
    }
    return 'Payer';
  }
}

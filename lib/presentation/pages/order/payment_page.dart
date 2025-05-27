import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../widgets/drink_card.dart';
import '../scan/scan_pay_page.dart';
import 'dart:math';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  String _generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TRX${timestamp}${random.nextInt(1000)}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final cartEntries = orderViewModel.cartEntries;
    final total = cartEntries.fold<double>(
      0, (sum, entry) => sum + (entry.key.price ?? 0) * entry.value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartEntries.length,
                itemBuilder: (context, index) {
                  final entry = cartEntries[index];
                  final drink = entry.key;
                  final quantity = entry.value;
                  return Card(
                    child: ListTile(
                      leading: Hero(
                        tag: 'product-${drink.name}-image',
                        child: drink.imagePath.startsWith('http')
                            ? Image.network(drink.imagePath, width: 48, height: 48, fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                    size: 40,
                                  );
                                },
                              )
                            : Image.asset(drink.imagePath, width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      title: Text(drink.name),
                      subtitle: Text('${drink.price?.toStringAsFixed(0) ?? ''} x $quantity'),
                      trailing: Text('${(drink.price ?? 0) * quantity}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text('Méthode de paiement'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Cash', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  final transactionId = _generateTransactionId();
                  final date = _getCurrentDate();
                  final time = _getCurrentTime();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScanPayPage(
                        transactionId: transactionId,
                        total: total,
                        date: date,
                        time: time,
                        showOnlyInfo: false,
                      ),
                    ),
                  );
                },
                child: const Text('Payer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
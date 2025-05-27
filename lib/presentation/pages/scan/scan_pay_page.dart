import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';

class ScanPayPage extends StatelessWidget {
  final String transactionId;
  final double total;
  final String date;
  final String time;
  final bool showOnlyInfo;
  
  const ScanPayPage({
    Key? key,
    this.transactionId = 'DEMO',
    this.total = 0.0,
    this.date = '2024-01-01',
    this.time = '00:00',
    this.showOnlyInfo = false,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    // Implement navigation logic based on index
    // This is a placeholder, you'll need to replace with your actual navigation
    switch (index) {
      case 0:
        // Navigate to Profile
        // Navigator.pushReplacementNamed(context, '/profile');
        Navigator.pop(context); // Placeholder
        break;
      case 1:
        // Already on Scan/Pay
        break;
      case 2:
        // Navigate to Order
        // Navigator.pushReplacementNamed(context, '/order');
        Navigator.pop(context); // Placeholder
        break;
      case 3:
        // Navigate to Account
        // Navigator.pushReplacementNamed(context, '/account');
        Navigator.pop(context); // Placeholder
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final cartEntries = orderViewModel.cartEntries;
    final calculatedTotal = cartEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
    );
    final qrData =
        'Transaction: $transactionId | Date: $date | Heure: $time | Commande: ${cartEntries.map((e) => "${e.key.name} x${e.value}").join(", ")} | Total: $calculatedTotal';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement par QR'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.brown),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Transaction ID: $transactionId',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: $date',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Heure: $time',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (!showOnlyInfo) ...[
                        const SizedBox(height: 16),
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!showOnlyInfo) ...[
                const SizedBox(height: 24),
                const Text(
                  'Détails de la commande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...cartEntries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Hero(
                        tag: 'product-${entry.key.name}-image', // Using name for tag
                        child: entry.key.imagePath.startsWith('http')
                            ? Image.network(
                                entry.key.imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
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
                                    Icons.fastfood, // More appropriate icon
                                    color: Colors.grey,
                                    size: 40,
                                  );
                                },
                              )
                            : Image.asset(
                                entry.key.imagePath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(entry.key.name),
                      subtitle: Text(
                          '${entry.key.price?.toStringAsFixed(0) ?? ""} x ${entry.value}'),
                      trailing: Text('${(entry.key.price ?? 0) * entry.value}'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Méthode de paiement',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('Cash'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${calculatedTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Retour',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: _selectedIndex, // You'll need to manage this state if ScanPayPage becomes stateful
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan/Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        selectedItemColor: Colors.brown, // Example styling
        unselectedItemColor: Colors.grey, // Example styling
      ),
    );
  }
}
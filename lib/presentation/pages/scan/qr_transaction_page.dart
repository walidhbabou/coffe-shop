import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';

class QrTransactionPage extends StatelessWidget {
  const QrTransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final cartEntries = orderViewModel.cartEntries;
    final total = cartEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
    );
    final qrData =
        'Commande: ${cartEntries.map((e) => "${e.key.name} x${e.value}").join(", ")} | Total: $total';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Transaction'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detail Commande',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...cartEntries.map(
              (entry) => Card(
                child: ListTile(
                  leading: entry.key.imagePath.startsWith('http')
                      ? Image.network(
                          entry.key.imagePath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          entry.key.imagePath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                  title: Text(entry.key.name),
                  subtitle:
                      Text('${entry.key.price?.toStringAsFixed(0) ?? ""} x ${entry.value}'),
                  trailing: Text('${(entry.key.price ?? 0) * entry.value}'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Récapitulatif du paiement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Méthode de paiement'),
              trailing: const Text('Cash'),
            ),
            ListTile(
              title: const Text('Total'),
              trailing: Text('${total.toStringAsFixed(0)}'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Retour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
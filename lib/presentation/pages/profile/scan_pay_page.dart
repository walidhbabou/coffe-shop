import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPayPage extends StatefulWidget {
  const ScanPayPage({Key? key}) : super(key: key);

  @override
  State<ScanPayPage> createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan & Pay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          debugPrint('Barcode found! ${barcode.rawValue}');
                          // Traiter les données du QR code ici
                          _showQRResult(context, barcode.rawValue ?? 'Aucune donnée');
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.start();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Scanner QR Code',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Pay Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            icon: Icons.credit_card,
            title: 'Pay with Card',
            subtitle: 'Use your saved cards',
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            icon: Icons.account_balance_wallet,
            title: 'Coffee Shop Wallet',
            subtitle: 'Balance: \$25.50',
            isWallet: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            icon: Icons.phone_android,
            title: 'Mobile Payment',
            subtitle: 'Apple Pay, Google Pay',
          ),
        ],
      ),
    );
  }

  void _showQRResult(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résultat du scan'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isWallet = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWallet ? Colors.brown : Colors.grey[300]!,
          width: isWallet ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isWallet ? Colors.brown.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isWallet ? Colors.brown : Colors.grey[700],
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }
}

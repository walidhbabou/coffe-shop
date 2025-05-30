import 'package:flutter/material.dart';
import '../../../data/models/payment_info.dart';

class ScanPayPage extends StatefulWidget {
  final PaymentInfo paymentInfo;

  const ScanPayPage({
    Key? key,
    required this.paymentInfo,
  }) : super(key: key);

  @override
  State<ScanPayPage> createState() => _ScanPayPageState();
}

class _ScanPayPageState extends State<ScanPayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Transaction ID: ${widget.paymentInfo.transactionId}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${widget.paymentInfo.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Date: ${widget.paymentInfo.date}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Time: ${widget.paymentInfo.time}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

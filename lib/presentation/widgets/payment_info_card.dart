import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/payment_info.dart';

class PaymentInfoCard extends StatelessWidget {
  final PaymentInfo info;

  const PaymentInfoCard({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _buildInfoRow('Transaction ID', info.transactionId),
          const SizedBox(height: 12),
          _buildInfoRow('Date', info.date),
          const SizedBox(height: 12),
          _buildInfoRow('Heure', info.time),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.brown.withOpacity(0.1),
                  Colors.brown.withOpacity(0.3),
                  Colors.brown.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Total',
            '${info.total.toStringAsFixed(2)} €',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.brown.shade700 : Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTotal ? 12 : 0,
            vertical: isTotal ? 6 : 0,
          ),
          decoration: isTotal ? BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.withOpacity(0.3)),
          ) : null,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.brown.shade700 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
} 
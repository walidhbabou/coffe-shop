import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';

class AdminWelcomePage extends StatelessWidget {
  const AdminWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi Admin',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8D6E63), // Brown 700
              Color(0xFFD7CCC8), // Brown 100
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMenuCard(
                      context,
                      'Scanner QR',
                      Icons.qr_code_scanner,
                      Colors.blue[700]!, // Blue
                      () => Navigator.pushNamed(context, AppRoutes.scanPay),
                    ),
                    _buildMenuCard(
                      context,
                      'Historique des factures',
                      Icons.history,
                      Colors.green[700]!, // Green
                      () => Navigator.pushNamed(
                          context, AppRoutes.invoiceHistory),
                    ),
                    _buildMenuCard(
                      context,
                      'Gérer les commandes',
                      Icons.shopping_cart,
                      Colors.orange[700]!, // Orange
                      () => Navigator.pushNamed(context, AppRoutes.order),
                    ),
                    _buildMenuCard(
                      context,
                      'Paramètres',
                      Icons.settings,
                      Colors.purple[700]!, // Purple
                      () => Navigator.pushNamed(context, AppRoutes.account),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, // Used for icon color
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4, // Reduced elevation for a lighter feel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Slightly less rounded
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12), // Reduced padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white, // White background
            border: Border.all(color: Colors.grey[200]!), // Lighter border
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36, // Reduced icon size
                color: color, // Use the passed color for the icon
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.w500, // Slightly lighter font weight
                  color: Colors.grey[700], // Dark grey text
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

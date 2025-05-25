import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/viewmodels/order_viewmodel.dart';
import '../../data/models/drink.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<OrderViewModel>().cart;
    final total = cart.fold<double>(0, (sum, item) => sum + (item.price ?? 0));
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier', style: GoogleFonts.poppins()),
        backgroundColor: Colors.brown.shade100,
        iconTheme: const IconThemeData(color: Color(0xFF4E342E)),
        elevation: 0,
      ),
      body: cart.isEmpty
          ? Center(
              child: Text('Votre panier est vide', style: GoogleFonts.poppins(fontSize: 18)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == cart.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${total.toStringAsFixed(2)} €', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                      ],
                    ),
                  );
                }
                final Drink drink = cart[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: drink.imagePath.startsWith('http')
                          ? Image.network(drink.imagePath, width: 48, height: 48, fit: BoxFit.cover)
                          : Image.asset(drink.imagePath, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text(drink.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: drink.price != null ? Text('${drink.price!.toStringAsFixed(2)} €', style: GoogleFonts.poppins(color: Colors.brown)) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        context.read<OrderViewModel>().cart.removeAt(index);
                        context.read<OrderViewModel>().notifyListeners();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

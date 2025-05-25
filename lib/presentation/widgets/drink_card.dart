import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/models/drink.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';

class DrinkCard extends StatefulWidget {
  final Drink drink;
  const DrinkCard({Key? key, required this.drink}) : super(key: key);

  @override
  State<DrinkCard> createState() => _DrinkCardState();
}

class _DrinkCardState extends State<DrinkCard> {
  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final cartCount = orderViewModel.cart[widget.drink.id] ?? 0;
    final isWide = MediaQuery.of(context).size.width > 600;
    final isFavorite = orderViewModel.isFavorite(widget.drink);
    return Container(
      constraints: const BoxConstraints(
        minHeight: 300,
        maxHeight: 450,
        minWidth: 240,
        maxWidth: 600,
      ),
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: widget.drink.imagePath.startsWith('http')
                      ? Image.network(widget.drink.imagePath,
                          height: 130, width: 130, fit: BoxFit.cover)
                      : Image.asset(widget.drink.imagePath,
                          height: 130, width: 130, fit: BoxFit.cover),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.drink.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isWide ? 34 : 28,
                    color: const Color(0xFF4E342E),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.drink.price != null)
                  Text(
                    '${widget.drink.price!.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontWeight: FontWeight.w600,
                      fontSize: isWide ? 24 : 20,
                    ),
                  ),
                if (widget.drink.description != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(
                      widget.drink.description!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: isWide ? 20 : 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: isWide ? 220 : double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 28),
                    label: Text(
                      cartCount > 0 ? 'x$cartCount' : 'Ajouter',
                      style: TextStyle(
                          fontSize: isWide ? 22 : 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 6,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Provider.of<OrderViewModel>(context, listen: false)
                          .addToCart(widget.drink);
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 28,
              ),
              onPressed: () {
                final orderViewModel =
                    Provider.of<OrderViewModel>(context, listen: false);
                if (isFavorite) {
                  orderViewModel.removeFavorite(widget.drink);
                } else {
                  orderViewModel.addFavorite(widget.drink);
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

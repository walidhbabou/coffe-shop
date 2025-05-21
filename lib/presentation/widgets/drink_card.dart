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
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialise l'état isFavorite en fonction du ViewModel
    isFavorite = Provider.of<OrderViewModel>(context, listen: false).isFavorite(widget.drink);
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les changements du ViewModel pour mettre à jour l'icône de favori
    isFavorite = Provider.of<OrderViewModel>(context).isFavorite(widget.drink);

    return Container(
      constraints: const BoxConstraints(
        minHeight: 220,
        maxHeight: 280,
        minWidth: 160,
        maxWidth: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.drink.imagePath,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error_outline, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.brown,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.drink.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ),
                if (widget.drink.price != null)
                  Text(
                    '${widget.drink.price!.toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Color(0xFF8B5E3C),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (widget.drink.description != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                      child: Text(
                        widget.drink.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ajouté au panier'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 20,
              ),
              onPressed: () {
                // Utilise le Provider pour accéder au OrderViewModel et ajouter/retirer des favoris
                final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
                if (isFavorite) {
                  orderViewModel.removeFavorite(widget.drink);
                } else {
                  orderViewModel.addFavorite(widget.drink);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

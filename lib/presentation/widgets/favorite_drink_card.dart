import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/drink.dart';

class FavoriteDrinkCard extends StatelessWidget {
  final Drink drink;
  const FavoriteDrinkCard({Key? key, required this.drink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  drink.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 80,
                      width: double.infinity,
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
            ),
            const SizedBox(height: 16),
            Text(
              drink.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF4E342E),
                ),
              ),
            ),
            if (drink.price != null)
              Text(
                '${drink.price!.toStringAsFixed(2)} €',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xFF8B5E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            if (drink.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                child: Text(
                  drink.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, color: Colors.red[400], size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

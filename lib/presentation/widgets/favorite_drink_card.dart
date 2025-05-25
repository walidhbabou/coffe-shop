import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/drink.dart';

class FavoriteDrinkCard extends StatelessWidget {
  final Drink drink;
  const FavoriteDrinkCard({Key? key, required this.drink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 160,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: drink.imagePath.startsWith('http')
                  ? Image.network(drink.imagePath, height: 70, width: 70, fit: BoxFit.cover)
                  : Image.asset(drink.imagePath, height: 70, width: 70, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(
              drink.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF4E342E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

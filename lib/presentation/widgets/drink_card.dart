import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/drink.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;
  const DrinkCard({Key? key, required this.drink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
          minHeight: 180, maxHeight: 240, minWidth: 140, maxWidth: 220),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: drink.imagePath.startsWith('http')
                  ? Image.network(drink.imagePath,
                      height: 90, width: 90, fit: BoxFit.cover)
                  : Image.asset(drink.imagePath,
                      height: 90, width: 90, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                child: Text(
                  drink.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

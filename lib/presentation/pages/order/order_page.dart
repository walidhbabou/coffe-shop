import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/viewmodels/order_viewmodel.dart';
import '../../widgets/drink_card.dart';
import '../../widgets/favorite_drink_card.dart';
import '../order/cart_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool showAllDrinks = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.error != null) {
          return Center(child: Text('Erreur: ' + viewModel.error!));
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF7F2EC),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF1E6D1), Color(0xFFE6D3BA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Your favorites',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Your most loved drinks',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.brown[300]),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return FavoriteDrinkCard(
                            drink: viewModel.favorites[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Drinks',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF4E342E),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.brown.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                          ),
                          onPressed: () {
                            setState(() {
                              showAllDrinks = !showAllDrinks;
                            });
                          },
                          child: Text(
                            showAllDrinks ? 'Show less' : 'See all',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5E3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Choose from our best-selling and newest drinks',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.brown[300]),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: GridView.count(
                      key: ValueKey(showAllDrinks),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                      children: (viewModel.drinks.length > 8 && !showAllDrinks)
                          ? viewModel.drinks
                              .take(8)
                              .map((drink) => DrinkCard(drink: drink))
                              .toList()
                          : viewModel.drinks
                              .map((drink) => DrinkCard(drink: drink))
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.brown,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                if (viewModel.cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        viewModel.cart.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

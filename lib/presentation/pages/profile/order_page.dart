import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.brown,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              tabs: [
                Tab(text: 'Menu'),
                Tab(text: 'Order History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMenuTab(),
                _buildOrderHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection('Hot Coffee', [
            _MenuItem(
              name: 'Caffè Americano',
              price: '3.95',
              description: 'Espresso shots topped with hot water',
              image: 'assets/images/americano.png',
            ),
            _MenuItem(
              name: 'Cappuccino',
              price: '4.25',
              description: 'Espresso with steamed milk foam',
              image: 'assets/images/cappuccino.png',
            ),
          ]),
          const SizedBox(height: 24),
          _buildCategorySection('Cold Coffee', [
            _MenuItem(
              name: 'Iced Coffee',
              price: '3.75',
              description: 'Freshly brewed coffee served chilled',
              image: 'assets/images/iced_coffee.png',
            ),
            _MenuItem(
              name: 'Cold Brew',
              price: '4.45',
              description: 'Slow-steeped, super-smooth coffee',
              image: 'assets/images/cold_brew.png',
            ),
          ]),
          const SizedBox(height: 24),
          _buildCategorySection('Frappuccino', [
            _MenuItem(
              name: 'Mocha Frappuccino',
              price: '5.45',
              description: 'Coffee, mocha sauce, and whipped cream',
              image: 'assets/images/mocha_frapp.png',
            ),
            _MenuItem(
              name: 'Caramel Frappuccino',
              price: '5.45',
              description: 'Coffee, caramel syrup, and whipped cream',
              image: 'assets/images/caramel_frapp.png',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${1000 + index}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${(15.99 + index).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'March ${20 - index}, 2024',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1x Caffè Americano\n1x Chocolate Croissant',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Reorder',
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(item.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${item.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                                fontSize: 16,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('Add to Cart'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MenuItem {
  final String name;
  final String price;
  final String description;
  final String image;

  const _MenuItem({
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'scan_pay_page.dart';
import '../../pages/order/order_page.dart' as order;
import 'account_page.dart';
import 'package:coffee_shop/domain/viewmodels/order_viewmodel.dart';
import '../../pages/order/cart_page.dart';
import '../../widgets/favorite_drink_card.dart';
import '../../../data/models/payment_info.dart';

class ProfileHomePage extends StatefulWidget {
  final PaymentInfo? pendingPaymentInfo;
  const ProfileHomePage({Key? key, this.pendingPaymentInfo}) : super(key: key);

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  int _selectedIndex = 0;
  PaymentInfo? _pendingPaymentInfo;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _pendingPaymentInfo = widget.pendingPaymentInfo;
    if (_pendingPaymentInfo != null) {
      _selectedIndex = 1; // Aller directement à ScanPayPage
    }
  }

  void showPaymentInfo(PaymentInfo info) {
    setState(() {
      _pendingPaymentInfo = info;
      _selectedIndex = 1; // ScanPayPage
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    if (authViewModel.currentUser == null && !_isLoggingOut) {
      _isLoggingOut = true;
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
    }
    final favorites = orderViewModel.favorites;
    final List<Widget> _pages = [
      _HomeContent(),
      ScanPayPage(
        paymentInfo: PaymentInfo(
          transactionId: _pendingPaymentInfo?.transactionId ?? 'DEMO',
          total: _pendingPaymentInfo?.total ?? 0.0,
          date: _pendingPaymentInfo?.date ?? '2024-01-01',
          time: _pendingPaymentInfo?.time ?? '00:00',
        ),
        showOnlyInfo: _pendingPaymentInfo != null,
      ),
      const order.OrderPage(),
      const AccountPage(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex ==
              0) // Affiche le bouton seulement sur l'accueil du profil
            Positioned(
              top: 36,
              right: 24,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.brown, size: 28),
                tooltip: 'Déconnexion',
                onPressed: () async {
                  await context.read<AuthViewModel>().signOut();
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CartPage(onPay: showPaymentInfo)),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            if (orderViewModel.cart.isNotEmpty)
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
                    orderViewModel.cart.length.toString(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index != 1) _pendingPaymentInfo = null;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.black38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan / Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final orderViewModel = context.watch<OrderViewModel>();
    final favorites = orderViewModel.favorites;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const NetworkImage(
                          'https://randomuser.me/api/portraits/men/32.jpg'),
                  backgroundColor: Colors.brown.shade100,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $userName!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back to Coffee Shop ☕',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 32),
          const Text(
            'Your favorites',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: favorites.isEmpty
                ? const Center(child: Text('No favorites yet'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final drink = favorites[index];
                      final cartCount = orderViewModel.cart[drink.id] ?? 0;
                      final isWide = MediaQuery.of(context).size.width > 400;
                      return Container(
                        width: isWide ? 150 : 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: drink.imagePath.startsWith('http')
                                  ? Image.network(drink.imagePath,
                                      height: 60, width: 60, fit: BoxFit.cover)
                                  : Image.asset(drink.imagePath,
                                      height: 60, width: 60, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              drink.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF4E342E),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (drink.price != null)
                              Text(
                                '${drink.price!.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  color: Colors.brown[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            const Spacer(),
                            SizedBox(
                              width: isWide ? 110 : 38,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 3,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  orderViewModel.addToCart(drink.id);
                                },
                                child: isWide
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 16,
                                              color: Colors.white),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              cartCount > 0
                                                  ? 'x$cartCount'
                                                  : 'Ajouter',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 18,
                                              color: Colors.white),
                                          if (cartCount > 0)
                                            Positioned(
                                              right: 2,
                                              top: 2,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'x$cartCount',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

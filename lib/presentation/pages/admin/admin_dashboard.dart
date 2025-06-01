import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_shop/presentation/widgets/admin/stat_card.dart';
import 'package:coffee_shop/presentation/widgets/admin/action_button.dart';
import 'package:coffee_shop/presentation/widgets/admin/header.dart';
import 'package:coffee_shop/presentation/pages/admin/admin_products_page.dart';
import 'package:coffee_shop/presentation/pages/admin/admin_users_page.dart';
import 'package:coffee_shop/presentation/pages/auth/login_page.dart';
import 'package:coffee_shop/presentation/pages/admin/admin_invoices_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminHeader(
                title: 'Tableau de Bord',
                subtitle: 'Bienvenue dans votre espace administrateur',
                onLogout: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Une erreur est survenue'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final orders = snapshot.data!.docs;
                        final totalRevenue = orders.fold<double>(
                          0,
                          (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return sum + (data['total'] as num).toDouble();
                          },
                        );

                        // Calculer les statistiques pour aujourd'hui
                        final now = DateTime.now();
                        final todayOrders = orders.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = (data['timestamp'] as Timestamp).toDate();
                          return timestamp.year == now.year &&
                              timestamp.month == now.month &&
                              timestamp.day == now.day;
                        }).toList();

                        final todayRevenue = todayOrders.fold<double>(
                          0,
                          (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return sum + (data['total'] as num).toDouble();
                          },
                        );

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            StatCard(
                              title: 'Commandes',
                              value: orders.length.toString(),
                              icon: Icons.shopping_cart_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              backgroundColor: const Color(0xFFEFF6FF),
                              trend: '${todayOrders.length} aujourd\'hui',
                              onTap: () {},
                            ),
                            StatCard(
                              title: 'Revenus Totaux',
                              value: '${totalRevenue.toStringAsFixed(2)} €',
                              icon: Icons.euro_rounded,
                              iconColor: const Color(0xFF10B981),
                              backgroundColor: const Color(0xFFECFDF5),
                              trend: '${todayRevenue.toStringAsFixed(2)} € aujourd\'hui',
                              onTap: () {},
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Actions Rapides',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      title: 'Gérer les Produits',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminProductsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      title: 'Gérer les Utilisateurs',
                      icon: Icons.people_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminUsersPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      title: 'Gérer les Factures',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminInvoicesPage(),
                          ),
                        );
                      },
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
}
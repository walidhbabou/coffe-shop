import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'package:coffee_shop/presentation/pages/profile/personal_info_page.dart';
import 'package:coffee_shop/presentation/pages/profile/payment_methods_page.dart';
import 'package:coffee_shop/presentation/pages/profile/addresses_page.dart';
import 'package:coffee_shop/presentation/pages/profile/notifications_page.dart';
import 'package:coffee_shop/presentation/pages/profile/rewards_page.dart';
import 'package:coffee_shop/presentation/pages/profile/about_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'Utilisateur';
    final userEmail = user?.email ?? 'Non connecté';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileCard(userName, userEmail, user?.photoURL),
          const SizedBox(height: 24),
          _buildSectionTitle('Paramètres du compte'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Informations personnelles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalInfoPage(),
                ),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.payment,
            title: 'Méthodes de paiement',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.location_on_outlined,
            title: 'Adresses',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressesPage()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Récompenses & Avantages'),
          _buildSettingItem(
            icon: Icons.star_border,
            title: 'Étoiles & Récompenses',
            subtitle: '150 étoiles disponibles',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardsPage()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.card_giftcard,
            title: 'Cartes cadeaux',
            onTap: () {
              // TODO: Naviguer vers la page des cartes cadeaux
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('À propos'),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'À propos de Coffee Shop',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            onTap: () {
              // TODO: Naviguer vers le centre d'aide
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            onTap: () {
              // TODO: Naviguer vers la politique de confidentialité
            },
          ),
          const SizedBox(height: 24),
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            onTap: () async {
              await authViewModel.signOut(context);
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String userName, String userEmail, String? photoURL) {
    return Container(
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
          CircleAvatar(
            radius: 40,
            backgroundImage: photoURL != null
                ? NetworkImage(photoURL)
                : null,
            backgroundColor: Colors.brown.shade100,
            child: photoURL == null
                ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Membre Gold',
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Naviguer vers la page d'édition du profil
            },
            color: Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.brown,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

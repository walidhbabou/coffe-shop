import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop/domain/viewmodels/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authViewModel.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations de l'admin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, ${authViewModel.currentUser?.email ?? "Admin"}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dernière connexion: ${authViewModel.userData?['lastLogin'] != null ? DateTime.fromMillisecondsSinceEpoch(authViewModel.userData!['lastLogin'].millisecondsSinceEpoch).toString() : "N/A"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Statistiques
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  'Utilisateurs',
                  Icons.people,
                  Colors.blue,
                  () => _showUsersList(context),
                ),
                _buildStatCard(
                  context,
                  'Commandes',
                  Icons.shopping_cart,
                  Colors.green,
                  () => _showOrdersList(context),
                ),
                _buildStatCard(
                  context,
                  'Produits',
                  Icons.coffee,
                  Colors.brown,
                  () => _showProductsList(context),
                ),
                _buildStatCard(
                  context,
                  'Rapports',
                  Icons.bar_chart,
                  Colors.purple,
                  () => _showReports(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUsersList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liste des utilisateurs'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Une erreur est survenue');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data!.docs[index];
                  final data = user.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['email'] ?? 'N/A'),
                    subtitle: Text('Rôle: ${data['role'] ?? 'user'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUser(context, user.id, data),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showOrdersList(BuildContext context) {
    // TODO: Implémenter la liste des commandes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showProductsList(BuildContext context) {
    // TODO: Implémenter la liste des produits
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showReports(BuildContext context) {
    // TODO: Implémenter les rapports
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _editUser(BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${userData['email']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: userData['role'] ?? 'user',
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'role': value});
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
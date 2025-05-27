import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos de Coffee Shop'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Notre histoire'),
          const SizedBox(height: 16),
          _buildStoryCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Nos valeurs'),
          const SizedBox(height: 16),
          _buildValueCard(
            icon: Icons.coffee,
            title: 'Qualité',
            description:
                'Nous sélectionnons les meilleurs grains de café pour vous offrir une expérience unique.',
          ),
          _buildValueCard(
            icon: Icons.eco,
            title: 'Durabilité',
            description:
                'Nous nous engageons à utiliser des pratiques durables et éthiques dans toute notre chaîne d\'approvisionnement.',
          ),
          _buildValueCard(
            icon: Icons.people,
            title: 'Communauté',
            description:
                'Nous créons des espaces accueillants où les gens peuvent se connecter et partager des moments.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Nos cafés'),
          const SizedBox(height: 16),
          _buildLocationCard(
            name: 'Coffee Shop Paris',
            address: '123 Rue du Café, 75001 Paris',
            hours: 'Lun-Dim: 7h-20h',
          ),
          _buildLocationCard(
            name: 'Coffee Shop Lyon',
            address: '45 Avenue des Cafés, 69002 Lyon',
            hours: 'Lun-Dim: 7h-20h',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contactez-nous'),
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Suivez-nous'),
          const SizedBox(height: 16),
          _buildSocialMediaCard(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.brown.shade700,
            Colors.brown.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.coffee,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Coffee Shop',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Depuis 2010',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notre passion pour le café a commencé en 2010, lorsque nous avons ouvert notre premier café à Paris. Depuis lors, nous nous sommes engagés à offrir la meilleure expérience café possible à nos clients.',
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aujourd\'hui, nous sommes fiers de servir des cafés de qualité supérieure dans plusieurs villes de France, tout en maintenant notre engagement envers la durabilité et l\'excellence.',
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.brown,
                size: 32,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String name,
    required String address,
    required String hours,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.brown,
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address),
            Text(
              hours,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Ouvrir la carte avec l'emplacement
        },
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactItem(
              icon: Icons.email,
              title: 'Email',
              value: 'contact@coffeeshop.com',
            ),
            const Divider(),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Téléphone',
              value: '+33 1 23 45 67 89',
            ),
            const Divider(),
            _buildContactItem(
              icon: Icons.access_time,
              title: 'Heures d\'ouverture',
              value: 'Lundi - Dimanche: 7h - 20h',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.brown,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialMediaButton(
              icon: Icons.facebook,
              onTap: () {
                // TODO: Ouvrir Facebook
              },
            ),
            _buildSocialMediaButton(
              icon: Icons.camera_alt,
              onTap: () {
                // TODO: Ouvrir Instagram
              },
            ),
            _buildSocialMediaButton(
              icon: Icons.chat,
              onTap: () {
                // TODO: Ouvrir Twitter
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.brown,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
} 
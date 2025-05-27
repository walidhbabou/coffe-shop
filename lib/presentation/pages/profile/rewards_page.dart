import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Étoiles & Récompenses'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRewardsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Vos récompenses'),
          const SizedBox(height: 16),
          _buildRewardItem(
            context,
            title: 'Café gratuit',
            description: 'Obtenez un café gratuit',
            starsRequired: 150,
            starsEarned: 150,
            isAvailable: true,
          ),
          _buildRewardItem(
            context,
            title: 'Café premium',
            description: 'Obtenez un café premium gratuit',
            starsRequired: 300,
            starsEarned: 150,
            isAvailable: false,
          ),
          _buildRewardItem(
            context,
            title: 'Boîte de café',
            description: 'Obtenez une boîte de café premium',
            starsRequired: 500,
            starsEarned: 150,
            isAvailable: false,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Historique des transactions'),
          const SizedBox(height: 16),
          _buildTransactionItem(
            context,
            title: 'Achat de café',
            date: '15/03/2024',
            stars: '+50',
            isEarned: true,
          ),
          _buildTransactionItem(
            context,
            title: 'Café gratuit',
            date: '10/03/2024',
            stars: '-150',
            isEarned: false,
          ),
          _buildTransactionItem(
            context,
            title: 'Achat de café',
            date: '05/03/2024',
            stars: '+50',
            isEarned: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
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
          const Text(
            'Vos étoiles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 40,
              ),
              const SizedBox(width: 8),
              const Text(
                '150',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 150 / 500,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '150/500 étoiles pour la prochaine récompense',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(
    BuildContext context, {
    required String title,
    required String description,
    required int starsRequired,
    required int starsEarned,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Disponible' : 'Non disponible',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$starsEarned/$starsRequired',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implémenter l'échange de récompense
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Échanger'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String date,
    required String stars,
    required bool isEarned,
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
            color: isEarned
                ? Colors.green.withOpacity(0.1)
                : Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isEarned ? Icons.add : Icons.remove,
            color: isEarned ? Colors.green : Colors.amber,
          ),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          stars,
          style: TextStyle(
            color: isEarned ? Colors.green : Colors.amber,
            fontWeight: FontWeight.bold,
          ),
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
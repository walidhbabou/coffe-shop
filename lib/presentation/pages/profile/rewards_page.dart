import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rewards',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildRewardsCard(),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 24),
          const Text(
            'Available Rewards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRewardItem(
            title: 'Free Drink',
            points: 150,
            description: 'Get any handcrafted drink, any size',
            isAvailable: true,
          ),
          const SizedBox(height: 12),
          _buildRewardItem(
            title: 'Birthday Reward',
            points: 0,
            description: 'Free drink or treat on your birthday',
            isAvailable: true,
            isBirthday: true,
          ),
          const SizedBox(height: 12),
          _buildRewardItem(
            title: 'Free Bakery Item',
            points: 250,
            description: 'Choose any item from our bakery',
            isAvailable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.brown.shade800,
            Colors.brown.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '150 Stars',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gold Level Member',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '100 more stars until your next reward!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress to Next Reward',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.brown.shade600,
                        Colors.brown.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Expanded(
                flex: 40,
                child: SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '150/250 stars',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem({
    required String title,
    required int points,
    required String description,
    required bool isAvailable,
    bool isBirthday = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.brown : Colors.grey[300]!,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.brown.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBirthday ? Icons.cake : Icons.star,
              color: isAvailable ? Colors.brown : Colors.grey[400],
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (!isBirthday) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$points Stars',
                    style: TextStyle(
                      color: isAvailable ? Colors.brown : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isAvailable)
            TextButton(
              onPressed: () {},
              child: const Text(
                'Redeem',
                style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

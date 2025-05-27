import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newsletter = false;
  bool _newProducts = true;
  bool _specialOffers = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Notifications push'),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Activer les notifications push',
            subtitle: 'Recevoir des notifications sur votre appareil',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Notifications par email'),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Activer les notifications par email',
            subtitle: 'Recevoir des emails de Coffee Shop',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Préférences de notification'),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Mises à jour de commande',
            subtitle: 'Suivi de vos commandes en temps réel',
            value: _orderUpdates,
            onChanged: _emailNotifications
                ? (value) {
                    setState(() {
                      _orderUpdates = value;
                    });
                  }
                : null,
          ),
          _buildNotificationSwitch(
            title: 'Promotions',
            subtitle: 'Offres spéciales et réductions',
            value: _promotions,
            onChanged: _emailNotifications
                ? (value) {
                    setState(() {
                      _promotions = value;
                    });
                  }
                : null,
          ),
          _buildNotificationSwitch(
            title: 'Newsletter',
            subtitle: 'Actualités et articles sur le café',
            value: _newsletter,
            onChanged: _emailNotifications
                ? (value) {
                    setState(() {
                      _newsletter = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Autres notifications'),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Nouveaux produits',
            subtitle: 'Découvrez nos dernières créations',
            value: _newProducts,
            onChanged: _pushNotifications
                ? (value) {
                    setState(() {
                      _newProducts = value;
                    });
                  }
                : null,
          ),
          _buildNotificationSwitch(
            title: 'Offres spéciales',
            subtitle: 'Offres exclusives et événements',
            value: _specialOffers,
            onChanged: _pushNotifications
                ? (value) {
                    setState(() {
                      _specialOffers = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 24),
          _buildNotificationPreferences(),
        ],
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

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.brown,
      ),
    );
  }

  Widget _buildNotificationPreferences() {
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
            const Text(
              'Préférences de notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choisissez quand vous souhaitez recevoir des notifications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Fréquence des notifications',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: 'daily',
              items: const [
                DropdownMenuItem(
                  value: 'daily',
                  child: Text('Quotidiennement'),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text('Hebdomadairement'),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Text('Mensuellement'),
                ),
              ],
              onChanged: (value) {
                // TODO: Implémenter le changement de fréquence
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Heure de notification',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: 'morning',
              items: const [
                DropdownMenuItem(
                  value: 'morning',
                  child: Text('Matin (8h-12h)'),
                ),
                DropdownMenuItem(
                  value: 'afternoon',
                  child: Text('Après-midi (12h-17h)'),
                ),
                DropdownMenuItem(
                  value: 'evening',
                  child: Text('Soir (17h-21h)'),
                ),
              ],
              onChanged: (value) {
                // TODO: Implémenter le changement d'heure
              },
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/admin_users_viewmodel.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  // Constantes de style
  static const _primaryColor = Color(0xFF2563EB);
  static const _backgroundColor = Color(0xFFF8FAFC);
  static const _cardColor = Colors.white;
  static const _dangerColor = Color(0xFFDC2626);
  static const _successColor = Color(0xFF059669);
  static const _warningColor = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: ChangeNotifierProvider<AdminUsersViewModel>(
        create: (_) => AdminUsersViewModel(),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: _buildText(
        'Gestion des Utilisateurs',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      backgroundColor: _primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () {
            // Rafraîchir la liste
            context.read<AdminUsersViewModel>().fetchUsers();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<AdminUsersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return _buildLoadingState();
        if (viewModel.errorMessage != null) return _buildErrorState(viewModel);
        if (viewModel.users.isEmpty) return _buildEmptyState();
        return _buildUsersList(viewModel);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          _buildText(
            'Chargement des utilisateurs...',
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AdminUsersViewModel viewModel) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: _dangerColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildText(
              'Erreur de chargement',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _dangerColor,
            ),
            const SizedBox(height: 8),
            _buildText(
              viewModel.errorMessage!,
              fontSize: 14,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchUsers(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildText(
              'Aucun utilisateur',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 8),
            _buildText(
              'Aucun utilisateur n\'a été trouvé dans le système',
              fontSize: 14,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(AdminUsersViewModel viewModel) {
    return Column(
      children: [
        _buildUsersHeader(viewModel.users.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) => _buildUserCard(
              context,
              viewModel.users[index],
              viewModel,
              index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersHeader(int userCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: _primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.people_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          _buildText(
            '$userCount utilisateur${userCount > 1 ? 's' : ''} trouvé${userCount > 1 ? 's' : ''}',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Map<String, dynamic> user,
    AdminUsersViewModel viewModel,
    int index,
  ) {
    final email = user['email'] ?? '';
    final displayName = _extractDisplayName(email);
    final userRole = user['role'] ?? 'User';
    final isAdmin = userRole.toLowerCase() == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetails(context, user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildUserAvatar(displayName, isAdmin),
                const SizedBox(width: 16),
                Expanded(child: _buildUserInfo(displayName, email, userRole)),
                _buildUserActions(context, user, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String displayName, bool isAdmin) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAdmin
                  ? [_warningColor, _warningColor.withOpacity(0.7)]
                  : [_primaryColor, _primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isAdmin ? _warningColor : _primaryColor).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _buildText(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (isAdmin)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _warningColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(String displayName, String email, String userRole) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText(
          displayName.isNotEmpty ? displayName : 'N/A',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
        const SizedBox(height: 4),
        _buildText(
          email.isNotEmpty ? email : 'N/A',
          fontSize: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 6),
        _buildRoleBadge(userRole),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role.toLowerCase() == 'admin';
    final color = isAdmin ? _warningColor : _successColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          _buildText(
            role,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildUserActions(
    BuildContext context,
    Map<String, dynamic> user,
    AdminUsersViewModel viewModel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showUserDetails(context, user),
          icon: const Icon(Icons.visibility_rounded),
          style: IconButton.styleFrom(
            backgroundColor: _primaryColor.withOpacity(0.1),
            foregroundColor: _primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context, user, viewModel),
          icon: const Icon(Icons.delete_outline_rounded),
          style: IconButton.styleFrom(
            backgroundColor: _dangerColor.withOpacity(0.1),
            foregroundColor: _dangerColor,
          ),
        ),
      ],
    );
  }

  // Méthodes utilitaires
  String _extractDisplayName(String email) {
    if (email.isEmpty) return '';
    final partBeforeAt = email.split('@')[0];
    final alphaRegex = RegExp(r'^[a-zA-Z]+');
    return alphaRegex.firstMatch(partBeforeAt)?.group(0) ?? partBeforeAt;
  }

  Widget _buildText(
    String text, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.grey[800],
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.person_rounded, color: _primaryColor),
            const SizedBox(width: 8),
            _buildText('Détails utilisateur',
                fontSize: 18, fontWeight: FontWeight.bold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nom', _extractDisplayName(user['email'] ?? '')),
            _buildDetailRow('Email', user['email'] ?? 'N/A'),
            _buildDetailRow('Rôle', user['role'] ?? 'User'),
            _buildDetailRow('UID', user['uid'] ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: _buildText('Fermer',
                color: _primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: _buildText(
              '$label:',
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: _buildText(
              value,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> user,
    AdminUsersViewModel viewModel,
  ) {
    // Vérifier si l'utilisateur est l'admin
    if (user['email'] == 'admin@coffeeapp.com') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Impossible de supprimer le compte administrateur principal'),
          backgroundColor: _dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: _dangerColor),
            const SizedBox(width: 8),
            _buildText('Confirmer la suppression',
                fontSize: 18, fontWeight: FontWeight.bold),
          ],
        ),
        content: _buildText(
          'Êtes-vous sûr de vouloir supprimer cet utilisateur ?\n\nCette action est irréversible.',
          color: Colors.grey[600],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: _buildText('Annuler',
                color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.deleteUser(user['uid']);
              if (viewModel.errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Utilisateur supprimé avec succès'),
                    backgroundColor: _successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: _dangerColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../domain/viewmodels/admin_users_viewmodel.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Utilisateurs',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ChangeNotifierProvider<AdminUsersViewModel>(
        create: (_) => AdminUsersViewModel(),
        child: Consumer<AdminUsersViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Text(
                  'Erreur: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (viewModel.users.isEmpty) {
              return const Center(
                child: Text('Aucun utilisateur trouvé.'),
              );
            }

            return ListView.builder(
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final user = viewModel.users[index];
                String email = user['email'] ?? '';
                String partBeforeAt = email.split('@')[0];

                RegExp alphaRegex = RegExp(r'^[a-zA-Z]+');
                String displayedName =
                    alphaRegex.firstMatch(partBeforeAt)?.group(0) ??
                        partBeforeAt;

                // Get user role, defaulting to 'User' if not present
                String userRole = user['role'] ?? 'User';

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(displayedName.isNotEmpty == true
                        ? displayedName[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(displayedName.isNotEmpty ? displayedName : 'N/A'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email.isNotEmpty ? email : 'N/A'),
                      Text('Role: $userRole',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          viewModel.deleteUser(user['uid']);
                          print('Delete user: ${user['uid']}');
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createAdminIfNotExists() async {
  const adminEmail = 'admin@coffeeapp.com';
  const adminPassword = 'AdminPassword123'; 

  final existingAdmins = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'admin')
      .limit(1)
      .get();

  if (existingAdmins.docs.isEmpty) {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: adminEmail, password: adminPassword);

      final adminUser = userCredential.user;
      if (adminUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(adminUser.uid).set({
          'role': 'admin',
          'email': adminEmail,
        });
        print('Admin account created.');
      }
    } on FirebaseAuthException catch (e) {
      print('Failed to create admin: ${e.message}');
    }
  } else {
    print('Admin already exists.');
  }
}
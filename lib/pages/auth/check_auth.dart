// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/admin_page.dart';
import '../home/home_page.dart';

class AuthService {
  Future<void> handleUserLogin(BuildContext context, User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = doc.data()?['role'] ?? 'user';

    if (role == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        //Loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //Not logged in
        if (!authSnapshot.hasData) {
          return const HomePage();
        }
        //Current logged in user
        final user = authSnapshot.data!;
        //Listen to Firestore user document
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            //Loading Firestore user document
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            //Error
            if (userSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error loading user')),
              );
            }

            //User document not created yet
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            //User data
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = (userData['role'] ?? 'user').toString().toLowerCase();
            //Admin
            if (role == 'admin') {
              return const AdminPage();
            }
            //Normal user
            return const HomePage();
          },
        );
      },
    );
  }
}

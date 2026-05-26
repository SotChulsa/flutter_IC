import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../admin/admin_page.dart';
import '../home/home_page.dart';

class AuthService {
  Future<void> handleUserLogin(User user) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    //Listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        //Not logged in
        if (!authSnapshot.hasData) {
          return const HomePage();
        }
        //Logged in user
        final user = authSnapshot.data!;
        //Check Firestore role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            //loading
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            //error
            if (userSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error loading user')),
              );
            }
            //no user
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User document not found')),
              );
            }
            //fetch user data
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            //get roles
            final role = userData['role'].toString().toLowerCase();
            //for admin
            if (role == 'admin') {
              return const AdminPage();
            }
            //for normal users
            return const HomePage();
          },
        );
      },
    );
  }
}

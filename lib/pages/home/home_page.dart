import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  //for users who are not logged in, navigate to login page when profile icon is tapped, for users who are logged in, navigate to profile page when profile icon is tapped
                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyLoginPage(),
                      ),
                    );
                  }
                  // USER LOGGED IN
                  else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  }
                },
                icon: ClipOval(
                  child: Image.asset(
                    'images/default_profile.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final quizzes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return ListTile(
                title: Text(quiz['title']),
                subtitle: Text(quiz['category']),
              );
            },
          );
        },
      ),
    );
  }
}

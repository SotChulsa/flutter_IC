import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/quiz/quiz_page.dart';

import '../auth/login_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 78, 180, 93),
            Color.fromARGB(255, 255, 255, 255),
          ],
          stops: [0.0, 0.4],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.green,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Results',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // top section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,\nUser!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose a category to start your learning journey',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),

                    SizedBox(
                      width: 55,
                      height: 55,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          // user not logged in
                          if (user == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyLoginPage(),
                              ),
                            );
                          }
                          // user logged in
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
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                //continue learning card
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('quizzes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    //loading state
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    //empty state
                    if (snapshot.data!.docs.isEmpty) {
                      return const SizedBox();
                    }

                    final latestQuiz = snapshot.data!.docs.first;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF42A5F5)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Continue Learning',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Last played',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            latestQuiz['category'],

                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: const LinearProgressIndicator(
                                    value: 0.7,
                                    minHeight: 10,
                                    backgroundColor: Colors.white30,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const QuizPage(),
                                    ),
                                  );
                                },
                                child: const Text('Resume Quiz'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Text(
                            '10 Questions Available',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Quiz Categories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories are sorted by your most frequently selected subjects',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 18),

                // quiz list
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('quizzes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // loading state
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final quizzes = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: quizzes.length,

                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          // skip unpublished quizzes
                          if (quiz['isPublished'] != true) {
                            return const SizedBox();
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.green.shade300),
                            ),

                            child: Row(
                              children: [
                                // icon
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // quiz info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz['title'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      Text(quiz['category']),
                                      const SizedBox(height: 4),

                                      Text(
                                        '${quiz['questions'].length} questions available',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // start quiz button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                  ),

                                  onPressed: () {
                                    // prevent invalid quizzes
                                    if (quiz['questions'].length < 10) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'this quiz needs at least 10 questions',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // navigate to quiz page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const QuizPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('Start Quiz'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

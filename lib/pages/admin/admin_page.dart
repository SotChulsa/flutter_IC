// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttergame_ic/pages/auth/login_page.dart';
import 'package:fluttergame_ic/pages/quiz/create_quiz.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyLoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 57, 255, 35),
                      Color.fromARGB(255, 36, 195, 18),
                    ],
                    stops: [0.0, 0.5],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Dashboard Overview',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              //Admin stats
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, userSnapshot) {
                  //Loading
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  //Error
                  if (userSnapshot.hasError) {
                    return Center(child: Text(userSnapshot.error.toString()));
                  }
                  //Users data
                  final users = userSnapshot.data?.docs ?? [];
                  //Total users
                  final totalUsers = users.length;
                  //Active users
                  final activeUsers = users.where((userDoc) {
                    final data = userDoc.data() as Map<String, dynamic>;
                    return data['isOnline'] == true;
                  }).length;
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quizzes')
                        .snapshots(),
                    builder: (context, quizSnapshot) {
                      //Loading
                      if (quizSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      //Error
                      if (quizSnapshot.hasError) {
                        return Center(
                          child: Text(quizSnapshot.error.toString()),
                        );
                      }
                      //Quiz data
                      final quizzes = quizSnapshot.data?.docs ?? [];
                      //Total quizzes
                      final totalQuizzes = quizzes.length;
                      //Total questions
                      int totalQuestions = 0;
                      for (var quiz in quizzes) {
                        final data = quiz.data() as Map<String, dynamic>;
                        final questions = data['questions'] as List? ?? [];
                        totalQuestions += questions.length;
                      }
                      return GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 57, 255, 35),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AdminStatCard(
                              title: 'Total Users',
                              value: totalUsers.toString(),
                              icon: Icons.people_alt_rounded,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 57, 255, 35),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AdminStatCard(
                              title: 'Total Quizzes',
                              value: totalQuizzes.toString(),
                              icon: Icons.quiz_rounded,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 57, 255, 35),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AdminStatCard(
                              title: 'Total Questions',
                              value: totalQuestions.toString(),
                              icon: Icons.menu_book_rounded,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 57, 255, 35),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AdminStatCard(
                              title: 'Active Users',
                              value: activeUsers.toString(),
                              icon: Icons.bar_chart_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 25),

              //Quiz management
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 57, 255, 35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quiz Management',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 27, 145, 13),
                                Color.fromARGB(255, 36, 195, 18),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateQuizPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Quiz'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const QuizManagementCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Reusable card widget for admin statistics
//Example:
//Total Users
//Total Quizzes
//Active Users
class AdminStatCard extends StatelessWidget {
  // card title text
  final String title;
  // card main value text
  final String value;
  // icon shown at top of card
  final IconData icon;
  const AdminStatCard({
    super.key,
    // required values passed when creating card
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    //main card container
    return Container(
      //spacing inside card
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        //white background
        color: const Color.fromARGB(255, 255, 255, 255),
        //rounded corners
        borderRadius: BorderRadius.circular(24),
        //shadow effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        //align children to left side
        crossAxisAlignment: CrossAxisAlignment.start,
        //push top and bottom content apart
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //icon container
          Container(
            //spacing inside icon box
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              //green background
              color: const Color.fromARGB(255, 46, 255, 23),
              //rounded icon container
              borderRadius: BorderRadius.circular(14),
            ),
            //display passed icon
            child: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          //value & title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main state value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              //stat title
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//class to allow for CRUD operations with quizzes
class QuizManagementCard extends StatelessWidget {
  const QuizManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    //StreamBuilder listens to Firestore in realtime
    //whenever quizzes collection changes,
    //UI updates automatically
    return StreamBuilder<QuerySnapshot>(
      //connect to quizzes collection
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, snapshot) {
        //show loading spinner while data is loading
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        //store all quiz documents from Firestore
        final quizzes = snapshot.data!.docs;
        //show message if no quizzes exist
        if (quizzes.isEmpty) {
          return const Center(child: Text('No quizzes found'));
        }
        // build scrollable list of quizzes
        return ListView.builder(
          //prevents nested scrolling issues
          shrinkWrap: true,
          //disables inner scrolling because parent already scrolls
          physics: const NeverScrollableScrollPhysics(),
          //total number of quizzes
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            //get current quiz document
            final quiz = quizzes[index];
            final isPublished = quiz['isPublished'] ?? false;
            //each quiz card container
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                // shadow effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color.fromARGB(255, 57, 255, 35),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //quiz title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quiz['title'] ?? 'Untitled Quiz',

                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPublished ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPublished ? 'Published' : 'Draft',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  //quiz category
                  Text(
                    //display category from Firestore
                    quiz['category'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  //action buttons
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      //button for viewwing and edititng/updating
                      Expanded(
                        child: ElevatedButton(
                          // navigate to CreateQuizPage
                          // pass current quiz ID
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateQuizPage(
                                  quizId: quiz.id,
                                  existingQuiz:
                                      quiz.data() as Map<String, dynamic>,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      //delete button
                      Expanded(
                        child: ElevatedButton(
                          // delete current quiz document
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('quizzes')
                                .doc(quiz.id)
                                .delete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

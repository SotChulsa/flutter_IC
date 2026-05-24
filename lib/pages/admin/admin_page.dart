// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttergame_ic/pages/quiz/create_quiz.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 251, 247),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 46, 255, 23),
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
                            'Last Login: May 21, 2026 10:30 AM',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              //admin only stats
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, userSnapshot) {
                  //loading buffer
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // error
                  if (userSnapshot.hasError) {
                    return Center(child: Text(userSnapshot.error.toString()));
                  }
                  // users data
                  final users = userSnapshot.data?.docs ?? [];
                  final totalUsers = users.length;
                  //get active users
                  final activeUsers = users.where((user) {
                    final data = user.data() as Map<String, dynamic>;
                    return data['isOnline'] == true;
                  }).length;
                  //function to get data from firestone
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quizzes')
                        .snapshots(),
                    builder: (context, quizSnapshot) {
                      // loading
                      if (quizSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      //error
                      if (quizSnapshot.hasError) {
                        return Center(
                          child: Text(quizSnapshot.error.toString()),
                        );
                      }
                      //quiz data
                      final quizzes = quizSnapshot.data?.docs ?? [];
                      //total quizzes
                      final totalQuizzes = quizzes.length;
                      //total questions
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
                          AdminStatCard(
                            title: 'Total Users',
                            value: totalUsers.toString(),
                            icon: Icons.people_alt_rounded,
                          ),

                          AdminStatCard(
                            title: 'Total Quizzes',
                            value: totalQuizzes.toString(),
                            icon: Icons.quiz_rounded,
                          ),

                          AdminStatCard(
                            title: 'Total Questions',
                            value: totalQuestions.toString(),
                            icon: Icons.menu_book_rounded,
                          ),

                          AdminStatCard(
                            title: 'Active Users',
                            value: activeUsers.toString(),
                            icon: Icons.bar_chart_rounded,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Create Quiz',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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

// Reusable card widget for admin statistics
// Example:
// Total Users
// Total Quizzes
// Active Users
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
      // connect to quizzes collection
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),

      builder: (context, snapshot) {
        //show loading spinner while data is loading
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        //store all quiz documents from Firestore
        final quizzes = snapshot.data!.docs;

        // show message if no quizzes exist
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
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //quiz title
                  Text(
                    //display title from Firestore
                    //fallback if title missing
                    quiz['title'] ?? 'Untitled Quiz',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

//category tag
class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Mathematics',
        style: TextStyle(
          color: Colors.green,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

//publish tag
class PublishedTag extends StatelessWidget {
  const PublishedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Published',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
      ),
    );
  }
}

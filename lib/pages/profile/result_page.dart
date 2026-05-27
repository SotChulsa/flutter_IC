import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/home/home_page.dart';
import 'package:fluttergame_ic/pages/quiz/complete_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int completedQuizzes = 0;
  double avgAccuracy = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  //Loads all quiz results of the current user from Firestore & calculates completed quizzes and average accuracy, then updates the UI
  Future<void> loadStats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('results')
        .where('userId', isEqualTo: currentUser.uid)
        .get();
    final docs = snapshot.docs;
    completedQuizzes = docs.length;
    double totalAccuracy = 0;
    for (var doc in docs) {
      totalAccuracy += (doc['accuracy'] ?? 0).toDouble();
    }
    if (docs.isNotEmpty) {
      avgAccuracy = totalAccuracy / docs.length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Result',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                //Top summary stats
                Row(
                  children: [
                    //Total quizzes completed
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.workspace_premium_outlined,
                        value: completedQuizzes.toString(),
                        label: 'Quizzes Completed',
                      ),
                    ),
                    const SizedBox(width: 24),

                    //Accuracy
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.show_chart,
                        value: '${avgAccuracy.toStringAsFixed(0)}%',
                        label: 'Avg Accuracy',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                //Recent quiz results
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 97, 241, 105),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Quiz Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),

                        //Retrieves the current user's quiz history from Firestore
                        //Updates automatically in realtime
                        //Dormats the quiz data & displays each result as a scrollable card list
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('results')
                                .where('userId', isEqualTo: currentUser?.uid)
                                .orderBy('completedAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text('No results yet'),
                                );
                              }
                              final results = snapshot.data!.docs;
                              return ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      results[index].data()
                                          as Map<String, dynamic>;
                                  final category =
                                      data['category'] ?? 'Unknown';
                                  final score = data['score'] ?? 0;
                                  final totalQuestions =
                                      data['totalQuestions'] ?? 0;
                                  final accuracy = (data['accuracy'] ?? 0)
                                      .toDouble();
                                  final completedAt =
                                      (data['completedAt'] as Timestamp?)
                                          ?.toDate();
                                  final formattedDate = completedAt != null
                                      ? '${completedAt.day}/${completedAt.month}/${completedAt.year}'
                                      : 'No date';
                                  final answers =
                                      List<Map<String, dynamic>>.from(
                                        data['answers'] ?? [],
                                      );
                                  final duration = data['duration'] ?? '00:00';
                                  final quizId = data['quizId'] ?? '';
                                  return _buildResultCard(
                                    category: category,
                                    score: score,
                                    totalQuestions: totalQuestions,
                                    accuracy: accuracy,
                                    date: formattedDate,
                                    answers: answers,
                                    duration: duration,
                                    quizId: quizId,
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
                const SizedBox(height: 20),

                //Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Do more Quizzess',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Stat card
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 97, 241, 105),
          width: 2.5,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 97, 241, 105),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 0, 0, 0),
              size: 22,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 97, 241, 105),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  //Result card
  Widget _buildResultCard({
    required String category,
    required int score,
    required int totalQuestions,
    required double accuracy,
    required String date,
    required List<Map<String, dynamic>> answers,
    required String duration,
    required String quizId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color.fromARGB(255, 97, 241, 105),
          width: 2.5,
        ),
      ),
      child: SizedBox(
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 147, 228, 159),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 70, 177, 86),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$score/$totalQuestions',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Score',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              date,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accuracy',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${accuracy.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: accuracy / 100,
              minHeight: 7,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.green.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 12),

            //When click view detail, the navigator will push to the complete quiz page that matches the parameter in the builder below
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizResultPage(
                        score: score,
                        totalQuestions: totalQuestions,
                        accuracy: accuracy,
                        category: category,
                        quizTitle: 'Quiz',
                        duration: duration,
                        answers: answers,
                        quizId: quizId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 251, 216),
                  foregroundColor: const Color.fromARGB(255, 70, 177, 86),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

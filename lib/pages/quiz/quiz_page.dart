// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  //quiz stats variables
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int score = 0;
  List<int?> userAnswers = [];
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  //fetching questions from firestone
  Future<void> fetchQuizQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .get();
      print(snapshot.docs.length);
      List<Map<String, dynamic>> loadedQuestions = [];
      //loops through quiz documents
      for (var doc in snapshot.docs) {
        final data = doc.data();
        //wont show unpublished quizzes
        if (data['isPublished'] != true) {
          continue;
        }
        final category = data['category'];
        final quizQuestions = data['questions'] as List;
        //flatten question arrays
        for (var q in quizQuestions) {
          loadedQuestions.add({
            'question': q['questionText'],
            'options': q['options'],
            'correctAnswer': q['correctAnswer'],
            'category': category,
          });
        }
      }
      //limits a quiz to 10 questions only
      setState(() {
        questions = loadedQuestions.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  //next questions function
  Future<void> nextQuestion() async {
    //save answer
    userAnswers.add(selectedAnswer);
    //check answer
    final selectedOption =
        questions[currentQuestionIndex]['options'][selectedAnswer];
    if (selectedOption == questions[currentQuestionIndex]['correctAnswer']) {
      score++;
      //last question
      if (currentQuestionIndex == questions.length - 1) {
        //get the time finished
        final endTime = DateTime.now();
        //calculate duration of a quiz
        final duration = endTime.difference(startTime);
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        //save result to firestore
        await FirebaseFirestore.instance.collection('results').add({
          'score': score,
          'totalQuestions': questions.length,
          'accuracy': (score / questions.length) * 100,
          'completedAt': Timestamp.now(),
          'category': questions[0]['category'],
        });
        //show the dialog for completion
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Quiz Completed'),
              content: Text(
                'Your Score: $score / ${questions.length}'
                'Time: ${minutes}m ${seconds}s',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Finish'),
                ),
              ],
            );
          },
        );
        return;
      }
      //next question
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    }
  }

  late DateTime startTime;

  @override
  void initState() {
    //start the quiz timer
    startTime = DateTime.now();
    super.initState();
    fetchQuizQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No quizzes found')));
    }
    final question = questions[currentQuestionIndex];
    final totalQuestions = questions.length;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Exit Quiz'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined),
                          SizedBox(width: 6),
                          Text(
                            '00:45',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                //category + progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      question['category'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Question ${currentQuestionIndex + 1} of $totalQuestions',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / totalQuestions,
                    minHeight: 10,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
                const SizedBox(height: 28),
                //question card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${currentQuestionIndex + 1}.',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          question['question'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Select the correct answer below',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),

                        //answer options
                        ...List.generate(question['options'].length, (index) {
                          final option = question['options'][index];
                          final isSelected = selectedAnswer == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAnswer = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isSelected
                                        ? Colors.green
                                        : Colors.grey.shade200,
                                    child: Text(
                                      String.fromCharCode(65 + index),

                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: selectedAnswer == null
                                ? null
                                : nextQuestion,
                            child: Text(
                              currentQuestionIndex == questions.length - 1
                                  ? 'Finish Quiz'
                                  : 'Next Question',
                            ),
                          ),
                        ),
                      ],
                    ),
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

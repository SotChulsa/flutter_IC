// ignore_for_file: unnecessary_non_null_assertion, use_build_context_synchronously, avoid_print
import 'quiz_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttergame_ic/pages/quiz/complete_page.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  //quiz stats variables
  QuizSession? currentSession;
  final currentUser = FirebaseAuth.instance.currentUser;
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int score = 0;
  List<int?> userAnswers = [];
  Set<int> flaggedQuestions = {};
  String category = '';
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> answerBreakdown = [];
  bool isLoading = true;
  //fetching questions from firestone
  //If the quiz exists, the document data is stored in data, and the quiz category and question list are extracted. If not, function does not load
  Future<void> fetchQuizQuestions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final data = doc.data()!;
      final category = data['category'];
      final quizQuestions = data['questions'] as List;
      List<Map<String, dynamic>> loadedQuestions = [];
      for (var q in quizQuestions) {
        loadedQuestions.add({
          'question': q['questionText'],
          'options': q['options'],
          'correctAnswer': q['correctAnswer'],
          'category': category,
        });
      }
      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  //next questions function
  Future<void> nextQuestion() async {
    //save the answer
    if (userAnswers.length > currentQuestionIndex) {
      userAnswers[currentQuestionIndex] = selectedAnswer;
    } else {
      userAnswers.add(selectedAnswer);
    }
    final breakdownData = {
      'question': questions[currentQuestionIndex]['question'],
      'selectedAnswer': selectedAnswer != null
          ? questions[currentQuestionIndex]['options'][selectedAnswer!]
          : 'Skipped',
      'correctAnswer': questions[currentQuestionIndex]['correctAnswer'],
    };

    if (answerBreakdown.length > currentQuestionIndex) {
      answerBreakdown[currentQuestionIndex] = breakdownData;
    } else {
      answerBreakdown.add(breakdownData);
    }
    //check for user choose
    if (selectedAnswer != null) {
      final selectedOption =
          questions[currentQuestionIndex]['options'][selectedAnswer!];
      if (selectedOption == questions[currentQuestionIndex]['correctAnswer']) {
        score++;
      }
    }
    //when user reaches the last question
    if (currentQuestionIndex == questions.length - 1) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      //show result for quiz completion
      final currentUser = FirebaseAuth.instance.currentUser;
      String category = questions[0]['category'];
      await FirebaseFirestore.instance.collection('results').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'category': category,
        'score': score,
        'totalQuestions': questions.length,
        'accuracy': (score / questions.length) * 100,
        'completedAt': Timestamp.now(),
        'answers': answerBreakdown,
        'duration': '$minutes:${seconds.toString().padLeft(2, '0')}',
        'quizId': widget.quizId,
      });
      await FirebaseFirestore.instance
          .collection('quiz_progress')
          .doc(currentUser!.uid)
          .delete();
      //update score for profile page
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final data = userDoc.data()!;
      //previous stats
      int previousCorrect = data['totalCorrectAnswers'] ?? 0;
      int previousQuestions = data['totalQuestionsAnswered'] ?? 0;
      //new totals
      int newCorrect = previousCorrect + score;
      int newQuestions = previousQuestions + questions.length;
      //calculate overall accuracy for all quizzes done
      double lifetimeAccuracy = (newCorrect / newQuestions) * 100;
      //daily goals & streak
      DateTime now = DateTime.now();
      Timestamp? lastQuizTimestamp = data['lastQuizCompletedDate'];
      DateTime? lastQuizDate = lastQuizTimestamp?.toDate();
      int todayCompleted = data['todayCompletedQuizzes'] ?? 0;
      //chec if its a new day
      bool isNewDay = true;
      if (lastQuizDate != null) {
        isNewDay =
            lastQuizDate.year != now.year ||
            lastQuizDate.month != now.month ||
            lastQuizDate.day != now.day;
      }
      //reset daily count
      if (isNewDay) {
        todayCompleted = 0;
      }
      //increase competed quizzes done for the day
      todayCompleted++;
      //update firestone
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
            'quizzesCompleted': FieldValue.increment(1),
            'totalScore': FieldValue.increment(score),
            'totalCorrectAnswers': newCorrect,
            'totalQuestionsAnswered': newQuestions,
            'accuracyRate': lifetimeAccuracy.round(),
            'todayCompletedQuizzes': todayCompleted,
            'lastQuizCompletedDate': Timestamp.now(),
          });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          //allow to update completed quiz data at the result page
          builder: (_) => QuizResultPage(
            score: score,
            totalQuestions: questions.length,
            accuracy: (score / questions.length) * 100,
            category: questions[0]['category'],
            quizTitle: 'Quiz',
            duration: '$minutes:${seconds.toString().padLeft(2, '0')}',
            answers: answerBreakdown,
            quizId: widget.quizId,
          ),
        ),
      );
      return;
    }
    //next question function
    await FirebaseFirestore.instance
        .collection('quiz_progress')
        .doc(currentUser!.uid)
        .set({
          'quizId': widget.quizId,
          'currentQuestionIndex': currentQuestionIndex + 1,
          'score': score,
          'answers': answerBreakdown,
          'userAnswers': userAnswers,
          'updatedAt': Timestamp.now(),
        });
    currentSession = QuizSession(
      questions: questions,
      selectedAnswers: {
        for (int i = 0; i < userAnswers.length; i++) i: userAnswers[i],
      },
      currentQuestionIndex: currentQuestionIndex,
    );
    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
    });
  }

  Future<void> submitQuiz() async {
    // save final answer
    if (userAnswers.length > currentQuestionIndex) {
      userAnswers[currentQuestionIndex] = selectedAnswer;
    } else {
      userAnswers.add(selectedAnswer);
    }
    final breakdownData = {
      'question': questions[currentQuestionIndex]['question'],
      'selectedAnswer': selectedAnswer != null
          ? questions[currentQuestionIndex]['options'][selectedAnswer!]
          : 'Skipped',
      'correctAnswer': questions[currentQuestionIndex]['correctAnswer'],
    };
    if (answerBreakdown.length > currentQuestionIndex) {
      answerBreakdown[currentQuestionIndex] = breakdownData;
    } else {
      answerBreakdown.add(breakdownData);
    }
    // calculate final score
    if (selectedAnswer != null) {
      final selectedOption =
          questions[currentQuestionIndex]['options'][selectedAnswer!];

      if (selectedOption == questions[currentQuestionIndex]['correctAnswer']) {
        score++;
      }
    }
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final currentUser = FirebaseAuth.instance.currentUser;
    String category = questions[0]['category'];
    await FirebaseFirestore.instance.collection('results').add({
      'userId': currentUser!.uid,
      'category': category,
      'score': score,
      'totalQuestions': questions.length,
      'accuracy': (score / questions.length) * 100,
      'completedAt': Timestamp.now(),
      'answers': answerBreakdown,
      'userAnswers': userAnswers,
      'duration': '$minutes:${seconds.toString().padLeft(2, '0')}',
      'quizId': widget.quizId,
    });

    await FirebaseFirestore.instance
        .collection('quiz_progress')
        .doc(currentUser.uid)
        .delete();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultPage(
          score: score,
          totalQuestions: questions.length,
          accuracy: (score / questions.length) * 100,
          category: questions[0]['category'],
          quizTitle: 'Quiz',
          duration: '$minutes:${seconds.toString().padLeft(2, '0')}',
          answers: answerBreakdown,
          quizId: widget.quizId,
        ),
      ),
    );
  }

  void toggleFlagQuestion() {
    setState(() {
      if (flaggedQuestions.contains(currentQuestionIndex)) {
        flaggedQuestions.remove(currentQuestionIndex);
      } else {
        flaggedQuestions.add(currentQuestionIndex);
      }
    });
  }

  void showReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review Questions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(questions.length, (index) {
                  final isAnswered = index < userAnswers.length;

                  final isFlagged = flaggedQuestions.contains(index);

                  Color color;

                  if (isFlagged) {
                    color = Colors.orange;
                  } else if (isAnswered) {
                    color = Colors.green;
                  } else {
                    color = Colors.grey;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        currentQuestionIndex = index;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await submitQuiz();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Quiz'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  late DateTime startTime;

  @override
  void initState() {
    //start the quiz timer
    startTime = DateTime.now();
    super.initState();
    fetchQuizQuestions().then((_) {
      loadQuizProgress();
    });
  }

  //This function loads a user’s saved quiz progress from Firestore so they can continue a quiz from where they left off.
  //If no progress document exists, the function stops immediately using return. If progress data exists,
  //it stores the document data into the data variable and checks whether the saved quizId matches the quiz currently being opened. This will save even when user lougouts
  Future<void> loadQuizProgress() async {
    final progressDoc = await FirebaseFirestore.instance
        .collection('quiz_progress')
        .doc(currentUser!.uid)
        .get();
    if (!progressDoc.exists) return;
    final data = progressDoc.data()!;
    if (data['quizId'] == widget.quizId) {
      setState(() {
        currentQuestionIndex = data['currentQuestionIndex'] ?? 0;
        score = data['score'] ?? 0;
        answerBreakdown = List<Map<String, dynamic>>.from(
          data['answers'] ?? [],
        );
        userAnswers = List<int?>.from(data['userAnswers'] ?? []);
        //reset selected answer
        selectedAnswer = null;
      });
    }
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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 70, 177, 86),
            Color.fromARGB(255, 29, 116, 255),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide.none, //removes outline border
                          backgroundColor:
                              Colors.transparent, //removes background color
                          shadowColor: Colors.transparent,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  //Category + Progress
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
                      valueColor: const AlwaysStoppedAnimation(
                        Color.fromARGB(255, 97, 241, 105),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  //Question card
                  Container(
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

                        //Dynamically generates quiz answer options and updates
                        //the selected answer when the user taps an option
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
                                    ? const Color.fromARGB(255, 70, 177, 86)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : const Color.fromARGB(255, 70, 177, 86),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .transparent, // removes background
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color.fromARGB(255, 0, 0, 0)
                                            : const Color.fromARGB(
                                                255,
                                                70,
                                                177,
                                                86,
                                              ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color.fromARGB(255, 0, 0, 0)
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
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

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: toggleFlagQuestion,
                            icon: Icon(
                              flaggedQuestions.contains(currentQuestionIndex)
                                  ? Icons.flag
                                  : Icons.outlined_flag,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            label: Text(
                              flaggedQuestions.contains(currentQuestionIndex)
                                  ? 'Flagged'
                                  : 'Flag Question',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            //skip button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Skip question
                                  nextQuestion();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),

                                  side: const BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            //Next button
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  if (currentQuestionIndex ==
                                      questions.length - 1) {
                                    showReviewSheet();
                                  } else {
                                    nextQuestion();
                                  }
                                },
                                child: Text(
                                  //Will move to the next question when there is less than 10 questions, when user reaches the 10th question, change to finish quiz
                                  currentQuestionIndex == questions.length - 1
                                      ? 'Finish Quiz'
                                      : 'Next Question',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

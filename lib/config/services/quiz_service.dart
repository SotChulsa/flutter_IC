import 'package:cloud_firestore/cloud_firestore.dart';

//Service to handle quiz-related operations
class QuizService {
  //Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create quizzes with question options
  Future<void> createQuiz({
    required String title,
    required String category,
    required List<Map<String, dynamic>> questions,
    required bool isPublished,
  }) async {
    await _firestore.collection('quizzes').add({
      'title': title,
      'category': category,
      'questions': questions,
      'createdAt': Timestamp.now(),
      'isPublished': isPublished,
    });
  }

  //updating quiz data
  Future<void> updateQuiz({
    required String quizId,
    required String updatedTitle,
    required String updatedCategory,
    required List<Map<String, dynamic>> updatedQuestions,
    required bool isPublished,
  }) async {
    await FirebaseFirestore.instance.collection('quizzes').doc(quizId).update({
      'title': updatedTitle,
      'category': updatedCategory,
      'questions': updatedQuestions,
      'isPublished': isPublished,
      'isDraft': !isPublished,
    });
  }

  //deleting quizzes
  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }
}

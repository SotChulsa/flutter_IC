import 'package:cloud_firestore/cloud_firestore.dart';

//Service to handle quiz-related operations
class QuizService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //CREATE QUIZ
  Future<void> createQuiz({
    required String title,
    required String category,
  }) async {
    await _firestore.collection('quizzes').add({
      'title': title,
      'category': category,
      'createdAt': Timestamp.now(),
      'isPublished': true,
    });
  }

  //UPDATE QUIZ
  Future<void> updateQuiz({
    required String quizId,
    required String updatedTitle,
  }) async {
    await _firestore.collection('quizzes').doc(quizId).update({
      'title': updatedTitle,
    });
  }

  //DELETE QUIZ
  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }
}

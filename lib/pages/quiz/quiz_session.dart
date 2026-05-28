class QuizSession {
  final List<dynamic> questions;
  final Map<int, dynamic> selectedAnswers;
  final int currentQuestionIndex;

  QuizSession({
    required this.questions,
    required this.selectedAnswers,
    required this.currentQuestionIndex,
  });
}

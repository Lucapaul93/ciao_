class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  int? userAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.userAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }

  bool isCorrect() => userAnswerIndex == correctAnswerIndex;
}

class Quiz {
  final List<QuizQuestion> questions;

  Quiz({required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    return Quiz(
      questions: questionsList.map((q) => QuizQuestion.fromJson(q)).toList(),
    );
  }

  int getScore() {
    return questions.where((q) => q.isCorrect()).length;
  }
}

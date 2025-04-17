import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  bool showResults = false;

  void _selectAnswer(int answerIndex) {
    setState(() {
      widget.quiz.questions[currentQuestionIndex].userAnswerIndex = answerIndex;
      if (currentQuestionIndex < widget.quiz.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showResults = true;
      }
    });
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.question,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ...question.options.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String option = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(idx),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildResults() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = widget.quiz.getScore();
    final total = widget.quiz.questions.length;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Hai ottenuto $score risposte corrette su $total!',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...widget.quiz.questions.asMap().entries.map((entry) {
                  final question = entry.value;
                  final isCorrect = question.isCorrect();

                  return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color:
                            isCorrect
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.error.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Domanda ${entry.key + 1}: ${question.question}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'La tua risposta: ${question.options[question.userAnswerIndex ?? -1]}',
                                style: TextStyle(
                                  color:
                                      isCorrect
                                          ? colorScheme.primary
                                          : colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Risposta corretta: ${question.options[question.correctAnswerIndex]}',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (100 * entry.key).ms)
                      .slideX(begin: 0.2, end: 0);
                }).toList(),
                Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 16.0,
                          ),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Torna alla Storia',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz sulla Storia'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child:
            showResults
                ? _buildResults()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: LinearProgressIndicator(
                        value:
                            (currentQuestionIndex + 1) /
                            widget.quiz.questions.length,
                        backgroundColor: colorScheme.primary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Domanda ${currentQuestionIndex + 1} di ${widget.quiz.questions.length}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildQuestionCard(
                        widget.quiz.questions[currentQuestionIndex],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

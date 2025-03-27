import 'package:flutter/material.dart';

class QuizQuestion {
  final String text;
  final String? image;
  final List<AnswerOption> answers;

  QuizQuestion({
    required this.text,
    required this.answers,
    this.image,
  });
}

class AnswerOption {
  final String text;
  final String? image;
  final bool correct;

  AnswerOption({
    required this.text,
    this.image,
    required this.correct,
  });
}

class QuizBoard extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizBoard({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuizBoard> createState() => _QuizBoardState();
}

class _QuizBoardState extends State<QuizBoard> {
  int _currentIndex = 0;
  bool? _isAnswerCorrect;
  bool _finished = false;
  List<int> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _shuffleAnswers();
  }

  void _shuffleAnswers() {
    setState(() {
      widget.questions[_currentIndex].answers.shuffle();
    });
  }

  void _handleAnswerSelection(bool correct, int index) {
    if (_isAnswerCorrect == true) return;

    setState(() {
      _selectedAnswers.add(index);
      if (correct) {
        _isAnswerCorrect = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (_currentIndex < widget.questions.length - 1) {
            setState(() {
              _currentIndex++;
              _shuffleAnswers();
              _isAnswerCorrect = null;
              _selectedAnswers.clear();
            });
          } else {
            setState(() {
              _finished = true;
            });
          }
        });
      } else {
        _isAnswerCorrect = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return const Center(
        child: Text(
          '🎉 Kvíz dokončený! 🎉',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      );
    }

    final question = widget.questions[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (question.image != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Image.asset('assets/img/${question.image!}', fit: BoxFit.contain),
                    ),
                  if (question.text.isNotEmpty)
                    Text(
                      question.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 2,
                children: List.generate(question.answers.length, (index) {
                  final answer = question.answers[index];
                  final isSelected = _selectedAnswers.contains(index);
                  final isCorrect = answer.correct && _isAnswerCorrect == true;
                  Color tileColor = Colors.white;
                  if (_isAnswerCorrect == false && isSelected) {
                    tileColor = Colors.red.shade100;
                  } else if (isCorrect) {
                    tileColor = Colors.green.shade100;
                  }

                  return GestureDetector(
                    onTap: _isAnswerCorrect == true || isCorrect
                        ? null
                        : () => _handleAnswerSelection(answer.correct, index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (answer.image != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.asset('assets/img/${answer.image!}', height: 50),
                            ),
                          if (answer.text.isNotEmpty)
                            Text(
                              answer.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

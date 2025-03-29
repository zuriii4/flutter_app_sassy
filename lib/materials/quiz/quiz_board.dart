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
  final Color primaryColor;
  final Color secondaryColor;

  const QuizBoard({
    Key? key, 
    required this.questions,
    this.primaryColor = const Color(0xFF4A67FF),
    this.secondaryColor = const Color(0xFF6C63FF),
  }) : super(key: key);

  @override
  State<QuizBoard> createState() => _QuizBoardState();
}

class _QuizBoardState extends State<QuizBoard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool? _isAnswerCorrect;
  bool _finished = false;
  List<int> _selectedAnswers = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _shuffleAnswers();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        Future.delayed(const Duration(milliseconds: 1200), () {
          _animationController.reverse().then((_) {
            if (_currentIndex < widget.questions.length - 1) {
              setState(() {
                _currentIndex++;
                _shuffleAnswers();
                _isAnswerCorrect = null;
                _selectedAnswers.clear();
              });
              _animationController.forward();
            } else {
              setState(() {
                _finished = true;
              });
              _animationController.forward();
            }
          });
        });
      } else {
        _isAnswerCorrect = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 70,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(height: 20),
              Text(
                '🎉 Kvíz dokončený! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _finished = false;
                    _isAnswerCorrect = null;
                    _selectedAnswers = [];
                    _shuffleAnswers();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Začať znova'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = widget.questions[_currentIndex];

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(_animation),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Otázka ${_currentIndex + 1}/${widget.questions.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / widget.questions.length,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(widget.secondaryColor),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  padding: const EdgeInsets.all(24),
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
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (question.image != null)
                        Container(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/img/${question.image!}',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      if (question.text.isNotEmpty)
                        Text(
                          question.text,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

                // Answer options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3 / 2,
                      children: List.generate(question.answers.length, (index) {
                        final answer = question.answers[index];
                        final isSelected = _selectedAnswers.contains(index);
                        final isCorrect = answer.correct && isSelected;
                        
                        Color tileColor = Colors.white;
                        Color borderColor = Colors.grey.shade300;
                        IconData? iconData;
                        Color? iconColor;
                        
                        if (_isAnswerCorrect == false && isSelected) {
                          tileColor = Colors.red.shade50;
                          borderColor = Colors.red.shade200;
                          iconData = Icons.close;
                          iconColor = Colors.red;
                        } else if (isCorrect) {
                          tileColor = Colors.green.shade50;
                          borderColor = Colors.green.shade200;
                          iconData = Icons.check_circle;
                          iconColor = Colors.green;
                        }

                        return GestureDetector(
                          onTap: _isAnswerCorrect == true
                              ? null
                              : () => _handleAnswerSelection(answer.correct, index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (answer.image != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Image.asset(
                                          'assets/img/${answer.image!}',
                                          height: 60,
                                        ),
                                      ),
                                    if (answer.text.isNotEmpty)
                                      Text(
                                        answer.text,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                  ],
                                ),
                                if (iconData != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      iconData,
                                      color: iconColor,
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
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
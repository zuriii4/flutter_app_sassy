import 'package:flutter/material.dart';
import 'package:sassy/services/api_service.dart';
import 'dart:typed_data';

class QuizWorkspace extends StatefulWidget {
  final List<dynamic> questions;
  final String materialId;
  final Function(List<Map<String, dynamic>>, int) onQuizCompleted;

  const QuizWorkspace({
    Key? key,
    required this.questions,
    required this.materialId,
    required this.onQuizCompleted,
  }) : super(key: key);

  @override
  State<QuizWorkspace> createState() => _QuizWorkspaceState();
}

class _QuizWorkspaceState extends State<QuizWorkspace> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Stav kvízu
  List<Map<String, dynamic>> _answers = [];
  bool _quizCompleted = false;
  
  // Cache pre načítané obrázky
  final Map<String, Uint8List?> _imageCache = {};
  
  // Pre sledovanie času
  final int _startTime = DateTime.now().millisecondsSinceEpoch;
  int _timeSpent = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnswers();
    _preloadImages();
    
    // Aktualizácia času každú sekundu
    _startTimer();
  }
  
  // Preload obrázkov na predchádzanie skákaniu layoutu
  Future<void> _preloadImages() async {
    for (var question in widget.questions) {
      // Načítanie obrázka otázky
      final questionImage = question['image'];
      if (questionImage != null && questionImage.isNotEmpty) {
        try {
          final bytes = await _apiService.getImageBytes(questionImage);
          _imageCache[questionImage] = bytes;
        } catch (e) {
          print('Error preloading question image: $e');
        }
      }
      
      // Načítanie obrázkov odpovedí
      final List<dynamic> answersData = question['answers'] ?? [];
      for (var answer in answersData) {
        final answerImage = answer['image'];
        if (answerImage != null && answerImage.isNotEmpty) {
          try {
            final bytes = await _apiService.getImageBytes(answerImage);
            _imageCache[answerImage] = bytes;
          } catch (e) {
            print('Error preloading answer image: $e');
          }
        }
      }
    }
  }
  
  // Získanie obrázka z cache alebo z API
  Future<Uint8List?> _getImage(String imagePath) async {
    if (_imageCache.containsKey(imagePath)) {
      return _imageCache[imagePath];
    }
    
    try {
      final bytes = await _apiService.getImageBytes(imagePath);
      _imageCache[imagePath] = bytes;
      return bytes;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }
  
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_quizCompleted) {
        setState(() {
          _timeSpent = DateTime.now().millisecondsSinceEpoch - _startTime;
        });
        _startTimer();
      }
    });
  }
  
  // Formátovanie času do podoby mm:ss
  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Inicializácia odpovedí na základe otázok
  void _initializeAnswers() {
    _answers = List.generate(widget.questions.length, (index) {
      final question = widget.questions[index];
      
      // Najdeme správnu odpověď
      String? correctAnswerId;
      final List<dynamic> answersData = question['answers'] ?? [];
      for (var answer in answersData) {
        if (answer['correct'] == true) {
          // Uložíme ID odpovede, nielen text
          correctAnswerId = answer['_id'] ?? answersData.indexOf(answer).toString();
          break;
        }
      }
      
      return {
        'questionId': question['_id'] ?? index.toString(),
        'question': question['text'] ?? 'Otázka ${index + 1}',
        'answerId': null,
        'answer': null,
        'correctAnswerId': correctAnswerId,
        'isCorrect': false,
      };
    });
  }
  
  // Kontrola, či sú všetky otázky zodpovedané
  bool _areAllQuestionsAnswered() {
    return _answers.every((answer) => answer['answer'] != null);
  }
  
  // Počet správnych odpovedí
  int _getCorrectAnswersCount() {
    return _answers.where((answer) => answer['isCorrect'] == true).length;
  }
  
  // Odoslanie výsledkov kvízu
  void _submitQuiz() {
    setState(() {
      _quizCompleted = true;
      _timeSpent = DateTime.now().millisecondsSinceEpoch - _startTime;
    });
    
    // Pridanie časového údaju do odpovedí
    for (var answer in _answers) {
      answer['timeSpent'] = _timeSpent;
      answer['completed'] = true;
    }
    
    // Zobrazenie dialogu s výsledkom
    _showQuizResultDialog();
  }
  
  // Zobrazenie dialogu s výsledkom kvízu
  void _showQuizResultDialog() {
    final correctCount = _getCorrectAnswersCount();
    final totalCount = widget.questions.length;
    final percentScore = (correctCount / totalCount * 100).round();
    final perfectScore = correctCount == totalCount;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(perfectScore ? 'Výborne!' : 'Kvíz dokončený'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              perfectScore ? Icons.emoji_events : Icons.check_circle_outline,
              color: perfectScore ? Colors.amber : Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              perfectScore 
                  ? 'Úspešne si dokončil/a kvíz bez chyby!' 
                  : 'Úspešne si dokončil/a kvíz!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Tvoje skóre: $correctCount/$totalCount ($percentScore%)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Čas: ${_formatTime(_timeSpent)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Zatvorenie dialógu
                
                // Odoslanie výsledkov naspäť do rodičovského komponentu
                widget.onQuizCompleted(_answers, _timeSpent);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Dokončiť'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Zobrazenie dialógu s nápoveďou
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ako riešiť kvíz?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('Správne odpovede sa označia zelenou farbou'),
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Nesprávne odpovede sa označia červenou farbou'),
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue),
              title: Text('Po výbere odpovede už nie je možné ju zmeniť'),
            ),
            ListTile(
              leading: Icon(Icons.done_all, color: Colors.orange),
              title: Text('Pre dokončenie musíš odpovedať na všetky otázky'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Načítavam kvíz...'),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Skúsiť znova'),
            ),
          ],
        ),
      );
    }
    
    // Príprava pre kontrolu odpovedí
    final allQuestionsAnswered = _areAllQuestionsAnswered();
    final correctAnswers = _getCorrectAnswersCount();
    
    return Column(
      children: [
        // Informačný panel
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kvíz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zodpovedané: $correctAnswers/${widget.questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Čas: ${_formatTime(_timeSpent)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Tlačidlo na zobrazenie nápovedy
                  Tooltip(
                    message: 'Nápoveda',
                    child: InkWell(
                      onTap: _showHelpDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.questions.isNotEmpty ? correctAnswers / widget.questions.length : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
        ),
        
        // Otázky
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.questions.length,
            itemBuilder: (context, index) {
              final question = widget.questions[index];
              final questionId = question['_id'] ?? index.toString();
              final questionImage = question['image'];
              
              // Zpracování struktury dat pro odpovědi
              final List<dynamic> answersData = question['answers'] ?? [];
              
              // Nájdeme správnou odpověď a jej ID
              String? correctAnswerId;
              String? correctAnswerText;
              for (var answer in answersData) {
                if (answer['correct'] == true) {
                  correctAnswerId = answer['_id'] ?? answersData.indexOf(answer).toString();
                  correctAnswerText = answer['text'];
                  break;
                }
              }
              
              // Nájdeme odpoveď pre túto otázku
              final answerIndex = _answers.indexWhere((a) => a['questionId'] == questionId);
              if (answerIndex == -1) return const SizedBox(); // Nemalo by sa stať
              
              // Aktualizujeme correctAnswer v _answers listu
              if (_answers[answerIndex]['correctAnswerId'] == null && correctAnswerId != null) {
                _answers[answerIndex]['correctAnswerId'] = correctAnswerId;
              }
              
              final selectedAnswerId = _answers[answerIndex]['answerId'];
              final selectedAnswer = _answers[answerIndex]['answer'];
              final isAnswered = selectedAnswer != null;
              // Porovnávame ID, nie texty (kvôli možným duplicitám)
              final isCorrect = isAnswered && selectedAnswerId == correctAnswerId;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Číslo a text otázky
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAnswered 
                                  ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Otázka ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAnswered 
                                    ? (isCorrect ? Colors.green.shade800 : Colors.red.shade800)
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isAnswered)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question['text'] ?? 'Neznáma otázka',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Obrázok k otázke (ak existuje)
                      if (questionImage != null && questionImage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // Rezervované miesto pre obrázok s fixnou výškou
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FutureBuilder<Uint8List?>(
                            future: _getImage(questionImage),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              } else {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Možnosti odpovede
                      ...answersData.asMap().entries.map((entry) {
                        final answerIndex = entry.key;
                        final answer = entry.value;
                        final answerId = answer['_id'] ?? answerIndex.toString();
                        final answerText = answer['text'] as String;
                        final answerImage = answer['image'];
                        final isCorrectOption = answerId == correctAnswerId;
                        final isSelected = selectedAnswerId == answerId;
                        
                        // Určenie farby pozadia pre možnosť
                        Color? tileColor;
                        if (isAnswered) {
                          if (isSelected && isCorrect) {
                            tileColor = Colors.green.withOpacity(0.1);
                          } else if (isSelected && !isCorrect) {
                            tileColor = Colors.red.withOpacity(0.1);
                          } else if (isCorrectOption) {
                            tileColor = Colors.green.withOpacity(0.05);
                          }
                        } else if (isSelected) {
                          tileColor = Colors.orange.withOpacity(0.1);
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isAnswered && isCorrectOption
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(answerText),
                                value: answerId,
                                groupValue: selectedAnswerId,
                                onChanged: isAnswered // Zabránime zmene, ak už otázka bola zodpovedaná
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _answers[answerIndex]['answerId'] = value;
                                          _answers[answerIndex]['answer'] = answerText;
                                          _answers[answerIndex]['isCorrect'] = value == correctAnswerId;
                                        });
                                      },
                                activeColor: Colors.orange,
                                contentPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              
                              // Obrázok k odpovedi (ak existuje)
                              if (answerImage != null && answerImage.isNotEmpty) ...[
                                // Rezervované miesto pre obrázok s fixnou výškou
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 32, bottom: 12, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FutureBuilder<Uint8List?>(
                                      future: _getImage(answerImage),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                          return const Center(
                                            child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                          );
                                        } else {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Tlačidlo na dokončenie kvízu
        if (!_quizCompleted)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allQuestionsAnswered ? _submitQuiz : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  allQuestionsAnswered ? 'Dokončiť kvíz' : 'Zodpovedaj všetky otázky',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
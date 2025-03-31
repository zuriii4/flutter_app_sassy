import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';
import 'package:sassy/widgets/form_fields.dart';
import 'package:sassy/services/api_service.dart';

class QuizContent extends StatefulWidget {
  final TaskModel taskModel;
  
  const QuizContent({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  String? _questionImagePath;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Načítame existujúce otázky, ak existujú
    if (widget.taskModel.content.containsKey('questions')) {
      _questions.addAll(List<Map<String, dynamic>>.from(widget.taskModel.content['questions']));
    } else {
      widget.taskModel.content['questions'] = _questions;
    }
  }

  void _addQuestion() {
    if (_questionController.text.isEmpty) return;
    
    setState(() {
      final newQuestion = {
        'text': _questionController.text,
        'answers': [],
        if (_questionImagePath != null) 'image': _questionImagePath,
      };
      
      _questions.add(newQuestion);
      widget.taskModel.content['questions'] = _questions;
      
      // Reset fields
      _questionController.clear();
      _questionImagePath = null;
    });
  }

  void _addAnswer(int questionIndex) {
    final TextEditingController answerController = TextEditingController();
    bool isCorrect = false;
    String? answerImagePath;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Pridať odpoveď'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormTextField(
                    label: 'Text odpovede',
                    placeholder: 'Zadajte text odpovede',
                    controller: answerController,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Správna odpoveď'),
                    value: isCorrect,
                    onChanged: (value) {
                      setDialogState(() {
                        isCorrect = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Použitie FormImagePicker pre výber obrázka odpovede
                  FormImagePicker(
                    label: 'Obrázok odpovede',
                    onImagePathSelected: (path) {
                      setDialogState(() {
                        answerImagePath = path;
                      });
                    },
                    initialImagePath: answerImagePath,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zrušiť'),
              ),
              TextButton(
                onPressed: () {
                  if (answerController.text.isNotEmpty) {
                    setState(() {
                      final answer = {
                        'text': answerController.text,
                        'correct': isCorrect,
                      };
                      
                      if (answerImagePath != null) {
                        answer['image'] = answerImagePath as Object;
                      }
                      
                      _questions[questionIndex]['answers'].add(answer);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Pridať'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      widget.taskModel.content['questions'] = _questions;
    });
  }

  void _onQuestionImageSelected(String path) {
    setState(() {
      _questionImagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vytvorenie kvízu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF67E4A),
              ),
            ),
            const SizedBox(height: 20),
            
            // Pridanie novej otázky
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nová otázka',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormTextField(
                      label: 'Text otázky',
                      placeholder: 'Zadajte text otázky',
                      controller: _questionController,
                    ),
                    const SizedBox(height: 16),
                    
                    // Použitie FormImagePicker pre výber obrázka otázky
                    FormImagePicker(
                      label: 'Obrázok otázky',
                      onImagePathSelected: _onQuestionImageSelected,
                      initialImagePath: _questionImagePath,
                    ),
                    
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF67E4A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pridať otázku'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Zoznam existujúcich otázok
            if (_questions.isNotEmpty) ...[
              const Text(
                'Existujúce otázky',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final answers = List<Map<String, dynamic>>.from(question['answers'] ?? []);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Otázka ${index + 1}: ${question['text']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeQuestion(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                          
                          // Zobrazenie obrázka otázky
                          if (question.containsKey('image') && question['image'] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Obrázok otázky:'),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          _apiService.getImageUrl(question['image']),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 8),
                          
                          // Odpovede
                          if (answers.isEmpty)
                            const Text('Žiadne odpovede'),
                          ...answers.map((answer) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.grey[50],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        answer['correct'] ? Icons.check_circle : Icons.cancel,
                                        color: answer['correct'] ? Colors.green : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          answer['text'],
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Zobrazenie obrázka odpovede
                                  if (answer.containsKey('image') && answer['image'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, left: 24.0),
                                      child: Container(
                                        height: 80,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              _apiService.getImageUrl(answer['image']),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )).toList(),
                          
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _addAnswer(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF67E4A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Pridať odpoveď'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Zatiaľ nie sú pridané žiadne otázky',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
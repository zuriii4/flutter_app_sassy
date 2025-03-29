import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';

class QuizContent extends StatefulWidget {
  final TaskModel taskModel;
  
  const QuizContent({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  bool _showImageSelection = false;
  String? _selectedImage;

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
        if (_selectedImage != null) 'image': _selectedImage,
      };
      
      _questions.add(newQuestion);
      widget.taskModel.content['questions'] = _questions;
      
      // Reset fields
      _questionController.clear();
      _selectedImage = null;
      _showImageSelection = false;
    });
  }

  void _addAnswer(int questionIndex) {
    final TextEditingController answerController = TextEditingController();
    bool isCorrect = false;
    String? answerImage;
    bool showImageSelection = false;
    
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
                  TextField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      labelText: 'Text odpovede',
                      border: OutlineInputBorder(),
                    ),
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
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            showImageSelection = !showImageSelection;
                          });
                        },
                        icon: const Icon(Icons.image),
                        label: Text(answerImage == null 
                          ? 'Pridať obrázok' 
                          : 'Zmeniť obrázok'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF67E4A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (answerImage != null)
                        Expanded(
                          child: Text(
                            'Vybraný obrázok: $answerImage',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  if (showImageSelection)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vyberte obrázok:'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    answerImage = 'odpoved1.jpg';
                                    showImageSelection = false;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                    border: answerImage == 'odpoved1.jpg'
                                        ? Border.all(color: const Color(0xFFF67E4A), width: 2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'odpoved1.jpg',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    answerImage = 'odpoved2.jpg';
                                    showImageSelection = false;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                    border: answerImage == 'odpoved2.jpg'
                                        ? Border.all(color: const Color(0xFFF67E4A), width: 2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'odpoved2.jpg',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                    ),
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
                      
                      if (answerImage != null) {
                        answer['image'] = answerImage as Object;
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

  void _toggleImageSelection() {
    setState(() {
      _showImageSelection = !_showImageSelection;
    });
  }

  void _selectImage(String imagePath) {
    setState(() {
      _selectedImage = imagePath;
      _showImageSelection = false;
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
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Text otázky',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleImageSelection,
                          icon: const Icon(Icons.image),
                          label: Text(_selectedImage == null 
                            ? 'Pridať obrázok' 
                            : 'Zmeniť obrázok'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF67E4A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_selectedImage != null)
                          Expanded(
                            child: Text(
                              'Vybraný obrázok: $_selectedImage',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    if (_showImageSelection)
                      _buildImageSelectionWidget(),
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
                          if (question.containsKey('image') && question['image'] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('Obrázok: ${question['image']}'),
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
                                  if (answer.containsKey('image') && answer['image'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0, left: 24.0),
                                      child: Text(
                                        'Obrázok: ${answer['image']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
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

  Widget _buildImageSelectionWidget() {
    // Placeholder pre výber obrázku - v reálnej aplikácii by sa tu nachádzala galéria alebo upload
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vyberte obrázok:'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildImageTile('obrazok1.jpg'),
              _buildImageTile('obrazok2.jpg'),
              _buildImageTile('obrazok3.jpg'),
              _buildImageTile('obrazok4.jpg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String imagePath) {
    return InkWell(
      onTap: () => _selectImage(imagePath),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
          border: _selectedImage == imagePath
              ? Border.all(color: const Color(0xFFF67E4A), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            imagePath,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}
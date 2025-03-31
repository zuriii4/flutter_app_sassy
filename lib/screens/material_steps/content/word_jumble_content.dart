import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';
import 'package:sassy/widgets/form_fields.dart';

class WordJumbleContent extends StatefulWidget {
  final TaskModel taskModel;
  
  const WordJumbleContent({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<WordJumbleContent> createState() => _WordJumbleContentState();
}

class _WordJumbleContentState extends State<WordJumbleContent> {
  final TextEditingController _wordController = TextEditingController();
  List<String> _words = [];
  List<String> _correctOrder = [];
  List<String> _shuffledWords = [];

  @override
  void initState() {
    super.initState();
    // Načítanie existujúcich hodnôt, ak existujú
    if (widget.taskModel.content.isNotEmpty) {
      if (widget.taskModel.content.containsKey('words')) {
        _words = List<String>.from(widget.taskModel.content['words']);
        _shuffledWords = List<String>.from(_words);
      }
      
      if (widget.taskModel.content.containsKey('correct_order')) {
        _correctOrder = List<String>.from(widget.taskModel.content['correct_order']);
      } else {
        _correctOrder = List<String>.from(_words);
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _updateModel() {
    widget.taskModel.setWordJumbleContent(_words, _correctOrder);
  }

  void _addWord() {
    if (_wordController.text.isEmpty) return;
    
    setState(() {
      final newWord = _wordController.text.trim();
      _words.add(newWord);
      _correctOrder.add(newWord);
      _shuffledWords = List<String>.from(_words);
      _wordController.clear();
      _updateModel();
    });
  }

  void _removeWord(int index) {
    setState(() {
      final removedWord = _words[index];
      _words.removeAt(index);
      
      // Odstránenie slova aj zo správneho poradia
      _correctOrder.remove(removedWord);
      _shuffledWords.remove(removedWord);
      
      _updateModel();
    });
  }

  void _shuffleWords() {
    setState(() {
      _shuffledWords = List<String>.from(_words);
      _shuffledWords.shuffle();
      
      // Uloženie zamešaného poradia
      _correctOrder = List<String>.from(_words);
      _updateModel();
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _correctOrder.removeAt(oldIndex);
      _correctOrder.insert(newIndex, item);
      _updateModel();
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
              'Vytvorenie slovného prešmyčku',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF67E4A),
              ),
            ),
            const SizedBox(height: 20),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pridať slová',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                            label: 'Nové slovo',
                            placeholder: 'Zadajte nové slovo',
                            controller: _wordController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _addWord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF67E4A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pridať'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    if (_words.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Slová v úlohe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _shuffleWords,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF67E4A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Náhodne zamiešať'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _words.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey[100],
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(_words[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeWord(index),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Správne poradie (preusporiadajte)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: _onReorder,
                          children: _correctOrder.map((word) {
                            return ListTile(
                              key: ValueKey(word),
                              title: Text(word),
                              trailing: const Icon(Icons.drag_handle),
                            );
                          }).toList(),
                        ),
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Pridajte aspoň jedno slovo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
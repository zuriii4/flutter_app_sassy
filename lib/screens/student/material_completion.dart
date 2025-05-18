import 'package:flutter/material.dart';
import 'package:sassy/screens/student/materials/connection/connection_board.dart';
import 'package:sassy/screens/student/materials/puzzle/puzzle_board.dart';
import 'package:sassy/screens/student/materials/quiz/quiz_board.dart';
import 'package:sassy/screens/student/materials/word_jumble/word_jumble_board.dart';
import 'package:sassy/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sassy/widgets/material_card.dart';

class MaterialCompletionScreen extends StatefulWidget {
  final Map<String, dynamic> material;
  final String materialId;

  const MaterialCompletionScreen({
    Key? key,
    required this.material,
    required this.materialId,
  }) : super(key: key);

  @override
  State<MaterialCompletionScreen> createState() => _MaterialCompletionScreenState();
}

class _MaterialCompletionScreenState extends State<MaterialCompletionScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Dynamické odpovede študenta
  List<Map<String, dynamic>> _answers = [];
  
  // Stav dokončenia
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  // Inicializácia štruktúry odpovedí na základe typu materiálu
  void _initializeAnswers() {
    final materialType = widget.material['type']?.toLowerCase() ?? 'unknown';
    
    switch (materialType) {
      case 'quiz':
        final questions = widget.material['content']?['questions'] ?? [];
        _answers = List.generate(questions.length, (index) {
          return {
            'questionId': questions[index]['_id'] ?? index.toString(),
            'answer': null,
          };
        });
        break;
        
      case 'puzzle':
        // Pre puzzle inicializujeme prázdne riešenie
        _answers = [
          {
            'solvedGrid': [], // Pozície puzzle dielov budú zaznamenané tu
            'timeSpent': 0,   // Čas strávený riešením
            'completed': false,
          }
        ];
        break;
        
      case 'connection':
        // Pre spojovačku/čiarky inicializujeme odpovede
        final items = widget.material['content']?['items'] ?? [];
        _answers = [
          {
            'connections': [], // Pole spojení [id1, id2]
            'timeSpent': 0,
            'completed': false,
          }
        ];
        break;
        
      case 'word-jumble':
        // Pre slovné hádanky
        _answers = [
          {
            'arrangedWords': [], // Usporiadané slová
            'timeSpent': 0,
            'completed': false,
          }
        ];
        break;
        
      default:
        // Obecný formát pre akýkoľvek typ
        _answers = [
          {
            'response': null,
            'timeSpent': 0,
            'completed': false,
          }
        ];
    }
  }

  // Update the _submitMaterial method to properly format the submission data
  Future<void> _submitMaterial() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Získanie userId zo SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId');
      
      if (studentId == null) {
        throw Exception('Používateľ nie je prihlásený');
      }

      // // Debug výstup před odesláním
      // print('ODESÍLANÁ DATA:');
      // print('studentId: $studentId');
      // print('materialId: ${widget.materialId}');
      // print('answers:');
      // print(jsonEncode(_answers));

      // Zajistíme, že každý záznam v _answers má požadovaná metadata (_id, timeSpent, completed, completedAt)
      final formattedAnswers = _answers.map((answer) {
        final Map<String, dynamic> updatedAnswer = Map.from(answer);

        // Ensure material ID or questionId is present
        if (!updatedAnswer.containsKey('_id') && !updatedAnswer.containsKey('questionId')) {
          updatedAnswer['_id'] = widget.materialId;
        }

        // Add default timeSpent if missing
        if (!updatedAnswer.containsKey('timeSpent') || updatedAnswer['timeSpent'] == 0) {
          updatedAnswer['timeSpent'] = DateTime.now().millisecondsSinceEpoch - _startTime;
        }

        // Add completed if missing
        if (!updatedAnswer.containsKey('completed')) {
          updatedAnswer['completed'] = true;
        }

        // Add timestamp if missing
        if (!updatedAnswer.containsKey('completedAt')) {
          updatedAnswer['completedAt'] = DateTime.now().toIso8601String();
        }

        return updatedAnswer;
      }).toList();

      // // Debug výstup po formátování
      // print('FORMÁTOVANÁ DATA PRO ODESLÁNÍ:');
      // print(jsonEncode(formattedAnswers));

      // Odoslanie odpovedí pomocou API služby
      final success = await _apiService.submitMaterial(
        studentId: studentId,
        materialId: widget.materialId,
        answers: formattedAnswers,
      );

      setState(() {
        _isSubmitting = false;
        if (success) {
          _isCompleted = true;
          if (_successMessage == null) {
            _successMessage = 'Výborne! Materiál bol úspešne dokončený.';
          }
        } else {
          _errorMessage = 'Nepodarilo sa odoslať odpovede.';
        }
      });
      
      if (success) {
        // Zobrazíme dialóg s úspechom
        _showCompletionDialog();
      }
    } catch (e) {
      print('❌ Chyba pri odosielaní materiálu: $e');
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Chyba: ${e.toString()}';
      });
    }
  }

  // Dialóg po úspešnom dokončení
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Gratulujeme!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Úspešne si dokončil/a tento materiál!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zatvorí dialóg
                Navigator.of(context).pop(true); // Vráti sa na predchádzajúcu obrazovku s úspechom
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Späť na prehľad'),
            ),
          ],
        ),
      ),
    );
  }

  // Čas začiatku práce na materiále
  final int _startTime = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final materialType = widget.material['type']?.toLowerCase() ?? 'unknown';
    final title = widget.material['title'] ?? 'Materiál';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2EA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        backgroundColor: MaterialUtils.getTypeColor(materialType),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isCompleted)
            TextButton.icon(
              onPressed: _isSubmitting ? null : _submitMaterial,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Dokončiť',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMaterialContent(materialType),
    );
  }

  // Hlavný obsah na základe typu materiálu
  Widget _buildMaterialContent(String materialType) {
    // Zobrazenie správy o chybe
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Späť'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Zobrazenie správy o úspechu
    if (_successMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                _successMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Späť na prehľad'),
              ),
            ],
          ),
        ),
      );
    }

    // Voľba typu obsahu
    switch (materialType) {
      case 'quiz':
        return _buildQuizInterface();
      case 'puzzle':
        return _buildPuzzleInterface();
      case 'connection':
        return _buildConnectionInterface();
      case 'word-jumble':
        return _buildWordJumbleInterface();
      default:
        return const Text(
          "Neznami material"
        );
    }
  }
  

  
  // Rozhranie pre kvíz
  // Updated implementation of _buildQuizInterface using the QuizWorkspace component
  Widget _buildQuizInterface() {
  final questions = widget.material['content']?['questions'] ?? [];
  
  if (questions.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Tento kvíz neobsahuje žiadne otázky',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Späť'),
          ),
        ],
      ),
    );
  }
  
  return QuizWorkspace(
    questions: questions,
    materialId: widget.materialId,
    onQuizCompleted: (answers, timeSpent) {
      // Aktualizácia odpovedí po dokončení kvízu
      setState(() {
        _answers = answers;
        
        // Nastavenie správy o úspechu
        final correctAnswers = answers.where((a) => a['isCorrect'] == true).length;
        final totalQuestions = questions.length;
        final percentCorrect = (correctAnswers / totalQuestions * 100).round();
        
        _successMessage = 'Výborne! Kvíz si úspešne dokončil/a so skóre $correctAnswers/$totalQuestions ($percentCorrect%) za ${_formatTime(timeSpent)}.';
      });
      
      // Automatické odoslanie odpovede na server
      _submitMaterial();
    },
  );
}

 // Add this method to your _MaterialCompletionScreenState class
  Widget _buildPuzzleInterface() {
    final grid = widget.material['content']?['grid'] ?? {};
    final int columns = grid['columns'] ?? 3;
    final int rows = grid['rows'] ?? 3;
    final String? imagePath = widget.material['content']?['image'];
    
    if (imagePath == null || imagePath.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Pre tento materiál nie je k dispozícii žiadny obrázok',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Späť'),
            ),
          ],
        ),
      );
    }
    
    return PuzzleWorkspace(
      imagePath: imagePath,
      rows: rows,
      columns: columns,
      materialId: widget.materialId,
      onPuzzleSolved: (arrangement, timeSpent) {
        // Převedení hodnot na string array
        final solvedGridStringArray = arrangement.map((index) => index.toString()).toList();
        
        // DŮLEŽITÁ OPRAVA: Přidáno ID materiálu a konzistentní struktura
        setState(() {
          _answers = [
            {
              "_id": widget.materialId,  // Přidáno ID materiálu - klíčové pro správné zpracování
              "solvedGrid": solvedGridStringArray,
              "timeSpent": timeSpent,
              "completed": true,
              "completedAt": DateTime.now().toIso8601String(),
            }
          ];
          
          _successMessage = 'Výborne! Puzzle si úspešne vyriešil/a za ${_formatTime(timeSpent)}';
        });
        // Automatické odeslání dat na server
        _submitMaterial();
      },
    );
  }


  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Rozhranie pre spojovačku
  Widget _buildConnectionInterface() {
    final Map<String, dynamic> content = widget.material['content'] ?? {};
    final List<dynamic> items = content['pairs'] ?? [];
    
    // Pokud nejsou žádná data, zobrazíme zprávu
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Táto spojovačka neobsahuje žiadne položky',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Späť'),
            ),
          ],
        ),
      );
    }
    
    // Zpracování dat pro ConnectionWorkspace
    List<ConnectionPair> pairs = [];
    
    // Analýza formátu dat
    if (items.isNotEmpty) {
      // Formát 1: Seznam objektů s left a right vlastnostmi
      if (items[0] is Map && items[0].containsKey('left') && items[0].containsKey('right')) {
        for (var item in items) {
          pairs.add(ConnectionPair(
            left: item['left']?.toString() ?? '',
            right: item['right']?.toString() ?? '',
          ));
        }
      }
      // Formát 2: Seznam objektů ve tvaru [{"terms": [...], "definitions": [...]}, ...]
      else if (items[0] is Map && items[0].containsKey('terms') && items[0].containsKey('definitions')) {
        final terms = List<String>.from(items[0]['terms'] ?? []);
        final definitions = List<String>.from(items[0]['definitions'] ?? []);
        
        // Vytvoříme páry, pokud máme stejný počet pojmů a definic
        int count = terms.length < definitions.length ? terms.length : definitions.length;
        for (int i = 0; i < count; i++) {
          pairs.add(ConnectionPair(
            left: terms[i],
            right: definitions[i],
          ));
        }
      }
    }
    
    // Získáme další nastavení
    final String instruction = content['instruction'] ?? 'Spoj k sebe zodpovedajúce položky:';
    final Color primaryColor = _getColorFromString(content['primaryColor'], const Color(0xFF5D69BE));
    final Color secondaryColor = _getColorFromString(content['secondaryColor'], const Color(0xFF42A5F5));
    
    return ConnectionWorkspace(
      pairs: pairs,
      instruction: instruction,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      onCompleted: (isCorrect, timeSpent) {
        // DŮLEŽITÁ OPRAVA: Aktualizace _answers se správnými daty
        setState(() {
          _answers = [
            {
              "_id": widget.materialId, // Přidáme ID materiálu
              "connections": pairs.map((pair) => {
                "left": pair.left,
                "right": pair.right,
                "isConnected": pair.isConnected
              }).toList(),
              "timeSpent": timeSpent,
              "completed": true
            }
          ];
          
          // Nastavíme zprávu o úspěšném dokončení
          _successMessage = 'Výborne! Spojovačku si dokončil/a za ${_formatTime(timeSpent)}.';
        });
        
        // Odešleme aktualizovaná data
        _submitMaterial();
      },
    );
  }

// Opravená část pro WordJumbleWorkspace
  Widget _buildWordJumbleInterface() {
    final Map<String, dynamic> content = widget.material['content'] ?? {};
    final List<dynamic> wordsData = content['words'] ?? [];
    
    // Pokud nejsou žádná data, zobrazíme zprávu
    if (wordsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Táto slovná hádanka neobsahuje žiadne slová',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Späť'),
            ),
          ],
        ),
      );
    }
    
    // Zkonvertujeme dynamic data na String listy
    List<String> words = [];
    List<String> correctOrder = [];
    
    // Zjistíme, jaký formát dat máme
    // Formát 1: Seznam slov jako stringy
    if (wordsData.isNotEmpty && wordsData[0] is String) {
      words = wordsData.map<String>((word) => word.toString()).toList();
      // Pro tento formát je správné pořadí stejné jako původní pořadí
      correctOrder = List.from(words);
    }
    // Formát 2: Seznam objektů s textem a pořadím
    else if (wordsData.isNotEmpty && wordsData[0] is Map) {
      // Uspořádáme slova podle pořadí (pokud je k dispozici)
      final List<Map<String, dynamic>> wordObjects = wordsData
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
      
      // Seřadíme podle 'order' atributu, pokud existuje
      if (wordObjects.isNotEmpty && wordObjects[0].containsKey('order')) {
        wordObjects.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
      }
      
      // Extrahujeme texty
      words = wordObjects.map<String>((item) => item['text']?.toString() ?? '').toList();
      correctOrder = List.from(words);
    }
    
    // Získáme další nastavení
    final String instruction = content['instruction'] ?? 'Poskladaj vetu:';
    final Color primaryColor = _getColorFromString(content['primaryColor'], const Color(0xFF5D69BE));
    final Color secondaryColor = _getColorFromString(content['secondaryColor'], const Color(0xFF42A5F5));
    
    return WordJumbleWorkspace(
      words: words,
      correctOrder: correctOrder,
      instruction: instruction,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      onCompleted: (isCorrect, timeSpent) {  // Upravený callback s přidaným timeSpent parametrem
        if (isCorrect) {
          // DŮLEŽITÁ OPRAVA: Aktualizace _answers se správnými daty
          setState(() {
            _answers = [
              {
                "_id": widget.materialId, // Přidáme ID materiálu
                "arrangedWords": correctOrder,
                "timeSpent": timeSpent,
                "completed": true
              }
            ];
            
            // Nastavíme zprávu o úspěšném dokončení
            _successMessage = 'Výborne! Slovnú hádanku si dokončil/a za ${_formatTime(timeSpent)}.';
          });
          
          // Odešleme aktualizovaná data
          _submitMaterial();
        }
      },
    );
  }

  // Pomocná metoda pro konverzi barvy z řetězce
  Color _getColorFromString(dynamic colorStr, Color defaultColor) {
    if (colorStr == null) return defaultColor;
    
    // Pokud je barva ve formátu '#RRGGBB' nebo 'RRGGBB'
    String hexColor = colorStr.toString().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Přidáme plnou neprůhlednost
    }
    
    // Pokusíme se převést na int hodnotu
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }
}
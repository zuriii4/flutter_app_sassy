import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/widgets/form_fields.dart';
import 'package:sassy/screens/teacher/material_steps/previews/preview_builder.dart';
import 'package:image_picker/image_picker.dart';

class MaterialEditScreen extends StatefulWidget {
  final Map<String, dynamic> material;
  
  const MaterialEditScreen({super.key, required this.material});

  @override
  State<MaterialEditScreen> createState() => _MaterialEditScreenState();
}

class _MaterialEditScreenState extends State<MaterialEditScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isInteractivePreview = false;
  File? _imageFile;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late Map<String, dynamic> _content;
  
  // Specific controllers based on type
  // Puzzle
  late TextEditingController _gridSizeController;
  
  // Quiz
  final List<Map<String, dynamic>> _questions = [];
  
  // Word Jumble
  final List<String> _words = [];
  final List<String> _correctOrder = [];
  
  // Connections
  final List<Map<String, String>> _pairs = [];

  @override
  void initState() {
    super.initState();
    // Initialize main controllers
    _titleController = TextEditingController(text: widget.material['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.material['description'] ?? '');
    _selectedType = widget.material['type'] ?? 'puzzle';
    _content = Map<String, dynamic>.from(widget.material['content'] ?? {});
    
    // Initialize type-specific controllers and data
    _initializeTypeSpecificData();
  }

  void _initializeTypeSpecificData() {
    switch (_selectedType.toLowerCase()) {
      case 'puzzle':
        _initializePuzzleData();
        break;
      case 'quiz':
        _initializeQuizData();
        break;
      case 'word-jumble':
        _initializeWordJumbleData();
        break;
      case 'connection':
        _initializeConnectionsData();
        break;
    }
  }

  void _initializePuzzleData() {
    final gridData = _content['grid'] ?? {};
    final int gridSize = gridData['columns'] ?? 3;
    _gridSizeController = TextEditingController(text: gridSize.toString());
  }

  void _initializeQuizData() {
    if (_content.containsKey('questions')) {
      _questions.addAll(List<Map<String, dynamic>>.from(_content['questions']));
    }
  }

  void _initializeWordJumbleData() {
    if (_content.containsKey('words')) {
      _words.addAll(List<String>.from(_content['words']));
    }
    
    if (_content.containsKey('correct_order')) {
      _correctOrder.addAll(List<String>.from(_content['correct_order']));
    } else {
      _correctOrder.addAll(List<String>.from(_words));
    }
  }

  void _initializeConnectionsData() {
    if (_content.containsKey('pairs')) {
      final List<dynamic> rawPairs = _content['pairs'];
      _pairs.addAll(rawPairs.map((pair) => {
        'left': pair['left'] as String,
        'right': pair['right'] as String,
      }));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _gridSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _updateGridSize() async {
    try {
      int newSize = int.parse(_gridSizeController.text);
      
      if (newSize > 0) {
        setState(() {
          _content['grid'] = {
            'columns': newSize,
            'rows': newSize
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veľkosť mriežky bola aktualizovaná')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veľkosť musí byť väčšia ako 0')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neplatná hodnota pre veľkosť mriežky')),
      );
    }
  }

  Future<void> _saveMaterial() async {
    setState(() => _isLoading = true);
    
    try {
      // Update content based on selected type
      _updateContentBasedOnType();
      
      // Call API to update material
      final success = await _apiService.updateMaterial(
        materialId: widget.material['_id'],
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        content: _content,
        imageFile: _imageFile,
      );
      
      setState(() => _isLoading = false);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materiál bol úspešne aktualizovaný')),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nepodarilo sa aktualizovať materiál')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri aktualizácii materiálu: $e')),
        );
      }
    }
  }

  void _updateContentBasedOnType() {
    switch (_selectedType.toLowerCase()) {
      case 'puzzle':
        // Already updated through the UI
        break;
      case 'quiz':
        _content['questions'] = _questions;
        break;
      case 'word-jumble':
        _content['words'] = _words;
        _content['correct_order'] = _correctOrder;
        break;
      case 'connection':
        _content['pairs'] = _pairs;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upraviť materiál'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Uložiť zmeny',
            onPressed: _saveMaterial,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Základné informácie
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Základné informácie',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            label: 'Názov',
                            placeholder: 'Zadajte názov materiálu',
                            controller: _titleController,
                          ),
                          const SizedBox(height: 16),
                          FormTextField(
                            label: 'Popis',
                            placeholder: 'Zadajte popis materiálu',
                            controller: _descriptionController,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Typ materiálu',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedType,
                            items: const [
                              DropdownMenuItem(
                                  value: 'puzzle', child: Text('Puzzle')),
                              DropdownMenuItem(
                                  value: 'quiz', child: Text('Quiz')),
                              DropdownMenuItem(
                                  value: 'word-jumble',
                                  child: Text('Word Jumble')),
                              DropdownMenuItem(
                                  value: 'connection',
                                  child: Text('Connections')),
                            ],
                            onChanged: null, // Typ sa nedá meniť
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Type-specific settings
                  _buildTypeSpecificSettings(),
                  const SizedBox(height: 24),
                  // Preview
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Náhľad materiálu',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Text('Interaktívny režim'),
                                  Switch(
                                    value: _isInteractivePreview,
                                    onChanged: (value) {
                                      setState(() {
                                        _isInteractivePreview = value;
                                      });
                                    },
                                    activeColor: const Color(0xFFF67E4A),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MaterialPreviewBuilder.buildPreview(
                            _selectedType,
                            _content,
                            _apiService,
                            isInteractive: _isInteractivePreview,
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

  Widget _buildTypeSpecificSettings() {
    switch (_selectedType.toLowerCase()) {
      case 'puzzle':
        return _buildPuzzleSettings();
      case 'quiz':
        return _buildQuizSettings();
      case 'word-jumble':
        return _buildWordJumbleSettings();
      case 'connection':
        return _buildConnectionsSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPuzzleSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nastavenia puzzle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Image selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Obrázok puzzle'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(_imageFile != null 
                        ? 'Nový obrázok: ${_imageFile!.path.split('/').last}'
                        : _content['image'] != null 
                          ? 'Aktuálny obrázok: ${_content['image'].toString().split('/').last}'
                          : 'Žiadny obrázok nie je vybraný'
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF67E4A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Vybrať obrázok'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Grid size
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Veľkosť mriežky'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gridSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Počet stĺpcov/riadkov',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _updateGridSize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF67E4A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aktualizovať'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nastavenia kvízu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Redirect to QuizContent for detailed editing
                    // (Out of scope for this implementation)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pre komplexnú úpravu kvízu použite samostatnú obrazovku')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF67E4A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Detailná úprava'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Počet otázok: ${_questions.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildWordJumbleSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nastavenia word jumble',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Redirect to WordJumbleContent for detailed editing
                    // (Out of scope for this implementation)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pre komplexnú úpravu word jumble použite samostatnú obrazovku')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF67E4A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Detailná úprava'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Počet slov: ${_words.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nastavenia connections',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Redirect to ConnectionContent for detailed editing
                    // (Out of scope for this implementation)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pre komplexnú úpravu connections použite samostatnú obrazovku')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF67E4A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Detailná úprava'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Počet párov: ${_pairs.length}'),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sassy/models/material.dart';
import 'package:sassy/widgets/form_fields.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/screens/teacher/material_steps/previews/puzzle_preview.dart';

class PuzzleContent extends StatefulWidget {
  final TaskModel taskModel;
  
  const PuzzleContent({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<PuzzleContent> createState() => _PuzzleContentState();
}

class _PuzzleContentState extends State<PuzzleContent> {
  String? _serverImagePath;
  int _gridSize = 3;
  final ApiService _apiService = ApiService();
  
  // Kontrolér pre veľkosť mriežky
  final TextEditingController _gridColumnsController = TextEditingController();
  final TextEditingController _gridRowsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Načítanie existujúcich hodnôt, ak existujú
    if (widget.taskModel.content.isNotEmpty) {
      if (widget.taskModel.content.containsKey('image')) {
        _serverImagePath = widget.taskModel.content['image'];
      }
      
      if (widget.taskModel.content.containsKey('grid')) {
        // Použijeme hodnotu stĺpcov ako našu veľkosť mriežky (štvorcová)
        _gridSize = widget.taskModel.content['grid']['columns'] ?? 3;
        // Aktualizujeme aj riadky, aby bola mriežka štvorcová
        widget.taskModel.content['grid']['rows'] = _gridSize;
      } else {
        // Inicializácia mriežky, ak neexistuje
        widget.taskModel.content['grid'] = {
          'columns': _gridSize,
          'rows': _gridSize
        };
      }
    } else {
      // Inicializácia prázdneho obsahu
      widget.taskModel.content = {
        'grid': {
          'columns': _gridSize,
          'rows': _gridSize
        }
      };
    }
    
    // Nastavenie kontroléru
    _gridColumnsController.text = _gridSize.toString();
    _gridRowsController.text = _gridSize.toString();
    
    // Pridanie listenerov na kontroléry
    _gridColumnsController.addListener(_syncColumnRowValues);
    _gridRowsController.addListener(_syncRowColumnValues);
  }
  
  // Synchronizácia hodnôt - keď sa zmenia stĺpce, zmenia sa aj riadky
  void _syncColumnRowValues() {
    // Zabránime nekonečnému cyklu aktualizácií
    if (_gridColumnsController.text != _gridRowsController.text) {
      _gridRowsController.text = _gridColumnsController.text;
    }
  }
  
  // Synchronizácia hodnôt - keď sa zmenia riadky, zmenia sa aj stĺpce
  void _syncRowColumnValues() {
    // Zabránime nekonečnému cyklu aktualizácií
    if (_gridRowsController.text != _gridColumnsController.text) {
      _gridColumnsController.text = _gridRowsController.text;
    }
  }
  
  @override
  void dispose() {
    // Odstránenie listenerov
    _gridColumnsController.removeListener(_syncColumnRowValues);
    _gridRowsController.removeListener(_syncRowColumnValues);
    
    _gridColumnsController.dispose();
    _gridRowsController.dispose();
    super.dispose();
  }

  void _updateGridSize() {
    try {
      int newSize = int.parse(_gridColumnsController.text);
      
      if (newSize > 0) {
        setState(() {
          _gridSize = newSize;
          
          // Aktualizácia modelu
          widget.taskModel.content['grid'] = {
            'columns': _gridSize,
            'rows': _gridSize
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

  // Callback funkcia pre FormImagePicker
  void _onImagePathSelected(String path) {
    setState(() {
      _serverImagePath = path;
      widget.taskModel.content['image'] = path;
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
              'Vytvorenie puzzle',
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
                    // Použitie FormImagePicker pre výber obrázka
                    FormImagePicker(
                      label: 'Vyberte obrázok pre puzzle',
                      onImagePathSelected: _onImagePathSelected,
                      initialImagePath: _serverImagePath,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Nastavenie mriežky',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dve polia pre stĺpce a riadky - ale hodnoty sú vzájomne prepojené
                    Row(
                      children: [
                        Expanded(
                          child: FormTextField(
                            label: 'Počet stĺpcov',
                            placeholder: 'Zadajte počet stĺpcov',
                            controller: _gridColumnsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormTextField(
                            label: 'Počet riadkov',
                            placeholder: 'Zadajte počet riadkov',
                            controller: _gridRowsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateGridSize,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF67E4A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aktualizovať mriežku'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    if (_serverImagePath != null)
                      _buildPuzzlePreview(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzlePreview() {
    // Now using the PuzzlePreview widget instead of custom implementation
    return PuzzlePreview(
      imagePath: _serverImagePath,
      gridSize: _gridSize,
      apiService: _apiService,
      isInteractive: false, // We're in edit mode, so we don't need interactivity
    );
  }
}
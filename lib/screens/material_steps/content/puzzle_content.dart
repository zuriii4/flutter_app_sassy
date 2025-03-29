import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sassy/models/material.dart';

class PuzzleContent extends StatefulWidget {
  final TaskModel taskModel;
  
  const PuzzleContent({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<PuzzleContent> createState() => _PuzzleContentState();
}

class _PuzzleContentState extends State<PuzzleContent> {
  String _selectedImage = '';
  int _columns = 3;
  int _rows = 3;
  bool _showImageSelection = false;

  @override
  void initState() {
    super.initState();
    // Načítanie existujúcich hodnôt, ak existujú
    if (widget.taskModel.content.isNotEmpty) {
      _selectedImage = widget.taskModel.content['image'] ?? '';
      _columns = widget.taskModel.content['grid']?['columns'] ?? 3;
      _rows = widget.taskModel.content['grid']?['rows'] ?? 3;
    }
  }

  void _updateModel() {
    widget.taskModel.setPuzzleContent(_selectedImage, _columns, _rows);
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
                    const Text(
                      'Vyberte obrázok pre puzzle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleImageSelection,
                          icon: const Icon(Icons.image),
                          label: Text(_selectedImage.isEmpty 
                            ? 'Vybrať obrázok' 
                            : 'Zmeniť obrázok'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF67E4A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_selectedImage.isNotEmpty)
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
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Nastavenie mriežky',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Počet stĺpcov',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: TextEditingController(text: _columns.toString()),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _columns = int.parse(value);
                                  _updateModel();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Počet riadkov',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: TextEditingController(text: _rows.toString()),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _rows = int.parse(value);
                                  _updateModel();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    if (_selectedImage.isNotEmpty)
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

  Widget _buildImageSelectionWidget() {
    // Placeholder pre výber obrázku
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
              _buildImageTile('puzzle1.jpg'),
              _buildImageTile('puzzle2.jpg'),
              _buildImageTile('puzzle3.jpg'),
              _buildImageTile('puzzle4.jpg'),
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
        width: 100,
        height: 100,
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

  Widget _buildPuzzlePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Náhľad puzzle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Jednoduchý náhľad rozdelenia obrázku na mriežku
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              childAspectRatio: 1,
            ),
            itemCount: _columns * _rows,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text('${index + 1}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
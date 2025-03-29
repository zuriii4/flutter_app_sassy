import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class PuzzleBoard extends StatefulWidget {
  final String assetPath;
  final int rows;
  final int cols;

  const PuzzleBoard({
    super.key,
    required this.assetPath,
    this.rows = 3,
    this.cols = 3,
  });

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  List<PuzzleTile>? _tiles;
  List<int>? _currentArrangement;
  List<int>? _correctArrangement;
  bool _puzzleSolved = false;

  Future<void> _loadSampleImage() async {
    try {
      final bytes = await DefaultAssetBundle.of(context).load(widget.assetPath);
      final decoded = img.decodeImage(bytes.buffer.asUint8List());
      if (decoded == null) throw Exception("Failed to decode image");
      await _sliceDecodedImage(decoded);
    } catch (e) {
      print("Error loading sample image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _sliceDecodedImage(img.Image decoded) async {
    final tileWidth = (decoded.width / widget.cols).floor();
    final tileHeight = (decoded.height / widget.rows).floor();
    List<PuzzleTile> pieces = [];
    final correctOrder = List<int>.generate(widget.rows * widget.cols, (i) => i);

    for (int i = 0; i < widget.rows * widget.cols; i++) {
      final row = i ~/ widget.cols;
      final col = i % widget.cols;
      final piece = img.copyCrop(
        decoded,
        x: col * tileWidth,
        y: row * tileHeight,
        width: tileWidth,
        height: tileHeight,
      );
      final encoded = img.encodePng(piece);
      pieces.add(PuzzleTile(id: i, imageBytes: Uint8List.fromList(encoded)));
    }

    final shuffledIndices = List<int>.generate(pieces.length, (i) => i)..shuffle();

    setState(() {
      _tiles = pieces;
      _currentArrangement = shuffledIndices;
      _correctArrangement = correctOrder;
      _puzzleSolved = false;
    });
  }

  void _checkSolution() {
    if (_currentArrangement == null || _correctArrangement == null) return;
    bool solved = true;
    for (int i = 0; i < _currentArrangement!.length; i++) {
      if (_currentArrangement![i] != _correctArrangement![i]) {
        solved = false;
        break;
      }
    }
    setState(() {
      _puzzleSolved = solved;
    });
    if (solved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle vyriešené! Gratulujem!')),
      );
    }
  }

  void _swapTiles(int oldIndex, int newIndex) {
    if (_currentArrangement == null) return;
    setState(() {
      final temp = _currentArrangement![oldIndex];
      _currentArrangement![oldIndex] = _currentArrangement![newIndex];
      _currentArrangement![newIndex] = temp;
    });
    _checkSolution();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jigsaw Puzzle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tiles != null) {
                setState(() {
                  _currentArrangement = List<int>.generate(_tiles!.length, (i) => i)..shuffle();
                  _puzzleSolved = false;
                });
              }
            },
            tooltip: 'Zamiešať puzzle',
          ),
        ],
      ),
      body: Center(
        child: _tiles == null
            ? const Text('Načítavam puzzle...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_puzzleSolved)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '🎉 Puzzle vyriešené! 🎉',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: screenSize.width * 0.95,
                        maxHeight: screenSize.height * 0.8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tileWidth = constraints.maxWidth / widget.cols;
                            final tileHeight = constraints.maxHeight / widget.rows;
                            final tileSize = tileWidth < tileHeight ? tileWidth : tileHeight;

                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _tiles!.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: widget.cols,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 2,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                final tileIndex = _currentArrangement![index];
                                return SizedBox(
                                  width: tileSize,
                                  height: tileSize,
                                  child: DragTarget<int>(
                                    onAccept: (draggedIndex) {
                                      _swapTiles(draggedIndex, index);
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      return Draggable<int>(
                                        data: index,
                                        feedback: SizedBox(
                                          width: tileSize,
                                          height: tileSize,
                                          child: Image.memory(
                                            _tiles![tileIndex].imageBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          width: tileSize,
                                          height: tileSize,
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Container(
                                          width: tileSize,
                                          height: tileSize,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: candidateData.isNotEmpty ? Colors.blue : Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                          child: Image.memory(
                                            _tiles![tileIndex].imageBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PuzzleTile {
  final int id;
  final Uint8List imageBytes;

  PuzzleTile({
    required this.id,
    required this.imageBytes,
  });
}
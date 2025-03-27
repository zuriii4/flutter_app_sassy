import 'package:flutter/material.dart';

class WordJumbleBoard extends StatefulWidget {
  final List<String> words;
  final List<String> correctOrder;

  const WordJumbleBoard({
    Key? key,
    required this.words,
    required this.correctOrder,
  }) : super(key: key);

  @override
  State<WordJumbleBoard> createState() => _WordJumbleBoardState();
}

class _WordJumbleBoardState extends State<WordJumbleBoard> {
  late List<String> _shuffledWords;
  List<String> _selectedWords = [];

  @override
  void initState() {
    super.initState();
    _shuffledWords = List.from(widget.words)..shuffle();
  }

  void _onWordTap(String word) {
    if (_selectedWords.contains(word)) return;
    setState(() {
      _selectedWords.add(word);
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedWords.clear();
    });
  }

  bool get _isCorrect {
    return _selectedWords.length == widget.correctOrder.length &&
        List.generate(_selectedWords.length,
                (i) => _selectedWords[i] == widget.correctOrder[i])
            .every((e) => e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Jumble')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Poskladaj vetu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _shuffledWords.map((word) {
                final isUsed = _selectedWords.contains(word);
                return ElevatedButton(
                  onPressed: isUsed ? null : () => _onWordTap(word),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUsed ? Colors.grey[300] : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(word),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text('Tvoja odpoveď:'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _selectedWords.map((word) {
                return Chip(
                  label: Text(
                    word,
                    style: TextStyle(color: _isCorrect ? Colors.green : Colors.black),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            if (_selectedWords.isNotEmpty)
              _isCorrect
                  ? const Text(
                      '🎉 Správne!',
                      style: TextStyle(color: Colors.green, fontSize: 18),
                    )
                  : ElevatedButton.icon(
                      onPressed: _resetSelection,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Skúsiť znova'),
                    ),
          ],
        ),
      ),
    );
  }
}

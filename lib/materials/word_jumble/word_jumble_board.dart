import 'package:flutter/material.dart';

class WordJumbleBoard extends StatefulWidget {
  final List<String> words;
  final List<String> correctOrder;
  final Color primaryColor;
  final Color secondaryColor;
  final String instruction;

  const WordJumbleBoard({
    Key? key,
    required this.words,
    required this.correctOrder,
    this.primaryColor = const Color(0xFF5D69BE),
    this.secondaryColor = const Color(0xFF42A5F5),
    this.instruction = 'Poskladaj vetu:',
  }) : super(key: key);

  @override
  State<WordJumbleBoard> createState() => _WordJumbleBoardState();
}

class _WordJumbleBoardState extends State<WordJumbleBoard> with SingleTickerProviderStateMixin {
  late List<String> _shuffledWords;
  List<String> _selectedWords = [];
  List<int> _selectedIndices = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _shuffledWords = List.from(widget.words)..shuffle();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onWordTap(String word, int index) {
    if (_selectedWords.contains(word) || _isCorrect) return;
    
    setState(() {
      _selectedWords.add(word);
      _selectedIndices.add(index);
    });
    
    // If all words are selected, check if answer is correct
    if (_selectedWords.length == widget.correctOrder.length) {
      if (_isCorrect) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  void _removeSelectedWord(int index) {
    if (_isCorrect) return;
    
    setState(() {
      // final wordIndex = _selectedIndices[index];
      _selectedWords.removeAt(index);
      _selectedIndices.removeAt(index);
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedWords.clear();
      _selectedIndices.clear();
      _shuffledWords = List.from(widget.words)..shuffle();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.primaryColor.withOpacity(0.1),
              widget.secondaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title and instruction
                Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: widget.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.instruction,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Shuffled words
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(_shuffledWords.length, (index) {
                    final word = _shuffledWords[index];
                    final isUsed = _selectedIndices.contains(index);
                    
                    return AnimatedOpacity(
                      opacity: isUsed ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        elevation: isUsed ? 0 : 3,
                        color: isUsed ? Colors.grey.shade200 : widget.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: isUsed ? null : () => _onWordTap(word, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              word,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isUsed ? Colors.grey.shade600 : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 40),
                
                // Divider
                Container(
                  height: 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        widget.primaryColor.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Answer title
                Text(
                  'Tvoja odpoveď:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Selected words
                if (_selectedWords.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Klikni na slová vyššie, aby si vytvoril vetu',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCorrect
                            ? Colors.green
                            : widget.primaryColor.withOpacity(0.3),
                        width: _isCorrect ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_selectedWords.length, (index) {
                        return GestureDetector(
                          onTap: () => _removeSelectedWord(index),
                          child: Chip(
                            label: Text(
                              _selectedWords[index],
                              style: TextStyle(
                                color: _isCorrect ? Colors.green.shade700 : Colors.black87,
                                fontWeight: _isCorrect ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            backgroundColor: _isCorrect
                                ? Colors.green.shade50
                                : widget.secondaryColor.withOpacity(0.1),
                            elevation: 0,
                            side: BorderSide(
                              color: _isCorrect
                                  ? Colors.green.shade200
                                  : widget.secondaryColor.withOpacity(0.3),
                            ),
                            deleteIcon: _isCorrect
                                ? null
                                : const Icon(Icons.close, size: 18),
                            onDeleted: _isCorrect ? null : () => _removeSelectedWord(index),
                          ),
                        );
                      }),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                // Result and actions
                if (_selectedWords.isNotEmpty)
                  _isCorrect
                      ? AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + 0.2 * _animation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Správne!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _resetSelection,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Skúsiť znova'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
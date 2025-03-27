import 'package:flutter/material.dart';

// Trieda reprezentujúca jeden pár spojenia
class ConnectionPair {
  final String left;
  final String right;
  bool isConnected;

  ConnectionPair({
    required this.left,
    required this.right,
    this.isConnected = false,
  });

  // Vytvoriť kópiu s aktualizovaným stavom
  ConnectionPair copyWith({bool? isConnected}) {
    return ConnectionPair(
      left: left,
      right: right,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// Model pre správu dát spojení
class ConnectionBoardModel {
  final List<ConnectionPair> pairs;
  
  // Stavy interakcie
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<bool> leftItemsConnected;
  List<bool> rightItemsConnected;
  List<Map<String, int>> connections;
  bool allConnected = false;

  ConnectionBoardModel({
    required this.pairs,
  }) : leftItemsConnected = List.filled(pairs.length, false),
       rightItemsConnected = List.filled(pairs.length, false),
       connections = [];

  // Zamieša položky v pravom stĺpci
  void shuffleRightItems(List<int> shuffledIndices) {
    // Dáta sú už zamiešané pri použití widgetu
  }

  // Overí, či je spojenie správne
  bool checkConnection(int leftIndex, int rightIndex, List<int> rightItemsOrder) {
    return pairs[leftIndex].right == pairs[rightItemsOrder[rightIndex]].right;
  }

  // Označí položku ako pripojenú
  void markAsConnected(int leftIndex, int rightIndex, List<int> rightItemsOrder) {
    leftItemsConnected[leftIndex] = true;
    rightItemsConnected[rightIndex] = true;
    connections.add({'left': leftIndex, 'right': rightIndex});
    
    checkAllConnected();
  }

  // Skontroluje, či sú všetky položky pripojené
  void checkAllConnected() {
    allConnected = connections.length == pairs.length;
  }

  // Resetuje všetky spojenia
  void resetConnections() {
    selectedLeftIndex = null;
    selectedRightIndex = null;
    leftItemsConnected = List.filled(pairs.length, false);
    rightItemsConnected = List.filled(pairs.length, false);
    connections = [];
    allConnected = false;
  }
}

class ConnectionBoard extends StatefulWidget {
  final List<ConnectionPair> pairs;
  final Function(bool)? onAllConnected;
  final Color backgroundColor;
  final Color itemColor;
  final Color selectedItemColor;
  final Color lineColor;
  final Color connectedLineColor;
  final double itemHeight;
  final double itemWidth;
  final double fontSize;

  const ConnectionBoard({
    Key? key,
    required this.pairs,
    this.onAllConnected,
    this.backgroundColor = Colors.white,
    this.itemColor = Colors.blue,
    this.selectedItemColor = Colors.lightBlue,
    this.lineColor = Colors.grey,
    this.connectedLineColor = Colors.green,
    this.itemHeight = 50.0,
    this.itemWidth = 120.0,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  State<ConnectionBoard> createState() => _ConnectionBoardState();
}

class _ConnectionBoardState extends State<ConnectionBoard> {
  late ConnectionBoardModel _model;
  late List<int> _rightItemsOrder;
  bool _gameCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void didUpdateWidget(ConnectionBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Ak sa zmenili vstupné páry, reštartujeme hru
    if (widget.pairs != oldWidget.pairs) {
      _initializeGame();
    }
  }

  void _initializeGame() {
    _model = ConnectionBoardModel(pairs: widget.pairs);
    
    // Vytvorenie zamiešaného poradia pravých položiek
    _rightItemsOrder = List.generate(widget.pairs.length, (index) => index)..shuffle();
    
    _gameCompleted = false;
  }

  // Metóda na výber položky na ľavej strane
  void _selectLeftItem(int index) {
    if (_model.leftItemsConnected[index]) return;

    setState(() {
      _model.selectedLeftIndex = index;
      
      // Ak je už vybraná položka na pravej strane, skontrolujeme spojenie
      if (_model.selectedRightIndex != null) {
        _checkAndCreateConnection();
      }
    });
  }

  // Metóda na výber položky na pravej strane
  void _selectRightItem(int index) {
    if (_model.rightItemsConnected[index]) return;

    setState(() {
      _model.selectedRightIndex = index;
      
      // Ak je už vybraná položka na ľavej strane, skontrolujeme spojenie
      if (_model.selectedLeftIndex != null) {
        _checkAndCreateConnection();
      }
    });
  }

  // Skontroluje a vytvorí spojenie, ak je správne
  void _checkAndCreateConnection() {
    final leftIndex = _model.selectedLeftIndex!;
    final rightIndex = _model.selectedRightIndex!;

    if (_model.pairs[leftIndex].right == widget.pairs[_rightItemsOrder[rightIndex]].right) {
      // Správne spojenie
      _model.markAsConnected(leftIndex, rightIndex, _rightItemsOrder);
      
      // Ak sú všetky položky spojené, oznámime to
      if (_model.allConnected) {
        _gameCompleted = true;
        if (widget.onAllConnected != null) {
          widget.onAllConnected!(true);
        }
      }
    }

    // Resetujeme výber bez ohľadu na to, či bolo spojenie správne
    _model.selectedLeftIndex = null;
    _model.selectedRightIndex = null;
  }

  // Obnoví hru s novým zamiešaním
  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        children: [
          // Tlačidlo na obnovenie hry
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Obnoviť spojenia'),
            ),
          ),
          
          // Text s informáciou o stave hry
          if (_gameCompleted)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '🎉 Všetky položky správne spojené! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            
          // Hlavná hracia plocha
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Čiary spojení
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: ConnectionLinesPainter(
                        connections: _model.connections,
                        leftItemsPositions: List.generate(
                          widget.pairs.length,
                          (i) => Offset(
                            widget.itemWidth / 2,
                            i * (widget.itemHeight + 10) + widget.itemHeight / 2,
                          ),
                        ),
                        rightItemsPositions: List.generate(
                          widget.pairs.length,
                          (i) => Offset(
                            constraints.maxWidth - widget.itemWidth / 2,
                            i * (widget.itemHeight + 10) + widget.itemHeight / 2,
                          ),
                        ),
                        lineColor: widget.connectedLineColor,
                      ),
                    ),
                    
                    // Aktívna čiara pre aktuálny výber
                    if (_model.selectedLeftIndex != null || _model.selectedRightIndex != null)
                      CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ActiveConnectionLinePainter(
                          leftIndex: _model.selectedLeftIndex,
                          rightIndex: _model.selectedRightIndex,
                          leftItemsPositions: List.generate(
                            widget.pairs.length,
                            (i) => Offset(
                              widget.itemWidth / 2,
                              i * (widget.itemHeight + 10) + widget.itemHeight / 2,
                            ),
                          ),
                          rightItemsPositions: List.generate(
                            widget.pairs.length,
                            (i) => Offset(
                              constraints.maxWidth - widget.itemWidth / 2,
                              i * (widget.itemHeight + 10) + widget.itemHeight / 2,
                            ),
                          ),
                          mousePosition: null,
                          lineColor: widget.lineColor,
                        ),
                      ),
                    
                    // Položky
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ľavá strana
                        Column(
                          children: List.generate(
                            widget.pairs.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () => _selectLeftItem(index),
                                child: Container(
                                  width: widget.itemWidth,
                                  height: widget.itemHeight,
                                  decoration: BoxDecoration(
                                    color: _model.leftItemsConnected[index]
                                        ? Colors.green
                                        : _model.selectedLeftIndex == index
                                            ? widget.selectedItemColor
                                            : widget.itemColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.pairs[index].left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: widget.fontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Pravá strana
                        Column(
                          children: List.generate(
                            widget.pairs.length,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () => _selectRightItem(index),
                                child: Container(
                                  width: widget.itemWidth,
                                  height: widget.itemHeight,
                                  decoration: BoxDecoration(
                                    color: _model.rightItemsConnected[index]
                                        ? Colors.green
                                        : _model.selectedRightIndex == index
                                            ? widget.selectedItemColor
                                            : widget.itemColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.pairs[_rightItemsOrder[index]].right,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: widget.fontSize,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pre čiary spojení
class ConnectionLinesPainter extends CustomPainter {
  final List<Map<String, int>> connections;
  final List<Offset> leftItemsPositions;
  final List<Offset> rightItemsPositions;
  final Color lineColor;

  ConnectionLinesPainter({
    required this.connections,
    required this.leftItemsPositions,
    required this.rightItemsPositions,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final connection in connections) {
      final leftIndex = connection['left']!;
      final rightIndex = connection['right']!;

      canvas.drawLine(
        leftItemsPositions[leftIndex],
        rightItemsPositions[rightIndex],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pre aktívnu čiaru
class ActiveConnectionLinePainter extends CustomPainter {
  final int? leftIndex;
  final int? rightIndex;
  final List<Offset> leftItemsPositions;
  final List<Offset> rightItemsPositions;
  final Offset? mousePosition;
  final Color lineColor;

  ActiveConnectionLinePainter({
    required this.leftIndex,
    required this.rightIndex,
    required this.leftItemsPositions,
    required this.rightItemsPositions,
    required this.mousePosition,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (leftIndex != null && rightIndex != null) {
      // Kreslíme čiaru medzi vybranými položkami
      canvas.drawLine(
        leftItemsPositions[leftIndex!],
        rightItemsPositions[rightIndex!],
        paint,
      );
    } else if (leftIndex != null) {
      // Vybraná ľavá položka, čiara ide k myši alebo ku pravému okraju
      final endPoint = mousePosition ?? 
        Offset(size.width - 100, leftItemsPositions[leftIndex!].dy);
      
      canvas.drawLine(
        leftItemsPositions[leftIndex!],
        endPoint,
        paint,
      );
    } else if (rightIndex != null) {
      // Vybraná pravá položka, čiara ide k myši alebo k ľavému okraju
      final endPoint = mousePosition ?? 
        Offset(100, rightItemsPositions[rightIndex!].dy);
      
      canvas.drawLine(
        rightItemsPositions[rightIndex!],
        endPoint,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConnectionGameWrapper extends StatefulWidget {
  final List<ConnectionPair> pairs;

  const ConnectionGameWrapper({Key? key, required this.pairs}) : super(key: key);

  @override
  State<ConnectionGameWrapper> createState() => _ConnectionGameWrapperState();
}

class _ConnectionGameWrapperState extends State<ConnectionGameWrapper> {
  bool _allConnected = false;

  void _onAllConnected(bool completed) {
    setState(() {
      _allConnected = completed;
    });

    if (completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Všetky páry sú správne spojené! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spoj páry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Ako hrať'),
                  content: Text(
                    'Klikni na položku vľavo a potom na zodpovedajúcu položku vpravo. '
                    'Správne spoj všetky páry!',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_allConnected)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '✅ Výborne! Všetky páry sú spojené!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            Expanded(
              child: ConnectionBoard(
                pairs: widget.pairs,
                onAllConnected: _onAllConnected,
                backgroundColor: Colors.grey[100]!,
                itemColor: Colors.blue,
                selectedItemColor: Colors.lightBlueAccent,
                connectedLineColor: Colors.green,
                itemHeight: 60,
                itemWidth: 120,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Spojené: ${widget.pairs.where((p) => p.isConnected).length} z ${widget.pairs.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
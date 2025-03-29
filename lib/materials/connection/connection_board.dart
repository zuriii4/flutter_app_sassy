// connection_board.dart
import 'package:flutter/material.dart';
import 'connection_pair.dart';
import 'line_painters.dart';

class ConnectionBoard extends StatefulWidget {
  final List<ConnectionPair> pairs;
  final Color itemColor;
  final Color selectedItemColor;
  final Color connectedColor;
  final Color lineColor;

  const ConnectionBoard({
    Key? key,
    required this.pairs,
    this.itemColor = Colors.blue,
    this.selectedItemColor = Colors.lightBlue,
    this.connectedColor = Colors.green,
    this.lineColor = Colors.grey,
  }) : super(key: key);

  @override
  State<ConnectionBoard> createState() => _ConnectionBoardState();
}

class _ConnectionBoardState extends State<ConnectionBoard> {
  // Game state
  late List<int> _rightItemsOrder;
  List<Map<String, int>> _connections = [];
  int? _selectedLeftIndex;
  int? _selectedRightIndex;
  Offset? _mousePosition;
  List<bool> _leftItemsConnected = [];
  List<bool> _rightItemsConnected = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void didUpdateWidget(ConnectionBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pairs != oldWidget.pairs) {
      _initializeGame();
    }
  }

  void _initializeGame() {
    _rightItemsOrder = List.generate(widget.pairs.length, (index) => index)..shuffle();
    _connections = [];
    _selectedLeftIndex = null;
    _selectedRightIndex = null;
    _leftItemsConnected = List.filled(widget.pairs.length, false);
    _rightItemsConnected = List.filled(widget.pairs.length, false);
    
    for (var pair in widget.pairs) {
      pair.isConnected = false;
    }
  }

  void _selectLeftItem(int index) {
    if (_leftItemsConnected[index]) return;

    setState(() {
      _selectedLeftIndex = index;
      
      if (_selectedRightIndex != null) {
        _checkConnection();
      }
    });
  }

  void _selectRightItem(int index) {
    if (_rightItemsConnected[index]) return;

    setState(() {
      _selectedRightIndex = index;
      
      if (_selectedLeftIndex != null) {
        _checkConnection();
      }
    });
  }

  void _checkConnection() {
    final leftIndex = _selectedLeftIndex!;
    final rightIndex = _selectedRightIndex!;

    if (widget.pairs[leftIndex].right == widget.pairs[_rightItemsOrder[rightIndex]].right) {
      // Correct connection
      setState(() {
        _leftItemsConnected[leftIndex] = true;
        _rightItemsConnected[rightIndex] = true;
        _connections.add({'left': leftIndex, 'right': rightIndex});
        widget.pairs[leftIndex].isConnected = true;
      });
    }

    // Reset selection
    setState(() {
      _selectedLeftIndex = null;
      _selectedRightIndex = null;
    });
  }

  void _updateMousePosition(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
    });
  }

  Widget _buildItem({
    required String text,
    required bool isConnected,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 50,
        decoration: BoxDecoration(
          color: isConnected
              ? widget.connectedColor
              : isSelected
                  ? widget.selectedItemColor
                  : widget.itemColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: _updateMousePosition,
          child: Listener(
            onPointerMove: _updateMousePosition,
            child: Stack(
              children: [
                // Connection lines
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: ConnectionLinesPainter(
                    connections: _connections,
                    leftItemsPositions: List.generate(
                      widget.pairs.length,
                      (i) => Offset(
                        120, // Item width
                        i * 60 + 25, // Position based on item height and spacing
                      ),
                    ),
                    rightItemsPositions: List.generate(
                      widget.pairs.length,
                      (i) => Offset(
                        constraints.maxWidth - 120,
                        i * 60 + 25,
                      ),
                    ),
                    lineColor: widget.connectedColor,
                  ),
                ),
                
                // Active line
                if (_selectedLeftIndex != null || _selectedRightIndex != null)
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: ActiveConnectionLinePainter(
                      leftIndex: _selectedLeftIndex,
                      rightIndex: _selectedRightIndex,
                      leftItemsPositions: List.generate(
                        widget.pairs.length,
                        (i) => Offset(120, i * 60 + 25),
                      ),
                      rightItemsPositions: List.generate(
                        widget.pairs.length,
                        (i) => Offset(constraints.maxWidth - 120, i * 60 + 25),
                      ),
                      mousePosition: _mousePosition,
                      lineColor: widget.lineColor,
                    ),
                  ),
                
                // Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left items
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: List.generate(
                          widget.pairs.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _buildItem(
                              text: widget.pairs[index].left,
                              isConnected: _leftItemsConnected[index],
                              isSelected: _selectedLeftIndex == index,
                              onTap: () => _selectLeftItem(index),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Right items
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: List.generate(
                          widget.pairs.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _buildItem(
                              text: widget.pairs[_rightItemsOrder[index]].right,
                              isConnected: _rightItemsConnected[index],
                              isSelected: _selectedRightIndex == index,
                              onTap: () => _selectRightItem(index),
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
        );
      },
    );
  }
}

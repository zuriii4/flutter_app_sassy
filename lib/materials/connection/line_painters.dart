// line_painters.dart
import 'package:flutter/material.dart';

// Painter for permanent connection lines
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
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      final leftIndex = connection['left']!;
      final rightIndex = connection['right']!;
      
      final startPoint = leftItemsPositions[leftIndex];
      final endPoint = rightItemsPositions[rightIndex];
      
      // Draw a straight line
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter for active connection line (follows mouse)
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
      // Line between selected items
      final startPoint = leftItemsPositions[leftIndex!];
      final endPoint = rightItemsPositions[rightIndex!];
      canvas.drawLine(startPoint, endPoint, paint);
    } else if (leftIndex != null && mousePosition != null) {
      // Line from left item to mouse
      final startPoint = leftItemsPositions[leftIndex!];
      canvas.drawLine(startPoint, mousePosition!, paint);
    } else if (rightIndex != null && mousePosition != null) {
      // Line from right item to mouse
      final startPoint = rightItemsPositions[rightIndex!];
      canvas.drawLine(startPoint, mousePosition!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

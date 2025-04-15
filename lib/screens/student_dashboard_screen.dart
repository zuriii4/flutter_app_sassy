import 'package:flutter/material.dart';

class StudentDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard študenta'),
      ),
      body: Center(
        child: Text(
          'Toto je zástupná stránka - Dashboard.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StudentNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikácie študenta'),
      ),
      body: Center(
        child: Text(
          'Toto je zástupná stránka pre notifikácie.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

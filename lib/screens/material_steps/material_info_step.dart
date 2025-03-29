import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';

class TaskInfoStep extends StatelessWidget {
  final TaskModel taskModel;
  
  const TaskInfoStep({Key? key, required this.taskModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Základné informácie o úlohe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF67E4A),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Názov úlohy',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                taskModel.title = value;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Popis úlohy',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                taskModel.description = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
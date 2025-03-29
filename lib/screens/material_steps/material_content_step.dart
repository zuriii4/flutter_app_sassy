import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';
import 'package:sassy/screens/material_steps/content/quiz_content.dart';
import 'package:sassy/screens/material_steps/content/puzzle_content.dart';
import 'package:sassy/screens/material_steps/content/word_jumble_content.dart';
import 'package:sassy/screens/material_steps/content/connection_content.dart';

// Základná abstraktná trieda pre obsahové kroky
abstract class TaskContentStep extends StatefulWidget {
  final TaskModel taskModel;
  
  const TaskContentStep({Key? key, required this.taskModel}) : super(key: key);
}

// Konkrétna implementácia pre typ Quiz
class TaskContentQuizStep extends TaskContentStep {
  const TaskContentQuizStep({Key? key, required TaskModel taskModel}) 
    : super(key: key, taskModel: taskModel);

  @override
  State<TaskContentQuizStep> createState() => _TaskContentQuizStepState();
}

class _TaskContentQuizStepState extends State<TaskContentQuizStep> {
  @override
  void initState() {
    super.initState();
    // Inicializácia štruktúry pre quiz, ak ešte neexistuje
    if (!widget.taskModel.content.containsKey('questions')) {
      widget.taskModel.content['questions'] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuizContent(taskModel: widget.taskModel);
  }
}

// Konkrétna implementácia pre typ Puzzle
class TaskContentPuzzleStep extends TaskContentStep {
  const TaskContentPuzzleStep({Key? key, required TaskModel taskModel}) 
    : super(key: key, taskModel: taskModel);

  @override
  State<TaskContentPuzzleStep> createState() => _TaskContentPuzzleStepState();
}

class _TaskContentPuzzleStepState extends State<TaskContentPuzzleStep> {
  @override
  void initState() {
    super.initState();
    // Inicializácia štruktúry pre puzzle
    if (widget.taskModel.content.isEmpty) {
      widget.taskModel.content = {
        'image': '',
        'grid': {
          'columns': 3,
          'rows': 3
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return PuzzleContent(taskModel: widget.taskModel);
  }
}

// Konkrétna implementácia pre typ Word Jumble
class TaskContentWordJumbleStep extends TaskContentStep {
  const TaskContentWordJumbleStep({Key? key, required TaskModel taskModel}) 
    : super(key: key, taskModel: taskModel);

  @override
  State<TaskContentWordJumbleStep> createState() => _TaskContentWordJumbleStepState();
}

class _TaskContentWordJumbleStepState extends State<TaskContentWordJumbleStep> {
  @override
  void initState() {
    super.initState();
    // Inicializácia štruktúry pre word jumble
    if (widget.taskModel.content.isEmpty) {
      widget.taskModel.content = {
        'words': [],
        'correct_order': []
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return WordJumbleContent(taskModel: widget.taskModel);
  }
}

// Konkrétna implementácia pre typ Connection
class TaskContentConnectionStep extends TaskContentStep {
  const TaskContentConnectionStep({Key? key, required TaskModel taskModel}) 
    : super(key: key, taskModel: taskModel);

  @override
  State<TaskContentConnectionStep> createState() => _TaskContentConnectionStepState();
}

class _TaskContentConnectionStepState extends State<TaskContentConnectionStep> {
  @override
  void initState() {
    super.initState();
    // Inicializácia štruktúry pre connection
    if (!widget.taskModel.content.containsKey('pairs')) {
      widget.taskModel.content['pairs'] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionContent(taskModel: widget.taskModel);
  }
}
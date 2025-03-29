import 'package:flutter/material.dart';
import 'package:sassy/splash_screen.dart';
// import 'package:sassy/materials/puzzle/puzzle_board.dart';
// import 'package:sassy/materials/quiz/quiz_board.dart';
// import 'package:sassy/materials/word_jumble/word_jumble_board.dart';
// import 'package:sassy/materials/connection/connection_pair.dart';
// import 'package:sassy/materials/connection/connection_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SplashScreen(),
    );

    // return MaterialApp(
    //   home: const PuzzleBoard(
    //     assetPath: 'assets/img/sample.jpg',
    //     rows: 3,
    //     cols: 3,
    //   ),
    // );

    // return MaterialApp(
    //   home: ConnectionBoard(
    //           pairs: [
    //             ConnectionPair(left: "Slon", right: "🐘"),
    //             ConnectionPair(left: "Pes", right: "🐕"),
    //             ConnectionPair(left: "Mačka", right: "🐈"),
    //             ConnectionPair(left: "Žirafa", right: "🦒"),
    //             ConnectionPair(left: "Lev", right: "🦁"),
    //           ],
    //           itemColor: const Color(0xFF3498DB),
    //           selectedItemColor: const Color(0xFF2980B9),
    //           connectedColor: const Color(0xFF2ECC71),
    //           lineColor: Colors.grey,
    //         )
    // );

    // return MaterialApp(
    //   home: QuizBoard(
    //     questions: [
    //       QuizQuestion(
    //         text: 'Ktorý obrázok zobrazuje Eiffelovu vežu?',
    //         image: 'eiffel-question.jpg',
    //         answers: [
    //           AnswerOption(text: 'Obrázok 1', image: 'eiffel1.jpg', correct: false),
    //           AnswerOption(text: 'Obrázok 2', image: 'eiffel2.jpg', correct: true),
    //           AnswerOption(text: 'Obrázok 3', image: 'eiffel3.jpg', correct: false),
    //           AnswerOption(text: 'Žiadna z možností', correct: false),
    //         ],
    //       ),
    //       QuizQuestion(
    //         text: 'Ktoré mesto je hlavné mesto Francúzska?',
    //         answers: [
    //           AnswerOption(text: 'Paríž', correct: true),
    //           AnswerOption(text: 'Lyon', correct: false),
    //           AnswerOption(text: 'Marseille', correct: false),
    //         ],
    //       ),
    //     ],
    //   ),
    // );

    // return MaterialApp(
    //   home: const WordJumbleBoard(
    //     words: ['pes', 'beží', 'po', 'dome'],
    //     correctOrder: ['pes', 'beží', 'po', 'dome'],
    //   ),
    // );

  }
}
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sassy/screens/login_screen.dart';
// import 'package:sassy/screens/main_screen.dart';
//
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});
//
//   Future<bool> _checkToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     return token != null && token.isNotEmpty;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _checkToken(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.data == true) {
//           return MainScreen();
//         } else {
//           return const LoginPage();
//         }
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sassy/screens/teacher/login_screen.dart';
import 'package:sassy/screens/main_screen.dart';
import 'package:sassy/services/socket_service.dart';
import 'package:sassy/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Inicializácia notifikačnej služby
    await _notificationService.initialize();

    // Kontrola prihlásenia a spustenie socketu
    final isLoggedIn = await _checkAndInitSocket();

    // Navigácia na príslušnú obrazovku
    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<bool> _checkAndInitSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userRole = prefs.getString('userRole');

    // Ak máme token, userId a userRole, inicializujeme socket
    if (token != null && userId != null && userRole != null) {
      _socketService.initialize(
          'http://localhost:3000', // Nahraďte adresou vášho servera
          userId,
          userRole
      );
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
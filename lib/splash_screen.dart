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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();

  // Kontrolery animácie
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializácia animácie
    _setupAnimation();

    // Spustenie služieb a navigácie po dokončení animácie
    _animationController.forward().then((_) {
      _initializeServices();
    });
  }

  void _setupAnimation() {
    // Vytvorenie controllera pre animáciu s trvaním 2 sekundy
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Scale animácia - začíname od 0.5 (polovičná veľkosť) a končíme na 1.2 (120% veľkosť)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Fade animácia - na konci sa logo vytratí
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Alebo použite vašu vlastnú farbu pozadia
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation.value == 0.0 ? const AlwaysStoppedAnimation(1.0) : _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/img/Sassy.png', // Cesta k vášmu logu - upravte podľa potreby
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
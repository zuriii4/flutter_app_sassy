// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:sassy/screens/main_screen.dart';
// import 'package:sassy/services/api_service.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final ApiService _apiService = ApiService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8EDE3),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Container(
//             width: 300,
//             height: 400,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF4D3BA),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     height: 140,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: Center(
//                       child: SvgPicture.asset(
//                         'assets/img/Sassy copy.svg',
//                         height: 100,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 160,
//                   left: 20,
//                   right: 20,
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           hintText: "Email",
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           hintText: "Heslo",
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                       ElevatedButton(
//                         onPressed: () async {
//                           try {
//                             final email = _emailController.text.trim();
//                             final password = _passwordController.text.trim();
//
//                             final token = await _apiService.login(email, password);
//
//                             if (token != null) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => MainScreen()),
//                               );
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Neplatné prihlasovacie údaje')),
//                               );
//                             }
//                           } catch (e) {
//                             print('❌ Chyba pri prihlasovaní: $e');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Chyba pri prihlasovaní')),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF4A261),
//                           shape: const CircleBorder(),
//                           padding: const EdgeInsets.all(15),
//                         ),
//                         child: const Icon(Icons.arrow_forward, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sassy/screens/main_screen.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EDE3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFFF4D3BA),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/img/Sassy copy.svg',
                        height: 100,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 160,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Heslo",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4A261),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final token = await _apiService.login(email, password);

      if (token != null) {
        // Po úspešnom prihlásení získame userId a userRole
        final userData = await _apiService.getCurrentUser();

        if (userData != null) {
          final prefs = await SharedPreferences.getInstance();

          // print(userData);
          // print(userData['user']['_id']);
          // print(userData['user']['role']);
          // Uložíme userId a userRole do SharedPreferences
          await prefs.setString('userId', userData['user']['_id']);
          await prefs.setString('userRole', userData['user']['role']);

          // Inicializujeme socket
          _socketService.initialize(
              'http://localhost:3000', // Nahraďte adresou vášho servera
              userData['user']['_id'],
              userData['user']['role']
          );
          // Navigácia na hlavnú obrazovku
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } else {
          _showError('Nepodarilo sa získať informácie o používateľovi');
        }
      } else {
        _showError('Neplatné prihlasovacie údaje');
      }
    } catch (e) {
      print('❌ Chyba pri prihlasovaní: $e');
      _showError('Chyba pri prihlasovaní');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
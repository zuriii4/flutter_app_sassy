import 'package:flutter/material.dart';
import 'package:sassy/screens/create_material_screen.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sassy/widgets/sidebar.dart';
import 'package:sassy/screens/dashboard_screen.dart';
import 'package:sassy/screens/materials_screen.dart';
import 'package:sassy/screens/students_screen.dart';
import 'package:sassy/screens/settings_screen.dart';
import 'package:sassy/screens/support_screen.dart';
import 'package:sassy/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final SidebarXController _controller = SidebarXController(selectedIndex: 0);
  String? _userRole;
  String? _userName;

  Future<void> _loadUserRole() async {
    final apiService = ApiService();
    final userData = await apiService.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        _userRole = userData['user']['role'];
        _userName = userData['user']['name'];
      });
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _loadUserRole();
      if (index == 5) {
        _controller.selectIndex(-1);
      } else {
        _controller.selectIndex(index);
      }
    });
  }

  void _onTaskSubmitted() {
    setState(() {
      _selectedIndex = 0; 
      _controller.selectIndex(0);
    });
  }

  // We need to create pages within build to pass callback
  List<Widget> _getPages() {
    return [
      DashboardPage(),
      TemplatesPage(),
      StudentsPage(),
      SettingsPage(),
      SupportPage(),
      CreateTaskScreen(onTaskSubmitted: _onTaskSubmitted),
    ];
  }

  void _startTokenValidationLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(minutes: 1));
      final apiService = ApiService();
      final isValid = await apiService.isTokenValid();
      if (!isValid) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return false; // stop the loop
      }
      return true; // continue the loop
    });
  }

  @override
  void initState() {
    super.initState();
    _startTokenValidationLoop();
    _loadUserRole();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Row(
        children: [
          Sidebar(
            controller: _controller,
            onItemSelected: _onItemSelected,
            userRole: _userRole ?? 'student',
            userName: _userName ?? 'Unknown',
          ),
          SizedBox(width: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
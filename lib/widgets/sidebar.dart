import 'package:flutter/material.dart';
import 'package:sassy/screens/login_screen.dart';
import 'package:sassy/screens/materials_screen.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sidebarx/sidebarx.dart';


class Sidebar extends StatelessWidget {
  final SidebarXController controller;
  final Function(int) onItemSelected; // Callback na zmenu stránky
  final String userRole;

  const Sidebar({
    super.key,
    required this.controller,
    required this.onItemSelected,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffd3ad), Color(0xfff9dfc8)],
            stops: [0, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0), // Dynamická hodnota
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        hoverColor: const Color.fromARGB(28, 0, 0, 0),
        hoverTextStyle: const TextStyle(color: Colors.black),
        textStyle: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter',),
        selectedTextStyle: const TextStyle(color: Colors.black),

        itemMargin: const EdgeInsets.only(left:5, right: 5, top: 0, bottom: 0),
        itemPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        selectedItemPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        selectedItemMargin: const EdgeInsets.only(left:5, right: 5, top: 0, bottom: 0),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),

        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(50, 0, 0, 0),
              Color.fromARGB(75, 2, 2, 2)
            ],
            transform: GradientRotation(1),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black54,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.black,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffd3ad), Color(0xfff9dfc8)],
            stops: [0, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0), // Dynamická hodnota
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      headerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // Minimalizuje šírku Row na obsah
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/img/avatar.png'),
                ),
                if (controller.extended) ...[
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Branislav Zurian",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "UČITEĽ",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
      items: userRole == 'teacher' ? [
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.dashboard),
          ),
          label: 'Dashboard',
          onTap: () {
            onItemSelected(0);
            debugPrint('Navigácia na Dashboard');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.folder),
          ),
          label: 'Materiály',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MaterialsPage()),
            );
            debugPrint('Navigácia na Materiály');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.people),
          ),
          label: 'Študenti',
          onTap: () {
            onItemSelected(2);
            debugPrint('Navigácia na Študenti');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.settings),
          ),
          label: 'Nastavenia',
          onTap: () {
            onItemSelected(3);
            debugPrint('Navigácia na Nastavenia');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.help_outline),
          ),
          label: 'Podpora',
          onTap: () {
            onItemSelected(4);
            debugPrint('Navigácia na Podpora');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.logout),
          ),
          label: 'Odhlásiť sa',
          onTap: () async {
            final success = await ApiService().logoutUser();
            if (success) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
              debugPrint('✅ Odhlásenie úspešné');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nepodarilo sa odhlásiť')),
              );
              debugPrint('❌ Odhlásenie zlyhalo');
            }
          },
        ),
      ] : [
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.dashboard),
          ),
          label: 'Dashboard',
          onTap: () {
            onItemSelected(0);
            debugPrint('Navigácia na Dashboard');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.person),
          ),
          label: 'Profil',
          onTap: () {
            onItemSelected(1);
            debugPrint('Navigácia na Profil');
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.logout),
          ),
          label: 'Odhlásiť sa',
          onTap: () async {
            final success = await ApiService().logoutUser();
            if (success) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
              debugPrint('✅ Odhlásenie úspešné');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nepodarilo sa odhlásiť')),
              );
              debugPrint('❌ Odhlásenie zlyhalo');
            }
          },
        ),
      ],
      footerBuilder: (context, extended) {
        if (extended) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8EDE3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Začnime!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Vytváranie alebo pridávanie nových úloh",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      onItemSelected(5);
                      debugPrint("Pridať novú úlohu");
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white, 
                    ),
                    label: const Text(
                      "Pridať novú úlohu",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 127, 37),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return ElevatedButton(
            onPressed: () async {
              onItemSelected(5);
              debugPrint("Pridať novú úlohu 2");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 229, 127, 37),
              minimumSize: const Size(50, 50),
              maximumSize: const Size(50, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
      },
    );
  }
}
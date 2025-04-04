import 'package:flutter/material.dart';
import 'package:sassy/screens/login_screen.dart';
import 'package:sassy/screens/materials_screen.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sidebarx/sidebarx.dart';


class Sidebar extends StatelessWidget {
  final SidebarXController controller;
  final Function(int) onItemSelected;
  final String userRole;
  final String userName;

  const Sidebar({
    super.key,
    required this.controller,
    required this.onItemSelected,
    required this.userRole,
    required this.userName
  });

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        width: 80, // Nastavíme pevnú šírku pre collapsed stav
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffd3ad), Color(0xfff9dfc8)],
            stops: [0, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        hoverColor: const Color.fromARGB(28, 0, 0, 0),
        hoverTextStyle: const TextStyle(color: Colors.black),
        textStyle: const TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Inter'),
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
        width: 250, // Pevná šírka pre rozbalený stav
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffffd3ad), Color(0xfff9dfc8)],
            stops: [0, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20)),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // const CircleAvatar(
                //   radius: 20,
                //   backgroundImage: AssetImage('assets/img/avatar.png'),
                // ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 25, color: Color(0xFFF4A261)),
                ),
                if (extended) ...[
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userRole == 'teacher' ? "UČITEĽ" : "ŠTUDENT",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nepodarilo sa odhlásiť')),
              );
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
            onItemSelected(6);
          },
        ),
        SidebarXItem(
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.person),
          ),
          label: 'Profil',
          onTap: () {
            onItemSelected(2);
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nepodarilo sa odhlásiť')),
              );
            }
          },
        ),
      ],
      footerBuilder: (context, extended) {
        // V footerBuilder už máme paramater extended, ktorý odráža stav sidebaru
        if (extended) {
          // Plne rozbalený stav
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
          // Zabalený stav - používame jednoduchšiu verziu tlačidla
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(255, 229, 127, 37),
                  onPressed: () {
                    onItemSelected(5);
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        }
      },
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}
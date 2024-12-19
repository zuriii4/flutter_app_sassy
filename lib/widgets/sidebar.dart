import 'package:flutter/material.dart';
import 'package:sassy/screens/add_task_screen.dart';
import 'package:sassy/screens/dashboard_screen.dart';
import 'package:sassy/screens/login_screen.dart';
import 'package:sassy/screens/materials_screen.dart';
import 'package:sassy/screens/settings_screen.dart';
import 'package:sassy/screens/students_screen.dart';
import 'package:sassy/screens/support_screen.dart';
import 'package:sidebarx/sidebarx.dart';


class Sidebar extends StatelessWidget {
  final SidebarXController controller;

  const Sidebar({super.key, required this.controller});

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
          ),],
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
          // border: Border.all(color: const Color.fromARGB(15, 0, 0, 0)),
          // gradient: const LinearGradient(
          //   colors: [Color.fromARGB(125, 255, 200, 155), Color.fromARGB(125, 255, 187, 142)],
          //   stops: [0, 1],
          //   begin: Alignment.bottomLeft,
          //   end: Alignment.topRight,
          // ),
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
          ),],
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
            // left: controller.extended ? 20 : 0, // Ternárny operátor pre ľavý padding
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // Minimalizuje šírku Row na obsah
              children: [
                // Avatar
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/img/avatar.png'),
                ),
                if (controller.extended) ...[
                  const SizedBox(width: 10), // Medzera medzi avatarom a textom
                  // Textová sekcia
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
      items: [
        SidebarXItem(
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.dashboard),
          ),
          label: 'Dashboard',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
            debugPrint('Navigácia na Dashboard');
          },
        ),
        SidebarXItem(
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
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
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.people),
          ),
          // icon: Icons.people,
          label: 'Študenti',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentsPage()),
            );
            debugPrint('Navigácia na Študenti');
          },
        ),
        SidebarXItem(
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.settings),
          ),
          label: 'Nastavenia',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
            debugPrint('Navigácia na Nastavenia');
          },
        ),
        SidebarXItem(
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.help_outline),
          ),
          label: 'Podpora',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportPage()),
            );
            debugPrint('Navigácia na Podpora');
          },
        ),
        SidebarXItem(
          // ignore: deprecated_member_use
          iconWidget: const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.logout),
          ),
          // icon: Icons.dashboard,
          label: 'Odhlásiť sa',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            debugPrint('Odhlásenie');
          },
        ),
      ],
      footerBuilder: (context, extended) {
        if (extended) {
          // Rozbalený stav
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8EDE3), // Svetlá farba pozadia
                borderRadius: BorderRadius.circular(20), // Zaoblenie rohov
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // Vnútorný padding
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
                      Navigator.push(
                        context,
                       MaterialPageRoute(builder: (context) => AddTaskPage()),
                      );
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
                        ), // Nastavenie veľkosti písma
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 229, 127, 37),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Zaoblenie tlačidla
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Zbalený stav
          return ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskPage()),
              );
              debugPrint("Pridať novú úlohu 2");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 229, 127, 37),
              minimumSize: const Size(50, 50),
              maximumSize: const Size(50, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.zero, // Odstráň padding
            ),
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
      },
    );
  }
}



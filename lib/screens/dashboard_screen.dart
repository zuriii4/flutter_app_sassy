import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
// import 'package:sassy/widgets/sidebar.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({Key? key}) : super(key: key);

  final SidebarXController _controller =
      SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Row(
        children: [
          // Sidebar(controller: _controller), // Sidebar naľavo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                color: const Color.fromARGB(0, 244, 163, 97), // Oranžové pozadie
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Biely kontajner
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sekcia Vaše projekty
                        const Text(
                          "Vaše projekty",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E48),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 400, // Výška pre projekty
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return ProjectCard(
                                title: "Projekt ${index + 1}",
                                description:
                                    "Toto je krátky popis projektu ${index + 1}, ktorý môže obsahovať užitočné detaily.",
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sekcia Oznámenia a Študenti
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Oznámenia
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Oznámenia",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E2E48),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: 5,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              "Oznámenie ${index + 1}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: const Text(
                                              "Krátky popis oznámenia...",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            leading: const Icon(
                                              Icons.notification_important,
                                              color: Colors.orange,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Študenti
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Študenti",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E2E48),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: 5,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              "Študent ${index + 1}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            leading: const CircleAvatar(
                                              backgroundColor: Colors.orange,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;

  const ProjectCard({Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.edit, color: Colors.grey),
                Icon(Icons.visibility, color: Colors.grey),
                Icon(Icons.link, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
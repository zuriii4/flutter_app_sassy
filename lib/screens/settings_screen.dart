import 'package:flutter/material.dart';
import 'package:sassy/widgets/sidebar.dart';
import 'package:sidebarx/sidebarx.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final SidebarXController _controller =
      SidebarXController(selectedIndex: 3, extended: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 211, 186),
      body: Row(
        children: [
          Sidebar(controller: _controller),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                color: const Color.fromARGB(0, 244, 163, 97),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black45,
                            indicatorColor: Color(0xFFF4A261),
                            indicatorWeight: 3,
                            tabs: [
                              Tab(text: "Môj účet"),
                              Tab(text: "Súkromie a bezpečnosť"),
                              Tab(text: "Oznámenia"),
                              Tab(text: "Ďalšie"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildAccountTab(),
                                _buildPrivacyTab(),
                                _buildNotificationsTab(),
                                _buildAdditionalTab(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return ListView(
      children: [
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFF4A261),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField("Meno", "John"),
        const SizedBox(height: 10),
        _buildTextField("Priezvisko", "Smith"),
        const SizedBox(height: 10),
        _buildTextField("Dátum narodenia", "12/12/1992", isDate: true),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.info, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Vaše údaje uchovávame v súkromí a nikdy ich neposkytujeme tretím stranám.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save),
          label: const Text("Upraviť"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4A261),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String placeholder, {bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          readOnly: isDate,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab() {
    return const Center(
      child: Text("Obsah pre Súkromie a bezpečnosť"),
    );
  }

  Widget _buildNotificationsTab() {
    return const Center(
      child: Text("Obsah pre Oznámenia"),
    );
  }

  Widget _buildAdditionalTab() {
    return const Center(
      child: Text("Obsah pre Ďalšie"),
    );
  }
}
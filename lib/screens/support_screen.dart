import 'package:flutter/material.dart';
// import 'package:sassy/widgets/sidebar.dart';
import 'package:sidebarx/sidebarx.dart';

class SupportPage extends StatelessWidget {
  SupportPage({Key? key}) : super(key: key);

  final SidebarXController _controller =
      SidebarXController(selectedIndex: 4, extended: true);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Podpora používateľov",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Ak máte otázky, problémy alebo potrebujete pomoc, vyplňte formulár nižšie a náš tím vás bude čoskoro kontaktovať.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildSupportForm(),
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

  Widget _buildSupportForm() {
    return Expanded(
      child: ListView(
        children: [
          _buildTextField("Vaše meno", "Zadajte svoje meno"),
          const SizedBox(height: 10),
          _buildTextField("E-mail", "Zadajte svoj e-mail"),
          const SizedBox(height: 10),
          _buildTextField("Predmet", "Zadajte predmet správy"),
          const SizedBox(height: 10),
          _buildTextArea("Správa", "Napíšte svoju správu"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Funkcia pre odoslanie správy
              print("Správa odoslaná");
            },
            icon: const Icon(Icons.send),
            label: const Text("Odoslať správu"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4A261),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
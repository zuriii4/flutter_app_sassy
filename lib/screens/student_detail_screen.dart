import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sassy/widgets/sidebar.dart';

class StudentDetailPage extends StatelessWidget {
  final String studentName;
  final String studentStatus;

  final SidebarXController _controller =
      SidebarXController(selectedIndex: 2, extended: true);

  StudentDetailPage({
    Key? key,
    required this.studentName,
    required this.studentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 211, 186), // Oranžové pozadie
      body: Row(
        children: [
          Sidebar(controller: _controller), // Sidebar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                color: Colors.transparent, // Transparentný kontajner
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8, // 80% šírky
                    padding: const EdgeInsets.all(20.0),
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
                        // Záhlavie
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  studentStatus,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.person, size: 40),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Štatistiky
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard("20", "Celkové lekcie"),
                            SizedBox(width: 10,),
                            _buildStatCard("15", "Dokončené"),
                            SizedBox(width: 10,),
                            _buildStatCard("80%", "Úspešnosť"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Grafy a výkony
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  const Text(
                                    "Strávené hodiny",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 244, 211, 186),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Bar Chart Placeholder",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  const Text(
                                    "Výkon",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 244, 211, 186),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Gauge Chart Placeholder",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tabuľka progresu
                        const Text(
                          "Tabuľka progresu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("Lekcia")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Dátum")),
                                DataColumn(label: Text("Hodnotenie")),
                              ],
                              rows: List<DataRow>.generate(
                                5,
                                (index) => DataRow(
                                  cells: [
                                    DataCell(Text("Lekcia ${index + 1}")),
                                    const DataCell(Text("Dokončené")),
                                    DataCell(Text("2024-12-${index + 1}")),
                                    DataCell(Text("${80 + index * 2}%")),
                                  ],
                                ),
                              ),
                            ),
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

  Widget _buildStatCard(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 244, 211, 186),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
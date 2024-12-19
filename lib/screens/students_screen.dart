import 'package:flutter/material.dart';
import 'package:sassy/screens/student_detail_screen.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sassy/widgets/sidebar.dart';

class StudentsPage extends StatelessWidget {
  StudentsPage({Key? key}) : super(key: key);

  final SidebarXController _controller =
      SidebarXController(selectedIndex: 2, extended: true);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard("12", "Študenti"),
                            _buildStatCard("5", "Špeciálne potreby"),
                            _buildStatCard("0", "Hostia"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF4F4F4),
                                  hintText: "Hľadať",
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.all(12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text("Pridať"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 244, 211, 186),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("")),
                                DataColumn(label: Text("Študenti")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Potreby")),
                                DataColumn(label: Text("Aktívny")),
                              ],
                              rows: List<DataRow>.generate(
                                7,
                                (index) => DataRow(
                                  cells: [
                                    DataCell(
                                      Checkbox(
                                        value: false,
                                        onChanged: (value) {},
                                      ),
                                    ),
                                    DataCell(
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentDetailPage(
                                                      studentName:
                                                          "Andrew Bojangles ${index + 1}", studentStatus: 'daco ${index + 1}',),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Colors.orange,
                                              child: Icon(Icons.person),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Andrew Bojangles ${index + 1}",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const DataCell(Text("Aktívny")),
                                    DataCell(
                                      Text([
                                        "Autizmus",
                                        "Aspergerov syndróm",
                                        "Downov syndróm",
                                        "ADHD",
                                        "Dyslexia",
                                        "Dyskalkúlia"
                                      ][index % 6]),
                                    ),
                                    const DataCell(Text("Pred 2 dňami")),
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
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
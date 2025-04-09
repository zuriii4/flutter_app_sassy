import 'package:flutter/material.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/screens/students/student_detail_screen.dart';
import 'package:sassy/models/student.dart';
import 'package:sassy/screens/material_detail_screen.dart';
import 'package:sassy/widgets/material_card.dart'; // Import nových komponentov

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  List<Student> _students = [];
  List<dynamic> _materials = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load students and materials simultaneously
      final studentsResult = await _apiService.getStudents();
      final materialsResult = await _apiService.getAllMaterials();
      
      setState(() {
        // Convert JSON to Student objects
        _students = studentsResult.map((json) => Student.fromJson(json)).toList();
        _materials = materialsResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Nepodarilo sa načítať dáta: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAsTemplate(String materialId) async {
    try {
      final result = await _apiService.saveMaterialAsTemplate(materialId);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materiál bol úspešne uložený ako šablóna')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodarilo sa uložiť materiál ako šablónu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? ErrorStateWidget(
                    errorMessage: _errorMessage!, 
                    onRetry: _loadData
                  )
                : Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E48),
                              ),
                            ),
                            
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.black),
                                onPressed: _loadData,
                                tooltip: 'Obnoviť',
                              ),

                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Materials section
                        const Text(
                          "Vaše materiály",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E48),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300, // Height for materials
                          child: _materials.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Zatiaľ nemáte žiadne šablóny",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    childAspectRatio: 1.5,
                                  ),
                                  itemCount: _materials.length,
                                  itemBuilder: (context, index) {
                                    final material = _materials[index];
                                    return MaterialCard(
                                      title: material['title'] ?? 'Bez názvu',
                                      description: material['description'] ?? 'Bez popisu',
                                      type: material['type'] ?? 'unknown',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MaterialDetailScreen(
                                              materialId: material['_id'],
                                            ),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      onSaveAsTemplate: () => _saveAsTemplate(material['_id']),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Students and Announcements section
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Students section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Študenti",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E2E48),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: _students.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "Nenašli sa žiadni študenti",
                                                style: TextStyle(fontSize: 16, color: Colors.black54),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: _students.length,
                                              itemBuilder: (context, index) {
                                                final student = _students[index];
                                                
                                                return ListTile(
                                                  title: Text(
                                                    student.name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    student.needsDescription.isEmpty 
                                                        ? student.status
                                                        : student.needsDescription,
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  leading: CircleAvatar(
                                                    backgroundColor: student.hasSpecialNeeds 
                                                        ? Colors.orange 
                                                        : Colors.blue,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  trailing: Text(
                                                    student.lastActive,
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StudentDetailScreen(
                                                          student: student,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Announcements section
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
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
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
    );
  }
}
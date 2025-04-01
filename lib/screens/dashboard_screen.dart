import 'package:flutter/material.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/screens/students/student_detail_screen.dart';
import 'package:sassy/models/student.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _students = [];
  List<dynamic> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Načítanie študentov a materiálov súčasne
      final studentsResult = await _apiService.getStudents();
      final materialsResult = await _apiService.getAllMaterials();
      
      setState(() {
        _students = studentsResult;
        _materials = materialsResult;
        _isLoading = false;
      });
    } catch (e) {
      print('Chyba pri načítaní dát: $e');
      setState(() {
        _isLoading = false;
      });
      // Tu môžete pridať zobrazenie chybového hlásenia
    }
  }

  // Získanie ikony podľa typu materiálu
  IconData _getMaterialIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.question_answer;
      case 'alphabet':
        return Icons.sort_by_alpha;
      case 'match':
        return Icons.compare_arrows;
      case 'puzzle':
        return Icons.extension;
      default:
        return Icons.description; // Predvolená ikona
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Row(
        children: [
          // Sidebar môžete pridať podľa potreby
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
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
                              // Sekcia Materiály
                              const Text(
                                "Vaše materiály",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E2E48),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 400, // Výška pre materiály
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                  ),
                                  itemCount: _materials.length,
                                  itemBuilder: (context, index) {
                                    final material = _materials[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MaterialDetailScreen(
                                              materialId: material['_id'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: MaterialCard(
                                        title: material['title'] ?? 'Bez názvu',
                                        description: material['description'] ?? 'Bez popisu',
                                        icon: _getMaterialIcon(material['type'] ?? ''),
                                      ),
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
                                    // Oznámenia - zachované z pôvodného kódu
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
                                    // Študenti - aktualizované s dynamickými dátami
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
                                              itemCount: _students.length,
                                              itemBuilder: (context, index) {
                                                final student = _students[index];
                                                final bool hasSpecialNeeds = student['hasSpecialNeeds'] ?? false;
                                                
                                                return ListTile(
                                                  title: Text(
                                                    student['name'] ?? 'Neznámy študent',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    student['email'] ?? 'Bez emailu',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  leading: CircleAvatar(
                                                    backgroundColor: hasSpecialNeeds 
                                                      ? Colors.orange 
                                                      : Colors.blue,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    // Vytvorenie Student objektu z JSON
                                                    final studentObj = Student(
                                                      id: student['_id'] ?? '',
                                                      name: student['name'] ?? '',
                                                      email: student['email'] ?? '',
                                                      notes: student['notes'] ?? '',
                                                      status: student['status'] ?? 'Aktívny',
                                                      needsDescription: student['needsDescription'] ?? '',
                                                      lastActive: student['lastActive'] ?? 'Dnes',
                                                      hasSpecialNeeds: student['hasSpecialNeeds'] ?? false,
                                                      dateOfBirth: student['dateOfBirth'] != null 
                                                        ? DateTime.parse(student['dateOfBirth']) 
                                                        : null,
                                                    );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StudentDetailScreen(
                                                          student: studentObj,
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

class MaterialCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const MaterialCard({
    Key? key, 
    required this.title, 
    required this.description,
    required this.icon,
  }) : super(key: key);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(icon, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Zakomentujte alebo odstráňte túto triedu, ak už máte MaterialDetailScreen
class MaterialDetailScreen extends StatelessWidget {
  final String materialId;

  const MaterialDetailScreen({Key? key, required this.materialId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail materiálu'),
      ),
      body: Center(
        child: Text('Detail materiálu s ID: $materialId'),
      ),
    );
  }
}
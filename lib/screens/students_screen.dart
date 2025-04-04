import 'package:flutter/material.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/models/student.dart';
import 'package:sassy/widgets/search_bar.dart';
import 'package:sassy/widgets/stat_card.dart';
import 'package:sassy/screens/students/student_detail_screen.dart';
import 'package:sassy/screens/students/create_group_screen.dart';
import 'package:sassy/screens/students/create_student_screen.dart';
import 'package:sassy/screens/group_screen.dart'; 

class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  List<String> _selectedStudentIds = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadStudents();
    
    _searchController.addListener(() {
      _filterStudents(_searchController.text);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final data = await _apiService.getStudents();
      _allStudents = data.map((json) => Student.fromJson(json)).toList();
      _filteredStudents = List.from(_allStudents);
    } catch (e) {
      setState(() {
        _errorMessage = "Nepodarilo sa načítať študentov: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _filterStudents(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredStudents = List.from(_allStudents);
      } else {
        _filteredStudents = _allStudents
            .where((student) => student.name.toLowerCase()
            .contains(searchTerm.toLowerCase()))
            .toList();
      }
    });
  }
  
  void _toggleStudentSelection(String studentId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedStudentIds.add(studentId);
      } else {
        _selectedStudentIds.remove(studentId);
      }
    });
  }
  
  void _navigateToGroupsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupsScreen(),
      ),
    );
  }
  
  void _createNewStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateStudentScreen(),
      ),
    );
    
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Študent bol úspešne vytvorený')),
      );
      _loadStudents(); // Obnovíme zoznam študentov
    }
  }

  void _createNewGroup() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyberte aspoň jedného študenta pre vytvorenie skupiny')),
      );
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(selectedStudentIds: _selectedStudentIds),
      ),
    );
    
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skupina bola úspešne vytvorená')),
      );
      setState(() {
        _selectedStudentIds = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Počítame štatistiky
    final specialNeedsCount = _allStudents.where((s) => s.hasSpecialNeeds).length;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
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
          padding: const EdgeInsets.all(20.0),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Štatistiky a tlačidlo pre skupiny
                        Row(
                          children: [
                            // Štatistiky
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  StatCard(
                                    count: _allStudents.length.toString(),
                                    label: "Študenti",
                                  ),
                                  StatCard(
                                    count: specialNeedsCount.toString(),
                                    label: "Špeciálne potreby",
                                  ),
                                ],
                              ),
                            ),
                            
                            // Tlačidlo pre zobrazenie skupín
                            ElevatedButton.icon(
                              onPressed: _navigateToGroupsScreen,
                              icon: const Icon(Icons.group),
                              label: const Text("Skupiny"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Vyhľadávanie a akcie
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomSearchBar(
                                controller: _searchController,
                                hintText: "Hľadať študenta",
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _selectedStudentIds.isNotEmpty 
                                  ? _createNewGroup
                                  : null,
                              icon: const Icon(Icons.group_add),
                              label: const Text("Vytvoriť skupinu"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 244, 211, 186),
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'select_all',
                                  child: Text('Vybrať všetkých'),
                                ),
                                const PopupMenuItem(
                                  value: 'deselect_all',
                                  child: Text('Zrušiť výber'),
                                ),
                                const PopupMenuItem(
                                  value: 'refresh',
                                  child: Text('Obnoviť'),
                                ),
                                const PopupMenuItem(
                                  value: 'newStudent',
                                  child: Text('Vytvoriť nového študenta'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'select_all') {
                                  setState(() {
                                    _selectedStudentIds = _filteredStudents
                                        .map((s) => s.id)
                                        .toList();
                                  });
                                } else if (value == 'deselect_all') {
                                  setState(() {
                                    _selectedStudentIds = [];
                                  });
                                } else if (value == 'refresh') {
                                  _loadStudents();
                                } else if (value == 'newStudent') {
                                  _createNewStudent();
                                }
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Tabuľka študentov
                        Expanded(
                          child: _buildStudentsTable(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
  
  Widget _buildStudentsTable() {
    if (_filteredStudents.isEmpty) {
      return const Center(
        child: Text(
          "Nenašli sa žiadni študenti",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text("")),
          DataColumn(label: Text("Študenti")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Potreby")),
          DataColumn(label: Text("Aktívny")),
        ],
        rows: _filteredStudents.map((student) {
          final isSelected = _selectedStudentIds.contains(student.id);
          
          return DataRow(
            selected: isSelected,
            cells: [
              DataCell(
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleStudentSelection(student.id, value ?? false),
                ),
              ),
              DataCell(
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailScreen(student: student),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: student.hasSpecialNeeds 
                            ? Colors.orange 
                            : Colors.blue,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(student.name),
                    ],
                  ),
                ),
              ),
              DataCell(Text(student.status)),
              DataCell(Text(student.needsDescription)),
              DataCell(Text(student.lastActive)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
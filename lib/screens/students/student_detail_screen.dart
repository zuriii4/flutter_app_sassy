import 'package:flutter/material.dart';
import 'package:sassy/models/student.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/screens/students/group_detail_screen.dart';
import 'package:sassy/screens/students/edit_student_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  

  const StudentDetailScreen({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final ApiService _apiService = ApiService();
  late Student _student; // <- lokálna premenná pre študenta
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student; // inicializuj kópiu
  }

  Future<void> _editStudent() async {
    final updatedStudent = await Navigator.push<Student>(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentScreen(
          student: _student,
        ),
      ),
    );

    if (updatedStudent != null) {
      setState(() {
        _student = updatedStudent; // prepíš údaje
      });
    }
  }

  
  Future<void> _deleteStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odstrániť študenta'),
        content: Text('Naozaj chcete odstrániť študenta ${_student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Odstrániť'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
    final success = await _apiService.deleteStudentById(_student.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Študent bol odstránený')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodarilo sa odstrániť študenta')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      appBar: AppBar(
        title: Text(_student.name),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _editStudent, 
            icon: const Icon(Icons.edit, color: Colors.black,),
            tooltip: "Upraviť",
          ),
          IconButton(
            onPressed: _deleteStudent, 
            icon: const Icon(Icons.delete, color: Colors.black,),
            tooltip: "Vymazať",
          )
        ],
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hlavička s informáciami o študentovi
                _buildStudentHeader(),
                const SizedBox(height: 24),
                
                // Štatistiky
                _buildStatistics(),
                const SizedBox(height: 24),
                
                // Údaje o progrese
                _buildProgressSection(),
                const SizedBox(height: 24),
                
                // Skupiny, do ktorých študent patrí
                _buildGroupsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStudentHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: _student.hasSpecialNeeds ? Colors.orange : Colors.blue,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _student.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _student.status == 'Aktívny' 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _student.status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _student.status == 'Aktívny' 
                        ? Colors.green.shade800 
                        : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_student.hasSpecialNeeds) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _student.needsDescription,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Posledná aktivita: ${_student.lastActive}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Poznamky: ${_student.notes}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Štatistiky',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("20", "Celkové lekcie"),
            _buildStatCard("15", "Dokončené"),
            _buildStatCard("80%", "Úspešnosť"),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String count, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progres študenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Graf progresu (placeholder)",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tabuľka progresu
        const Text(
          "Posledné aktivity",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DataTable(
          columns: const [
            DataColumn(label: Text("Lekcia")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Dátum")),
            DataColumn(label: Text("Hodnotenie")),
          ],
          rows: List<DataRow>.generate(
            3,
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
      ],
    );
  }
  
  Widget _buildGroupsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apiService.getStudentGroups(_student.id),
      builder: (context, snapshot) {
        // Zobrazenie loadingu počas načítavania dát
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skupiny študenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }

        // Zobrazenie chyby
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skupiny študenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nepodarilo sa načítať skupiny: ${snapshot.error}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Spustí refresh stránky
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Skúsiť znova'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A261),
                  ),
                ),
              ),
            ],
          );
        }

        // Získanie dát
        final groups = snapshot.data ?? [];

        // Zobrazenie prázdneho stavu
        if (groups.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skupiny študenta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Študent nie je členom žiadnej skupiny',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        // Zobrazenie zoznamu skupín
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skupiny študenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...groups.map((group) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Navigácia na obrazovku skupiny
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                        groupId: group['id'],
                        groupName: group['name'] ?? 'Neznáma skupina',
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.group, color: Colors.blue),
                  ),
                  title: Text(
                    group['name'] ?? 'Neznáma skupina',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${group['studentCount'] ?? 0} študentov'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            )).toList(),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Implementácia pridania do novej skupiny
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Pridať do novej skupiny'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4A261),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
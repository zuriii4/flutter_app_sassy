import 'package:flutter/material.dart';
import 'package:sassy/models/material.dart';
import 'package:sassy/services/api_service.dart';

class TaskAssignmentStep extends StatefulWidget {
  final TaskModel taskModel;
  
  const TaskAssignmentStep({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<TaskAssignmentStep> createState() => _TaskAssignmentStepState();
}

class _TaskAssignmentStepState extends State<TaskAssignmentStep> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  List<dynamic> _selectedStudents = [];
  
  List<dynamic> _allGroups = [];
  List<dynamic> _filteredGroups = [];
  List<dynamic> _selectedGroups = [];
  
  bool _isLoading = true;
  bool _showStudentTab = true; // Pre prepínanie medzi študentmi a skupinami

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
      // Načítanie študentov
      final students = await _apiService.getStudents();
      
      // Načítanie skupín
      final groups = await _apiService.getAllGroupsWithDetails();
      
      setState(() {
        _allStudents = students;
        _filteredStudents = List.from(students);
        
        _allGroups = groups;
        _filteredGroups = List.from(groups);
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri načítavaní dát: $e')),
      );
    }
  }

  void _toggleStudentSelection(dynamic student) {
    setState(() {
      final studentId = student['_id'];
      if (_isStudentSelected(student)) {
        _selectedStudents.removeWhere((s) => s['_id'] == studentId);
        widget.taskModel.assignedTo.remove(studentId);
      } else {
        _selectedStudents.add(student);
        widget.taskModel.assignedTo.add(studentId);
      }
    });
  }

  bool _isStudentSelected(dynamic student) {
    return _selectedStudents.any((s) => s['_id'] == student['_id']);
  }

  void _toggleGroupSelection(dynamic group) {
    setState(() {
      final groupId = group['_id'];
      if (_isGroupSelected(group)) {
        _selectedGroups.removeWhere((g) => g['_id'] == groupId);
        widget.taskModel.assignedGroups.remove(groupId);
      } else {
        _selectedGroups.add(group);
        widget.taskModel.assignedGroups.add(groupId);
      }
    });
  }

  bool _isGroupSelected(dynamic group) {
    return _selectedGroups.any((g) => g['_id'] == group['_id']);
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(_allStudents);
      } else {
        _filteredStudents = _allStudents
            .where((student) => 
                student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                (student['email']?.toString().toLowerCase() ?? '').contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGroups = List.from(_allGroups);
      } else {
        _filteredGroups = _allGroups
            .where((group) => 
                group['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const Text(
                'Priradenie úlohy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF67E4A),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tabs pre prepínanie medzi študentmi a skupinami
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _showStudentTab = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showStudentTab ? const Color(0xFFF67E4A) : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Študenti (${_selectedStudents.length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _showStudentTab ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _showStudentTab = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showStudentTab ? const Color(0xFFF67E4A) : Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Skupiny (${_selectedGroups.length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_showStudentTab ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Vyhľadávanie
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: _showStudentTab 
                      ? 'Vyhľadať študenta' 
                      : 'Vyhľadať skupinu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _showStudentTab 
                                ? _filterStudents('') 
                                : _filterGroups('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _showStudentTab 
                      ? _filterStudents(value) 
                      : _filterGroups(value);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Zoznam študentov alebo skupín
              Expanded(
                child: _showStudentTab
                    ? _buildStudentsList()
                    : _buildGroupsList(),
              ),
            ],
          );
  }

  Widget _buildStudentsList() {
    if (_filteredStudents.isEmpty) {
      return Center(
        child: Text(
          'Žiadni študenti neboli nájdení',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        final isSelected = _isStudentSelected(student);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.blue[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
              child: Text(
                student['name'][0] ?? '?',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            title: Text(student['name'] ?? 'Neznámy študent'),
            subtitle: Text(student['email'] ?? ''),
            trailing: Checkbox(
              value: isSelected,
              activeColor: Colors.blue,
              onChanged: (_) => _toggleStudentSelection(student),
            ),
            onTap: () => _toggleStudentSelection(student),
          ),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    if (_filteredGroups.isEmpty) {
      return Center(
        child: Text(
          'Žiadne skupiny neboli nájdené',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _filteredGroups.length,
      itemBuilder: (context, index) {
        final group = _filteredGroups[index];
        final isSelected = _isGroupSelected(group);
        final studentCount = group['students']?.length ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.green[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.green : Colors.grey[300],
              child: Text(
                group['name'][0] ?? '?',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            title: Text(group['name'] ?? 'Neznáma skupina'),
            subtitle: Text('Počet študentov: $studentCount'),
            trailing: Checkbox(
              value: isSelected,
              activeColor: Colors.green,
              onChanged: (_) => _toggleGroupSelection(group),
            ),
            onTap: () => _toggleGroupSelection(group),
          ),
        );
      },
    );
  }
}
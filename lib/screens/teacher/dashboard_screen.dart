import 'package:flutter/material.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/screens/teacher/students/student_detail_screen.dart';
import 'package:sassy/models/student.dart';
import 'package:sassy/screens/teacher/material_steps/material_detail_screen.dart';
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
  List<dynamic> _notifications = [];
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
      final onlineStudentsResult = await _apiService.getOnlineStudents();
      final materialsResult = await _apiService.getAllMaterials();
      final notificationsResult = await _apiService.getNotifications(limit: 10);


      List<Student> completeStudents = [];
      for (var onlineStudent in onlineStudentsResult) {
        String? studentId = onlineStudent['studentId'] ?? onlineStudent['_id'];

        if (studentId == null) continue;

        try {
          final studentDetails = await _apiService.getStudentDetails(studentId);
          completeStudents.add(Student.fromJson(studentDetails));
        } catch (e) {
          print('Failed to fetch details for student $studentId: $e');
        }
      }

      setState(() {
        _students = completeStudents;
        _materials = materialsResult;
        _notifications = notificationsResult;
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

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Online študenti",
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
                    "Momentálne nie sú žiadni študenti online",
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
                            ? "Aktívny" 
                            : student.needsDescription,
                        style: const TextStyle(fontSize: 12),
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: student.hasSpecialNeeds
                                ? Colors.orange
                                : Colors.blue,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          // Online indicator
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Oznámenia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E48),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  try {
                    final success = await _apiService.markAllNotificationsAsRead();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Všetky oznámenia označené ako prečítané')),
                      );
                      _loadData();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chyba: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Označiť všetky ako prečítané'),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _notifications.isEmpty
              ? const Center(
                  child: Text(
                    "Nemáte žiadne oznámenia",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final bool isRead = notification['isRead'] ?? false;
                    final String type = notification['type'] ?? 'system';

                    IconData iconData;
                    Color iconColor;

                    switch (type) {
                      case 'material_assigned':
                        iconData = Icons.assignment;
                        iconColor = Colors.blue;
                        break;
                      case 'material_completed':
                        iconData = Icons.task_alt;
                        iconColor = Colors.green;
                        break;
                      default:
                        iconData = Icons.notification_important;
                        iconColor = Colors.orange;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isRead ? null : Colors.blue.shade50,
                      child: ListTile(
                        title: Text(
                          notification['title'] ?? "Oznámenie",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['message'] ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(notification['createdAt']),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        leading: Icon(
                          iconData,
                          color: iconColor,
                        ),
                        trailing: isRead
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () async {
                                  try {
                                    final success = await _apiService.markNotificationAsRead(notification['_id']);
                                    if (success) {
                                      _loadData();
                                    }
                                  } catch (e) {
                                    print('Error marking notification as read: $e');
                                  }
                                },
                                tooltip: 'Označiť ako prečítané',
                              ),
                        onTap: () {
                          if (!isRead) {
                            _apiService.markNotificationAsRead(notification['_id']).then((_) {
                              _loadData();
                            });
                          }

                          if (notification['relatedId'] != null) {
                            if (type == 'material_assigned' || type == 'material_completed') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MaterialDetailScreen(
                                    materialId: notification['relatedId'],
                                  ),
                                ),
                              ).then((_) => _loadData());
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorStateWidget(
                  errorMessage: _errorMessage!, 
                  onRetry: _loadData
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
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
                            height: 300,
                            child: _materials.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Zatiaľ nemáte žiadne Materialy",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = constraints.maxWidth > 1000
                                          ? 3
                                          : constraints.maxWidth > 600 
                                            ? 2
                                            : 1;

                                      return GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
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
                                      );
                                    }
                                  ),
                          ),
                          const SizedBox(height: 20),
                          
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return constraints.maxWidth > 700
                                  ? SizedBox(
                                      height: 400,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildStudentsSection(),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: _buildNotificationsSection(),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 300,
                                          child: _buildStudentsSection(),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          height: 300,
                                          child: _buildNotificationsSection(),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

String _formatDate(String? dateString) {
  if (dateString == null) return '';

  try {
    final DateTime date = DateTime.parse(dateString);
    final DateTime now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'deň' : difference.inDays < 5 ? 'dni' : 'dní'} dozadu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hodina' : difference.inHours < 5 ? 'hodiny' : 'hodín'} dozadu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minúta' : difference.inMinutes < 5 ? 'minúty' : 'minút'} dozadu';
    } else {
      return 'Práve teraz';
    }
  } catch (e) {
    return dateString;
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Skúsiť znova'),
          ),
        ],
      ),
    );
  }
}
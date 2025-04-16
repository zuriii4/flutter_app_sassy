import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sassy/models/student.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/widgets/form_fields.dart';
import 'package:sassy/widgets/message_display.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;

  const EditStudentScreen({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late TextEditingController _dateOfBirthController;
  bool _hasSpecialNeeds = false;
  late TextEditingController _needsDescriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    _notesController = TextEditingController(text: widget.student.notes);
    _hasSpecialNeeds = widget.student.hasSpecialNeeds;
    _needsDescriptionController = TextEditingController(text: widget.student.needsDescription);
    
    // Inicializácia dátumu narodenia
    if (widget.student.dateOfBirth != null) {
      // Formátovanie dátumu do DD/MM/RRRR
      final date = widget.student.dateOfBirth!;
      _dateOfBirthController = TextEditingController(
        text: '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
      );
    } else {
      _dateOfBirthController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _needsDescriptionController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parsovanie dátumu narodenia
      DateTime? birthDate;
      if (_dateOfBirthController.text.isNotEmpty) {
        try {
          birthDate = _parseDateOfBirth(_dateOfBirthController.text);
        } catch (e) {
          setState(() {
            _errorMessage = "Neplatný formát dátumu. Použite formát DD/MM/RRRR";
            _isLoading = false;
          });
          return;
        }
      }

      // Použite novú metódu updateUserById
      final success = await _apiService.updateUserById(
        userId: widget.student.id,
        name: _nameController.text,
        email: _emailController.text,
        notes: _notesController.text,
        hasSpecialNeeds: _hasSpecialNeeds,
        needsDescription: _hasSpecialNeeds ? _needsDescriptionController.text : null,
        dateOfBirth: birthDate,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Údaje boli úspešne aktualizované')),
        );
        
        // Vráťte aktualizované údaje študenta na predchádzajúcu obrazovku
        Navigator.pop(
          context, 
          Student(
            id: widget.student.id,
            name: _nameController.text,
            email: _emailController.text,
            notes: _notesController.text,
            status: widget.student.status,
            hasSpecialNeeds: _hasSpecialNeeds,
            needsDescription: _hasSpecialNeeds ? _needsDescriptionController.text : '',
            lastActive: widget.student.lastActive,
            dateOfBirth: birthDate,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Nepodarilo sa aktualizovať údaje';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Pomocná metóda na parsovanie dátumu
  DateTime _parseDateOfBirth(String date) {
    // Kontrola, či je dátum v správnom formáte (DD/MM/YYYY alebo DD.MM.YYYY)
    final separator = date.contains('/') ? '/' : '.';
    final parts = date.split(separator);
    
    if (parts.length == 3) {
      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } catch (e) {
        throw Exception('Neplatný formát dátumu');
      }
    } else {
      throw Exception('Neplatný formát dátumu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      appBar: AppBar(
        title: const Text('Upraviť študenta'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Uložiť'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          MessageDisplay(
                            message: _errorMessage!,
                            type: MessageType.error,
                          ),
                        
                        // Profile image placeholder
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: _hasSpecialNeeds ? Colors.orange : Colors.blue,
                                child: const Icon(Icons.person, size: 50, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Name field
                        FormTextField(
                          label: 'Meno a priezvisko',
                          placeholder: 'Zadajte meno a priezvisko',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field
                        FormTextField(
                          label: 'E-mail',
                          placeholder: 'Zadajte e-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        
                        // Date of Birth field
                        FormDateField(
                          label: 'Dátum narodenia',
                          placeholder: 'DD/MM/RRRR',
                          controller: _dateOfBirthController,
                        ),
                        const SizedBox(height: 16),
                        
                        // Special needs checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _hasSpecialNeeds,
                              onChanged: (value) {
                                setState(() {
                                  _hasSpecialNeeds = value ?? false;
                                });
                              },
                            ),
                            const Text('Študent má špeciálne potreby'),
                          ],
                        ),
                        
                        // Special needs description (conditional)
                        if (_hasSpecialNeeds) ...[
                          const SizedBox(height: 16),
                          FormTextField(
                            label: 'Popis špeciálnych potrieb',
                            placeholder: 'Zadajte popis špeciálnych potrieb',
                            controller: _needsDescriptionController,
                          ),
                        ],
                        const SizedBox(height: 16),
                        
                        // Notes field
                        FormTextField(
                          label: 'Poznámky',
                          placeholder: 'Zadajte poznámky',
                          controller: _notesController,
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF4A261),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Uložiť zmeny',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _isLoading 
        ? Container(
            height: 4,
            child: const LinearProgressIndicator(),
          )
        : null,
    );
  }
}
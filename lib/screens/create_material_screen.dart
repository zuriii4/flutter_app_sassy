import 'package:flutter/material.dart';
import 'package:sassy/screens/material_steps/material_info_step.dart';
import 'package:sassy/screens/material_steps/material_type_step.dart';
import 'package:sassy/screens/material_steps/material_content_step.dart';
import 'package:sassy/screens/material_steps/material_assignment_step.dart';
import 'package:sassy/services/api_service.dart';
import 'package:sassy/models/material.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final ApiService _apiService = ApiService();
  
  // Model pre uchovanie dát v rámci krokov
  final TaskModel taskModel = TaskModel(
    title: '',
    description: '',
    type: '',
    content: {},
    assignedTo: [],
    assignedGroups: []
  );
  
  // Referencia na obsah aktuálnej úlohy, ktorý sa mení podľa typu
  Widget _contentStep = Container();

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // Metóda pre výber typu úlohy
  void _selectTaskType(String type) {
    setState(() {
      taskModel.type = type;
      
      // Zmena obsahu kroku podľa vybraného typu úlohy
      switch (type) {
        case 'quiz':
          _contentStep = TaskContentQuizStep(taskModel: taskModel);
          break;
        case 'puzzle':
          _contentStep = TaskContentPuzzleStep(taskModel: taskModel);
          break;
        case 'word-jumble':
          _contentStep = TaskContentWordJumbleStep(taskModel: taskModel);
          break;
        case 'connection':
          _contentStep = TaskContentConnectionStep(taskModel: taskModel);
          break;
        default:
          _contentStep = Container();
      }
    });
    
    // Automatický presun na ďalší krok po výbere typu
    _nextStep();
  }

  // Metóda pre odosielanie dát na server
  Future<void> _submitTask() async {
    try {
      final result = await _apiService.createMaterial(
        title: taskModel.title,
        type: taskModel.type,
        content: taskModel.content,
        description: taskModel.description,
        assignedTo: taskModel.assignedTo.isNotEmpty ? taskModel.assignedTo.join(',') : null,
        assignedGroups: taskModel.assignedGroups,
      );
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Úloha bola úspešne vytvorená')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri vytváraní úlohy')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
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
                    children: [
                      // Čísla a indikátor krokov
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_currentStep + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'BowlbyOneSC',
                                    fontSize: 40,
                                    color: Color(0xFFF67E4A),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                4,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index <= _currentStep
                                        ? const Color(0xFFF67E4A)
                                        : const Color(0xFFE0E0E0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Krok 1: Základné informácie o úlohe
                            TaskInfoStep(taskModel: taskModel),
                            
                            // Krok 2: Výber typu úlohy
                            TaskTypeStep(onSelectType: _selectTaskType),
                            
                            // Krok 3: Dynamický obsah podľa typu úlohy
                            _contentStep,
                            
                            // Krok 4: Priradenie študentov/skupín
                            TaskAssignmentStep(taskModel: taskModel),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 0)
                              ElevatedButton(
                                onPressed: _previousStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF67E4A),
                                  foregroundColor: Colors.white, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Späť'),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                if (_currentStep == 3) {
                                  _submitTask();
                                } else if (_currentStep != 1) { // Ak nie je na kroku výberu typu
                                  _nextStep();
                                }
                                // Pre krok 1 (výber typu) sa posun riadi funkciou _selectTaskType
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF67E4A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0, 
                                shadowColor: Colors.transparent, 
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_currentStep == 3 ? 'Dokončiť' : 'Ďalej'),
                            )
                          ],
                        ),
                      ),
                    ],
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
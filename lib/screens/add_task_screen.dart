import 'package:flutter/material.dart';
// import 'package:sassy/screens/dashboard_screen.dart';
import 'package:sassy/screens/main_screen.dart';
import 'package:sidebarx/sidebarx.dart';
// import 'package:sassy/widgets/sidebar.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final PageController _pageController = PageController();
  final SidebarXController _controller = SidebarXController(selectedIndex: 0);
  int _currentStep = 0;
  bool _showImageSelection = false; // Stavová premenná pre zobrazenie widgetov
  bool _showDragAndDrop = false; // Stav pre zobrazenie drag-and-drop sekcie
  String? _uploadedFileName; // Uchová meno nahraného súboru


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

  void _selectImage() {
    setState(() {
      _showImageSelection = true; // Po kliknutí sa zobrazia widgety
      _showDragAndDrop = false;
    });
  }


  void _showUploadWidget() {
    setState(() {
      _showDragAndDrop = true; // Po kliknutí sa zobrazí drag-and-drop
      _showImageSelection = false;
    });
  }

  void _handleFileUpload(String fileName) {
    setState(() {
      _uploadedFileName = fileName; // Nastavenie mena súboru po nahraní
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 230, 217),
      body: Row(
        children: [
          // Sidebar(controller: _controller), // Sidebar naľavo
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
                            _buildStep1(),
                            _buildStep2(),
                            _buildStep3(),
                            _buildStep4(),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainScreen()),
                                  );
                                } else {
                                  _nextStep();
                                }
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

  Widget _buildStep1() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Názov úlohy',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Popis úlohy',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Vybrať úlohu',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: 'Možnosť 1', child: Text('Možnosť 1')),
            DropdownMenuItem(value: 'Možnosť 2', child: Text('Možnosť 2')),
          ],
          onChanged: (value) {},
        ),
      ),
    );
  }

Widget _buildStep3() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _selectImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF67E4A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Vybrať obrázok'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showUploadWidget,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF67E4A),
              foregroundColor: Colors.white,
              ),
            child: const Text('Nahrať obrázok'),
          ),
          const SizedBox(height: 20),
          if (_showDragAndDrop) _buildDragAndDropWidget(),
          if (_showImageSelection) _buildImageSelection(),
        ],
      ),
    );
  }

  Widget _buildImageSelection() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Text(
              'Vybrať obrázok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                6,
                (index) => _buildImageTile(index),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Výška',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Šírka',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                },
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildImageTile(int index) {
  final isSelected = ValueNotifier<bool>(false); 

  return InkWell(
    onTap: () {
      isSelected.value = !isSelected.value; // Toggle selection on tap
    },
    child: Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        color: isSelected.value ? Colors.blue.shade200 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          const Text( 
            '300 x 200',
            style: TextStyle(color: Colors.grey),
          ),
          if (isSelected.value)
            Icon(Icons.check, color: Colors.white),
        ],
      ),
    ),
  );
}

Widget _buildDragAndDropWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: () {
              _handleFileUpload('obrazok.png'); 
            },
            onPanUpdate: (details) {
              _handleFileUpload('obrazok_dragged.png');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 50,
                  color: Colors.amber,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vložiť obrázok',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                const Text(
                  'maximálna veľkosť: 10 MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_uploadedFileName != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                const Text(
                  'Súbor bol úspešne nahraný:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _uploadedFileName!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Výška',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Šírka',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildStep4() {
  return StatefulBuilder(
    builder: (context, setState) {
      final TextEditingController searchController = TextEditingController();
      List<String> students = ['Študent 1', 'Študent 2', 'Študent 3', 'Študent 4', 'Študent 5'];
      List<String> filteredStudents = List.from(students);

      void filterStudents(String query) {
        setState(() {
          if (query.isEmpty) {
            filteredStudents = List.from(students);
          } else {
            filteredStudents = students
                .where((student) => student.toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
        });
      }

      void deleteStudent(String student) {
        setState(() {
          students.remove(student);
          filterStudents(searchController.text); // Aktualizuje filtrovaný zoznam
        });
      }

      void addStudent(String student) {
        if (student.isNotEmpty && !students.contains(student)) {
          setState(() {
            students.add(student);
            filterStudents(searchController.text); // Aktualizuje filtrovaný zoznam
          });
        }
      }

      return Center(
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Vyhľadávanie študentov',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    addStudent(searchController.text);
                    searchController.clear(); // Vymaže textové pole
                  },
                ),
              ),
              onChanged: filterStudents,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(student[0]), // Prvé písmeno mena
                    ),
                    title: Text(student),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteStudent(student), // Odstráni študenta
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
}
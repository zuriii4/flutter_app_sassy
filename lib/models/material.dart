class TaskModel {
  String title;
  String description;
  String type; // 'puzzle', 'word-jumble', 'quiz', 'connection'
  Map<String, dynamic> content;
  List<String> assignedTo; // Zoznam ID študentov
  List<String> assignedGroups; // Zoznam ID skupín

  TaskModel({
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.assignedTo,
    required this.assignedGroups,
  });

  // Helper metódy pre konkrétne typy úloh
  
  // Pre typ quiz
  void addQuizQuestion(String text, List<Map<String, dynamic>> answers, {String? image}) {
    if (type != 'quiz') return;
    
    if (!content.containsKey('questions')) {
      content['questions'] = [];
    }
    
    final question = {
      'text': text,
      'answers': answers,
    };
    
    if (image != null) {
      question['image'] = image;
    }
    
    content['questions'].add(question);
  }
  
  // Pre typ puzzle
  void setPuzzleContent(String image, int columns, int rows) {
    if (type != 'puzzle') return;
    
    content = {
      'image': image,
      'grid': {
        'columns': columns,
        'rows': rows
      }
    };
  }
  
  // Pre typ word-jumble
  void setWordJumbleContent(List<String> words, List<String> correctOrder) {
    if (type != 'word-jumble') return;
    
    content = {
      'words': words,
      'correct_order': correctOrder
    };
  }
  
  // Pre typ connection
  void setConnectionContent(List<Map<String, String>> pairs) {
    if (type != 'connection') return;
    
    content = {
      'pairs': pairs
    };
  }
  
  // Validácia obsahu podľa typu
  bool isContentValid() {
    switch (type) {
      case 'quiz':
        return content.containsKey('questions') && 
               (content['questions'] as List).isNotEmpty;
      case 'puzzle':
        return content.containsKey('image') && 
               content.containsKey('grid');
      case 'word-jumble':
        return content.containsKey('words') && 
               content.containsKey('correct_order');
      case 'connection':
        return content.containsKey('pairs') && 
               (content['pairs'] as List).isNotEmpty;
      default:
        return false;
    }
  }
}
class Student {
  final String id;
  final String name;
  final String email;
  final String notes;
  final String status;
  final String needsDescription;
  final String lastActive;
  final bool hasSpecialNeeds;
  final DateTime? dateOfBirth;
  
  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.notes,
    required this.status,
    required this.needsDescription,
    required this.lastActive,
    required this.hasSpecialNeeds,
    this.dateOfBirth,  // zmenené na nepovinné
  });

  // Factory metóda na vytvorenie Student objektu z JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    // Správne parsovanie dateOfBirth z JSON
    DateTime? parsedDate;
    if (json['dateOfBirth'] != null) {
      try {
        parsedDate = DateTime.parse(json['dateOfBirth']);
      } catch (e) {
        // V prípade neplatného dátumu necháme null
        parsedDate = null;
      }
    }
    
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Aktívny',
      needsDescription: json['needsDescription'] ?? '',
      lastActive: json['lastActive'] ?? 'Dnes',
      hasSpecialNeeds: json['hasSpecialNeeds'] ?? false,
      dateOfBirth: parsedDate,  // použitie sparsovaného dátumu
    );
  }

  // Metóda na konvertovanie objektu Student na JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notes': notes,
      'status': status,
      'needsDescription': needsDescription,
      'lastActive': lastActive,
      'hasSpecialNeeds': hasSpecialNeeds,
      'dateOfBirth': dateOfBirth?.toIso8601String(),  // konverzia na ISO string s null-safety
    };
  }
}
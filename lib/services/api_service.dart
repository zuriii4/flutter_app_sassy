import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ✅ Prihlásenie používateľa
  Future<String?> login(String email, String password) async {
    try {
      final body = jsonEncode({'email': email, 'password': password});

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Uloženie tokenu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return token;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Chyba pri prihlasovaní: $e');
      return null;
    }
  }

  // ✅ Získanie materiálov pre študenta
  Future<List<dynamic>> getMaterials(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/materials/$studentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nepodarilo sa načítať materiály.');
    }
  }

  // 🟢 Získanie detailov konkrétneho materiálu
  Future<Map<String, dynamic>?> getMaterialDetails(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // print("id: $materialId");

    final response = await http.get(
      Uri.parse('$baseUrl/materials/details/$materialId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // 🟡 Odoslanie odpovedí študenta
  Future<bool> submitMaterial({
    required String studentId,
    required String materialId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/materials/submit-material'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'studentId': studentId,
        'materialId': materialId,
        'answers': answers,
      }),
    );

    return response.statusCode == 201;
  }

  // ✅ Registrácia používateľa
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required DateTime dateOfBirth,
    String? specialization,
    String? group,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        if (specialization != null) 'specialization': specialization,
        if (group != null) 'group': group,
      }),
    );

    return response.statusCode == 201;
  }

  // ✅ Získanie informácií o aktuálnom používateľovi
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    // print('📩 Status kód: ${response.statusCode}');
    // print('📦 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // ✅ Odhlásenie používateľa
  Future<bool> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/users/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateUser({
    String? name,
    String? email,
    String? password,
    String? role,
    String? notes,
    String? specialization,
    bool? hasSpecialNeeds,
    DateTime? dateOfBirth,
    String? needsDescription,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (role != null) 'role': role,
        if (notes != null) 'notes': notes,
        if (specialization != null) 'specialization': specialization,
        if (hasSpecialNeeds != null) 'hasSpecialNeeds': hasSpecialNeeds,
        if (needsDescription != null) 'needsDescription': needsDescription,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(), // Convert to ISO format
      }),
    );
    
    // print('📩 Status kód: ${response.statusCode}');
    // print('📦 Response body: ${response.body}');
    
    return response.statusCode == 200;
  }

  // Aktualizácia používateľa podľa ID (pre admin/učiteľ funkcie)
  Future<bool> updateUserById({
    required String userId,  // ID používateľa, ktorého aktualizujeme
    String? name,
    String? email,
    String? password,
    String? notes,
    String? specialization,
    bool? hasSpecialNeeds,
    DateTime? dateOfBirth,
    String? needsDescription,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.put(
      Uri.parse('$baseUrl/students/update/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (notes != null) 'notes': notes,
        if (specialization != null) 'specialization': specialization,
        if (hasSpecialNeeds != null) 'hasSpecialNeeds': hasSpecialNeeds,
        if (needsDescription != null) 'needsDescription': needsDescription,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      }),
    );
    
    // print('📩 Status kód: ${response.statusCode}');
    // print('📦 Response body: ${response.body}');
    
    return response.statusCode == 200;
  }

  // 🟢 Vytvorenie novej skupiny
  Future<bool> createGroup({
    required String name,
    required String teacherId,
    required List<String> studentIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/groups/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'teacherId': teacherId,
        'studentIds': studentIds,
      }),
    );
    // print(response.body);

    return response.statusCode == 201;
  }

  // 🟢 Pridanie študenta do skupiny
  Future<bool> addStudentToGroup({
    required String groupId,
    required String studentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/groups/groups/add-student'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'groupId': groupId,
        'studentId': studentId,
      }),
    );
    // print(response.body);
    return response.statusCode == 200;
  }

  // 🔴 Odstránenie skupiny
  Future<bool> deleteGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/groups/groups/$groupId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
  
  // 🟢 Nahrávanie obrázka na server
  Future<String?> uploadImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Používateľ nie je prihlásený');
      }
      
      // Vytvorenie formData pre multipart request
      final dio = Dio();
      
      // Získanie názvu súboru a typu zo súborového rozšírenia
      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      MediaType? contentType;
      
      // Nastavenie správneho typu obsahu podľa prípony súboru
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType.parse('image/jpeg');
          break;
        case 'png':
          contentType = MediaType.parse('image/png');
          break;
        case 'gif':
          contentType = MediaType.parse('image/gif');
          break;
        case 'webp':
          contentType = MediaType.parse('image/webp');
          break;
        default:
          contentType = MediaType.parse('image/jpeg'); // Predvolený typ
      }
      
      // Vytvorenie FormData so správnym názvom poľa 'image'
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: contentType,
        ),
      });
      
      // Odoslanie požiadavky na server
      final response = await dio.post(
        '$baseUrl/materials/image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data', // Explicitne nastavenie typu obsahu
          },
          followRedirects: false,
          validateStatus: (status) => true, // Akceptácia akéhokoľvek stavového kódu pre ladenie
        ),
      );
      
      if (response.statusCode == 200) {
        // Vrátime cestu k nahranému obrázku
        return response.data['filePath'];
      } else {
        print('❌ Chyba pri nahrávaní obrázka: ${response.statusCode}');
        print('❌ Response data: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Výnimka pri nahrávaní obrázka: $e');
      return null;
    }
  }
  
  // 🟢 Získanie obrázka ako bajtov
  Future<Uint8List?> getImageBytes(String fullPath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
 
    final response = await http.post(
      Uri.parse('$baseUrl/materials/get-image'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'path': fullPath}),
    );
 
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('❌ Chyba pri získavaní obrázka: ${response.statusCode}');
      return null;
    }
  }
  
  // 🟡 Aktualizácia metódy createMaterial pre podporu nahrávania obrázkov
  Future<bool> createMaterial({
    required String title,
    required String type,
    required Map<String, dynamic> content,
    String? description,
    List<String>? assignedTo,
    List<String>? assignedGroups,
    File? imageFile, // Nový parameter pre súbor obrázka
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Ak ide o typ puzzle a máme súbor obrázka, najprv ho nahráme
    if (type == 'puzzle' && imageFile != null) {
      final imagePath = await uploadImage(imageFile);
      if (imagePath != null) {
        // Aktualizujeme obsah s cestou k obrázku
        content['image'] = imagePath;
      } else {
        return false; // Zlyhalo nahrávanie obrázka
      }
    }
    
    // Pokračujeme so štandardným vytvorením materiálu
    final body = {
      'title': title,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
      if (assignedGroups != null && assignedGroups.isNotEmpty) 'assignedGroups': assignedGroups,
    };
        
    final response = await http.post(
      Uri.parse('$baseUrl/materials/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    print(response.body);
    return response.statusCode == 201;
  }
  
  // 🟡 Aktualizácia materiálu s podporou obrázkov
  Future<bool> updateMaterial({
    required String materialId,
    String? title,
    String? description,
    String? type,
    Map<String, dynamic>? content,
    List<String>? assignedTo,  // Zmena z String? na List<String>?
    List<String>? assignedGroups,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Ak máme nový obrázok a content nie je null
    if (imageFile != null && content != null && type == 'puzzle') {
      final imagePath = await uploadImage(imageFile);
      if (imagePath != null) {
        content['image'] = imagePath;
      } else {
        return false;
      }
    }
 
    final body = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (assignedTo != null && assignedTo.isNotEmpty) 'assignedTo': assignedTo,
      if (assignedGroups != null && assignedGroups.isNotEmpty) 'assignedGroups': assignedGroups,
    };
 
    final response = await http.put(
      Uri.parse('$baseUrl/materials/materials/$materialId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
 
    print(response.body);
 
    return response.statusCode == 200;
  }


  // 🔴 Odstránenie materiálu
  Future<bool> deleteMaterial(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/materials/materials/$materialId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // 🟢 Získanie parametrov daného materiálu
  Future<Map<String, dynamic>?> getMaterialParams(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/materials/details/$materialId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['material'];
    } else {
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$baseUrl/users/validate-token'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // Získanie zoznamu všetkých študentov
  Future<List<dynamic>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nepodarilo sa načítať študentov');
    }
  }

  // Získanie detailov konkrétneho študenta
  Future<Map<String, dynamic>> getStudentDetails(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // print(response.body);


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nepodarilo sa načítať detaily študenta');
    }
  }

  // Získanie skupín študenta
  Future<List<Map<String, dynamic>>> getStudentGroups(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }
    print(studentId);
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId/groups'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Nepodarilo sa načítať skupiny študenta');
    }
  }

  // Vyhľadávanie študentov
  Future<List<dynamic>> searchStudents(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/students/search?q=${Uri.encodeComponent(query)}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nepodarilo sa vyhľadať študentov');
    }
  }

  // Odstránenie študenta zo skupiny
  Future<bool> removeStudentFromGroup(String groupId, String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    // print(studentId);
    final response = await http.delete(
      Uri.parse('$baseUrl/students/groups/$groupId/students/$studentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // print(response.body);

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> getTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/teacher'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print(data);
      return data['teacher']; // Vraciaš konkrétny objekt učiteľa
    } else {
      throw Exception('Nepodarilo sa načítať učiteľa');
    }
  }

// ✅ Získanie detailov skupiny vrátane učiteľa a študentov
  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/groups/group/$groupId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nepodarilo sa načítať detail skupiny');
    }
  }

  // 🟢 Získanie všetkých skupín s detailmi učiteľa a študentov
  Future<List<Map<String, dynamic>>> getAllGroupsWithDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/groups/groups'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Nepodarilo sa načítať skupiny');
    }
  }

  Future<List<Map<String, dynamic>>> getAllMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/materials/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Nepodarilo sa načítať skupiny');
    }
  }

  
  
  // 🟥 Odstránenie aktuálne prihláseného používateľa
  Future<bool> deleteCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
  
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }
  
    final response = await http.delete(
      Uri.parse('$baseUrl/users/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
  
    return response.statusCode == 200;
  }
  
  // 🟥 Odstránenie študenta podľa ID (admin alebo učiteľ)
  Future<bool> deleteStudentById(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
  
    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }
  
    final response = await http.delete(
      Uri.parse('$baseUrl/students/delete/$studentId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  
    return response.statusCode == 200;
  }

  Future<bool> saveMaterialAsTemplate(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/materials/save-as-template'), // uprav podľa reálnej cesty
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'materialId': materialId}),
    );

    if (response.statusCode == 201) {

      return true;
    } else {
      return false;
    }
  }

  // 🟢 Získanie všetkých šablón materiálov
  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Používateľ nie je prihlásený');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/materials/templates'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Nepodarilo sa načítať šablóny materiálov');
    }
  }

}


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

    final response = await http.get(
      Uri.parse('$baseUrl/materials/details/$materialId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['material'];
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

  // ✅ Aktualizácia používateľa
  Future<bool> updateUser({
    String? name,
    String? email,
    String? password,
    String? role,
    String? specialization,
    String? group,
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
        if (specialization != null) 'specialization': specialization,
        if (group != null) 'group': group,
      }),
    );

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
      Uri.parse('$baseUrl/groups'),
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
      Uri.parse('$baseUrl/groups/add-student'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'groupId': groupId,
        'studentId': studentId,
      }),
    );

    return response.statusCode == 200;
  }

  // 🔴 Odstránenie skupiny
  Future<bool> deleteGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/groups/$groupId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // 🟢 Vytvorenie nového materiálu
  Future<bool> createMaterial({
    required String title,
    required String type,
    required Map<String, dynamic> content,
    String? description,
    String? assignedTo,
    List<String>? assignedGroups,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = {
      'title': title,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (assignedGroups != null) 'assignedGroups': assignedGroups,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/materials/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 201;
  }

  // 🟡 Aktualizácia materiálu
  Future<bool> updateMaterial({
    required String materialId,
    String? title,
    String? description,
    String? type,
    Map<String, dynamic>? content,
    String? assignedTo,
    List<String>? assignedGroups,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (assignedGroups != null) 'assignedGroups': assignedGroups,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/materials/materials/$materialId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

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
}
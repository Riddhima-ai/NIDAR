import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> getStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/status'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to get backend status: ${response.statusCode}',
    );
  }
}
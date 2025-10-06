import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendService {
  final String baseUrl;

  BackendService({required this.baseUrl});

  /// Saves user profile data to the backend MongoDB after Firebase registration/login.
  ///
  /// Returns true on success, false otherwise.
  Future<bool> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
    required String firebaseIdToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: jsonEncode({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print(
          'Failed to save user profile: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  }

  /// Fetches user profile data by UID from the backend.
  ///
  /// Returns JSON map on success, throws on failure.
  Future<Map<String, dynamic>> getUserProfile({
    required String uid,
    required String firebaseIdToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/$uid');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $firebaseIdToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }
}

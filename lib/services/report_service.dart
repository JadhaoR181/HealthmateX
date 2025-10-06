import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  // Change this to your backend URL
  static const String baseUrl =
      'https://healthmatex-backend.onrender.com'; // For local testing
  // static const String baseUrl = 'https://your-api.com'; // For production

  final Dio _dio = Dio();
  final FirebaseAuth _auth = FirebaseAuth.instance;

// Get Firebase ID token
  Future<String> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Force refresh to get fresh token
      final token = await user.getIdToken(true);
      if (token == null) throw Exception('Failed to get authentication token');
      return token;
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  // Upload image to S3 via backend
  Future<Map<String, dynamic>> uploadReportToS3({
    required File imageFile,
    required String reportName,
  }) async {
    try {
      final idToken = await _getIdToken();
      final fileName = imageFile.path.split('/').last;

      // Step 1: Get presigned URL from backend
      final urlResponse = await http.post(
        Uri.parse('$baseUrl/api/generate-upload-url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'file_name': fileName,
          'file_type': 'image/jpeg',
        }),
      );

      if (urlResponse.statusCode != 200) {
        throw Exception('Failed to get upload URL: ${urlResponse.body}');
      }

      final urlData = jsonDecode(urlResponse.body);
      final uploadUrl = urlData['upload_url'];
      final s3Url = urlData['file_url'];
      final fileKey = urlData['file_key'];

      print('✅ Step 1: Got presigned URL');

      // Step 2: Upload file to S3
      final fileBytes = await imageFile.readAsBytes();
      final uploadResponse = await _dio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {'Content-Type': 'image/jpeg'},
        ),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Failed to upload to S3');
      }

      print('✅ Step 2: Uploaded to S3');

      // Step 3: Save metadata to MongoDB
      final saveResponse = await http.post(
        Uri.parse('$baseUrl/api/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': reportName,
          's3_url': s3Url,
          'file_key': fileKey,
        }),
      );

      print('📥 Backend response status: ${saveResponse.statusCode}');
      print('📥 Backend response body: ${saveResponse.body}');

      // ✅ FIXED: Accept both 200 and 201 status codes
      if (saveResponse.statusCode != 200 && saveResponse.statusCode != 201) {
        throw Exception('Failed to save report metadata: ${saveResponse.body}');
      }

      print('✅ Step 3: Saved metadata to MongoDB');

      return {
        'success': true,
        's3_url': s3Url,
        'file_key': fileKey,
      };
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  // Load reports from MongoDB
  Future<List<Map<String, dynamic>>> loadReports() async {
    try {
      final idToken = await _getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/reports'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reportsList = data['reports'] as List;

        return reportsList.map((report) {
          return {
            'id': report['id'],
            'name': report['name'],
            's3_url': report['s3_url'],
            'file_key': report['file_key'],
            'upload_date': DateTime.parse(report['upload_date']),
          };
        }).toList();
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Load reports error: $e');
      return [];
    }
  }

  // Generate presigned URL for viewing
  // Generate presigned URL for viewing image
  Future<String?> getPresignedViewUrl(String fileKey) async {
    try {
      final idToken = await _getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/get-view-url?file_key=$fileKey'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['view_url'];
      }
      return null;
    } catch (e) {
      print('Error getting view URL: $e');
      return null;
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/models/incoming_tutoring_request.dart';
import 'package:peer_tutoring/models/my_tutoring_request.dart';
import 'package:peer_tutoring/models/tutoring_request.dart';
import 'package:peer_tutoring/models/tutoring_session.dart';
import 'package:peer_tutoring/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // --------------------------------------------------
  // AUTHENTICATION HEADERS
  // --------------------------------------------------

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await AuthSession.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // --------------------------------------------------
  // TEST CONNECTION
  // --------------------------------------------------

  static Future<String> testConnection() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/test'),
    );

    if (response.statusCode == 200) {
      return response.body;
    }

    throw Exception(
      'Failed to connect to backend: ${response.statusCode}',
    );
  }

  // --------------------------------------------------
  // USER AUTHENTICATION
  // --------------------------------------------------

  // Public endpoint: login does not require a token.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Login failed: ${response.statusCode} ${response.body}',
    );
  }

  // Public endpoint: registration does not require a token.
  static Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create user: ${response.statusCode} ${response.body}',
    );
  }

  static Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => User.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception(
      'Failed to retrieve users: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> getUserProfile(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load profile: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String name,
    required String university,
    required String major,
    required int year,
    required String bio,
    required String profileImage,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId/profile'),
      headers: await getAuthHeaders(),
      body: jsonEncode({
        'name': name,
        'university': university,
        'major': major,
        'year': year,
        'bio': bio,
        'profileImage': profileImage,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to update profile: ${response.statusCode} ${response.body}',
    );
  }

  // --------------------------------------------------
  // TUTORING REQUESTS
  // --------------------------------------------------

  static Future<void> createTutoringRequest(
    TutoringRequest request,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tutoring-requests'),
      headers: await getAuthHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to send request: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<MyTutoringRequest>> getMyRequests(
    int requesterId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/tutoring-requests/requester/$requesterId',
      ),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => MyTutoringRequest.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load tutoring requests: ${response.statusCode}',
    );
  }

  static Future<List<IncomingTutoringRequest>> getIncomingRequests(
    int tutorId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tutoring-requests/tutor/$tutorId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => IncomingTutoringRequest.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Failed to load incoming requests: ${response.statusCode}',
    );
  }

  static Future<void> updateTutoringRequestStatus({
    required int requestId,
    required int tutorId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/tutoring-requests/$requestId/status'),
      headers: await getAuthHeaders(),
      body: jsonEncode({
        'tutorId': tutorId,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update request: ${response.statusCode} ${response.body}',
      );
    }
  }

  // --------------------------------------------------
  // TUTORING SESSIONS
  // --------------------------------------------------

  static Future<Map<String, dynamic>> scheduleTutoringSession(
    TutoringSession session,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tutoring-sessions'),
      headers: await getAuthHeaders(),
      body: jsonEncode(session.toJson()),
    );

    dynamic responseBody;

    try {
      responseBody = jsonDecode(response.body);
    } catch (_) {
      responseBody = null;
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (responseBody is Map<String, dynamic>) {
        return responseBody;
      }

      throw Exception('Unexpected session response.');
    }

    if (responseBody is Map<String, dynamic>) {
      throw Exception(
        responseBody['error'] ?? 'Failed to schedule tutoring session.',
      );
    }

    throw Exception(
      'Failed to schedule tutoring session: ${response.statusCode}',
    );
  }

  static Future<bool> hasScheduleSession(int requestId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tutoring-sessions/request/$requestId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) return true;
    if (response.statusCode == 404) return false;

    throw Exception(
      'Failed to check tutoring session: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getTutorSessions(int tutorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tutoring-sessions/tutor/$tutorId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load tutor sessions: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getStudentSessions(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tutoring-sessions/student/$studentId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load student sessions: ${response.statusCode}',
    );
  }

  // --------------------------------------------------
  // STUDY GROUPS
  // --------------------------------------------------

  static Future<List<dynamic>> getStudyGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-groups'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load study groups: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> searchStudyGroups(
    String subject,
  ) async {
    final uri = Uri.parse('$baseUrl/api/study-groups').replace(
      queryParameters: {'subject': subject},
    );

    final response = await http.get(
      uri,
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to search study groups: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> createStudyGroup({
    required String name,
    required String subject,
    required String description,
    required int creatorId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/study-groups'),
      headers: await getAuthHeaders(),
      body: jsonEncode({
        'name': name,
        'subject': subject,
        'description': description,
        'creatorId': creatorId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to create study group: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> joinStudyGroup({
    required int groupId,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/study-groups/$groupId/join'),
      headers: await getAuthHeaders(),
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to join study group: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> leaveStudyGroup({
    required int groupId,
    required int userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/study-groups/$groupId/leave/$userId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to leave study group: ${response.statusCode} ${response.body}',
    );
  }

  static Future<List<dynamic>> getStudyGroupMembers(
    int groupId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-groups/$groupId/members'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load group members: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> getStudyGroupDetails(
    int groupId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-groups/$groupId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load study group: ${response.statusCode}',
    );
  }

  // --------------------------------------------------
  // STUDY MATERIALS
  // --------------------------------------------------

  static Future<List<dynamic>> getStudyMaterials() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-materials'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load study materials: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> searchStudyMaterials(
    String subject,
  ) async {
    final uri = Uri.parse('$baseUrl/api/study-materials').replace(
      queryParameters: {'subject': subject},
    );

    final response = await http.get(
      uri,
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to search study materials: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> getStudyMaterialById(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-materials/$id'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load study material: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getMyStudyMaterials(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/study-materials/user/$userId'),
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Failed to load your study materials: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> createStudyMaterial({
    required String title,
    required String description,
    required String subject,
    required String fileUrl,
    required int uploadedById,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/study-materials'),
      headers: await getAuthHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'subject': subject,
        'fileUrl': fileUrl,
        'uploadedById': uploadedById,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to create study material: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> deleteStudyMaterial({
    required int materialId,
    required int userId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/study-materials/$materialId',
    ).replace(
      queryParameters: {'userId': userId.toString()},
    );

    final response = await http.delete(
      uri,
      headers: await getAuthHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete study material: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> updateStudyMaterial({
    required int materialId,
    required int userId,
    required String title,
    required String description,
    required String subject,
    required String fileUrl,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/study-materials/$materialId',
    ).replace(
      queryParameters: {'userId': userId.toString()},
    );

    final response = await http.put(
      uri,
      headers: await getAuthHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'subject': subject,
        'fileUrl': fileUrl,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to update study material: ${response.statusCode} ${response.body}',
    );
  }

  // --------------------------------------------------
  // PROFILE IMAGE UPLOAD
  // --------------------------------------------------

  static Future<String> uploadProfileImage({
    required int userId,
    required XFile imageFile,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/users/$userId/profile-image',
    );

    final request = http.MultipartRequest('POST', uri);

    final token = await AuthSession.getToken();

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final bytes = await imageFile.readAsBytes();

    final filename = imageFile.name.isNotEmpty
        ? imageFile.name
        : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: http.MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['profileImage'].toString();
    }

    throw Exception(
      'Failed to upload profile image: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, String>> getImageHeaders() async {
    final token = await AuthSession.getToken();

    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}

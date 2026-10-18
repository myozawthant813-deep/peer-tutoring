import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peer_tutoring/models/incoming_tutoring_request.dart';
import 'package:peer_tutoring/models/my_tutoring_request.dart';
import 'package:peer_tutoring/models/tutoring_request.dart';
import 'package:peer_tutoring/models/tutoring_session.dart';
import 'package:peer_tutoring/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<String> testConnection() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/test'),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "Failed to connect backend";
    }
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/login"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed: ${response.statusCode}  ${response.body}');
    }
  }

  static Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Failed to create User, Error: ${response.statusCode}, ${response.body}");
    }
  }

  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) {
        return User.fromJson(json);
      }).toList();
    } else {
      throw Exception("Failed to retrive Users");
    }
  }

  static Future<void> createTutoringRequest(TutoringRequest request) async {
    final response = await http.post(
        Uri.parse('$baseUrl/api/tutoring-requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()));

    if (response.statusCode != 201) {
      throw Exception(
          'Failled to send request ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<MyTutoringRequest>> getMyRequests(int requesterId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/tutoring-requests/requester/$requesterId',
      ),
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
      headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> scheduleTutoringSession(
    TutoringSession session,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tutoring-sessions'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(session.toJson()),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return responseBody as Map<String, dynamic>;
    }

    if (responseBody is Map<String, dynamic>) {
      throw Exception(
        responseBody['error'] ?? 'Failed to schedule tutoring session.',
      );
    }

    throw Exception('Failed to schedule tutoring session.');
  }

  static Future<bool> hasScheduleSession(int requestId) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/api/tutoring-sessions/request/$requestId',
    ));
    if (response.statusCode == 200) {
      return true;
    }
    if (response.statusCode == 404) {
      return false;
    }

    throw Exception("failed to check tutoring session!");
  }
}

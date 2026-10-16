import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peer_tutoring/models/my_tutoring_request.dart';
import 'package:peer_tutoring/models/tutoring_request.dart';
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
}

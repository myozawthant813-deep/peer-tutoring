import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';

void main() {
  runApp(const PeerLinkApp());
}

class PeerLinkApp extends StatelessWidget {
  const PeerLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConnectionPage(),
    );
  }
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  String message = 'Connnecting.....';
  final ApiService api = ApiService();

  void initState() {
    super.initState();
    testBackend();
  }

  Future<void> testBackend() async {
    try {
      final result = await ApiService.testConnection();

      setState(() {
        message = result;
      });
    } catch (e) {
      setState(() {
        message = "Connection error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Connection"),
      ),
      body: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 28,
          ),
        ),
      ),
    );
  }
}

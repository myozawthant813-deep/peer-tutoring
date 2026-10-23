import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/pages/auth/login_page.dart';
import 'package:peer_tutoring/pages/home/home_page.dart';
import 'package:peer_tutoring/models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PeerLinkApp());
}

class PeerLinkApp extends StatelessWidget {
  const PeerLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SessionCheckPage(),
    );
  }
}

class SessionCheckPage extends StatefulWidget {
  const SessionCheckPage({super.key});

  @override
  State<SessionCheckPage> createState() => _SessionCheckPageState();
}

class _SessionCheckPageState extends State<SessionCheckPage> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final user = await AuthSession.getUser();

    if (!mounted) return;

    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentUser != null && currentUser!.id != null) {
      return HomePage(user: currentUser!);
    }

    return const LoginPage();
  }
}

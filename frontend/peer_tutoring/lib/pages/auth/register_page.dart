import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';

import '../../models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    final user = User(
      name: nameController.text,
      email: emailcontroller.text,
      password: passwordController.text,
      university: universityController.text,
      major: majorController.text,
      year: int.parse(yearController.text),
      bio: bioController.text,
      profileImage: '',
      role: 'STUDENT',
      peerScore: 0,
    );
    setState(() {
      isLoading = true;
    });

    try {
      final createdUser = await ApiService.createUser(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created for ${createdUser.name}")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailcontroller.dispose();
    passwordController.dispose();
    universityController.dispose();
    majorController.dispose();
    yearController.dispose();
    bioController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("REGISTRSTION"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: "name", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: emailcontroller,
              decoration: const InputDecoration(
                  labelText: "email", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "password", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: universityController,
              decoration: const InputDecoration(
                  labelText: "university", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(
                  labelText: "major", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "year", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                  labelText: "bio", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("REGISTER"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

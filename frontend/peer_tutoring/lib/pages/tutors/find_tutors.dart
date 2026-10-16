import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/profile/student_profile_page.dart';

class FindTutorsPage extends StatefulWidget {
  final int requesterId;
  const FindTutorsPage({super.key, required this.requesterId});

  @override
  State<FindTutorsPage> createState() => _FindTutorsPageState();
}

class _FindTutorsPageState extends State<FindTutorsPage> {
  List<User> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final result = await ApiService.getUsers();
      if (!mounted) return;
      setState(() {
        isLoading = false;
        users = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find TUTOR"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  loadUser();
                },
                child: const Text('Retry')),
          ],
        ),
      );
    }
    if (users.isEmpty) {
      return const Center(
        child: Text('No students Found'),
      );
    }

    return ListView.builder(
        padding: EdgeInsets.only(bottom: 20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('${user.major} - Year ${user.year} \n ${user.bio}'),
              ),
              isThreeLine: true,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentProfilePage(
                            user: user, requesterId: widget.requesterId)));
              },
            ),
          );
        });
  }
}

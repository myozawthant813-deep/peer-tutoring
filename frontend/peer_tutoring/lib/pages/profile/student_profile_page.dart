import 'package:flutter/material.dart';
import 'package:peer_tutoring/models/user.dart';

class StudentProfilePage extends StatelessWidget {
  final User user;
  const StudentProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("STUdent PRofile"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 55,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              user.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              user.major,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 18,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('University'),
                    subtitle: Text(user.university),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text('Academc Year'),
                    subtitle: Text('Year ${user.year}'),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Peer Score'),
                    subtitle: Text('${user.peerScore}'),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Me',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    user.bio.isNotEmpty
                        ? user.bio
                        : 'THis student has not added a bio yet',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Study Request feature coming soon!')));
                },
                icon: const Icon(Icons.school),
                label: const Text("Request Tutoring"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

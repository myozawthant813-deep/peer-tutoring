import 'package:flutter/material.dart';

import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/cards/feature_card.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/auth/login_page.dart';
import 'package:peer_tutoring/pages/study_group_page.dart';
import 'package:peer_tutoring/pages/tutors/find_tutors.dart';
import 'package:peer_tutoring/pages/tutors/incoming_request_page.dart';
import 'package:peer_tutoring/pages/tutors/my_tutoring_request_page.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({
    super.key,
    required this.user,
  });

  Future<void> logout(BuildContext context) async {
    await AuthSession.clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PeerLink'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Let\'s learn together. Grow together.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 25),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user.name),
                subtitle: Text('${user.major} & Year ${user.year}'),
                trailing: const Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Explore PeerLink',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  FeatureCard(
                    icon: Icons.people,
                    title: 'Find Tutor',
                    onTap: () {
                      if (user.id == null) {
                        _showMessage(
                          context,
                          'User ID missing. Please log in again.',
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindTutorsPage(
                            requesterId: user.id!,
                          ),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.assignment_outlined,
                    title: 'My Requests',
                    onTap: () {
                      if (user.id == null) {
                        _showMessage(
                          context,
                          'User ID missing. Please log in again.',
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyTutoringRequestsPage(
                            requesterId: user.id!,
                          ),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.inbox_outlined,
                    title: 'Incoming Requests',
                    onTap: () {
                      if (user.id == null) {
                        _showMessage(
                          context,
                          'User ID missing. Please log in again.',
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncomingRequestsPage(
                            tutorId: user.id!,
                          ),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.groups,
                    title: 'Study Group',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyGroupsPage(),
                        ),
                      );
                    },
                  ),
                  const FeatureCard(
                    icon: Icons.menu_book,
                    title: 'Study Material',
                  ),
                  const FeatureCard(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

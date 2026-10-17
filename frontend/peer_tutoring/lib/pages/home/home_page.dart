import 'package:flutter/material.dart';
import 'package:peer_tutoring/cards/feature_card.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/tutors/find_tutors.dart';
import 'package:peer_tutoring/pages/tutors/incoming_request_page.dart';
import 'package:peer_tutoring/pages/tutors/my_tutoring_request_page.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WELocme"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WELcome, ${user.name}",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 7,
              ),
              const Text(
                "Let learn together. Grow together.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 25,
              ),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('${user.name}!'),
                  subtitle: Text("${user.major} & ${user.year}"),
                  trailing: const Icon(Icons.school),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Explore Peerlink',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    FeatureCard(
                      icon: Icons.people,
                      title: 'FIND Tutor',
                      onTap: () {
                        if (user.id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("User Id misssing login again")));
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FindTutorsPage(
                                    requesterId: user.id!,
                                  )),
                        );
                      },
                    ),
                    FeatureCard(
                      icon: Icons.assignment_outlined,
                      title: 'My Requests',
                      onTap: () {
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
                    FeatureCard(icon: Icons.groups, title: 'Study Group'),
                    FeatureCard(icon: Icons.menu_book, title: 'Study Material'),
                    FeatureCard(icon: Icons.person_outline, title: 'My Profile')
                  ],
                ),
              )
            ],
          )),
    );
  }
}

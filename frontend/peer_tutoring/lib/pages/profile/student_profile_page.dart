import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/tutors/request_tutoring_page.dart';

class StudentProfilePage extends StatelessWidget {
  final int requesterId;
  final User user;

  const StudentProfilePage({
    super.key,
    required this.user,
    required this.requesterId,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = user.profileImage?.trim() ?? '';

    final imageUrl = imagePath.isEmpty
        ? ''
        : imagePath.startsWith('http')
            ? imagePath
            : '${ApiService.baseUrl}$imagePath';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Student profile picture
            CircleAvatar(
              radius: 65,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              onBackgroundImageError: imageUrl.isNotEmpty
                  ? (exception, stackTrace) {
                      debugPrint('Student profile image error: $exception');
                    }
                  : null,
              child: imageUrl.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),

            const SizedBox(height: 15),

            Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user.major.isNotEmpty ? user.major : 'Major not provided',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 18),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('University'),
                    subtitle: Text(
                      user.university.isNotEmpty
                          ? user.university
                          : 'Not provided',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text('Academic Year'),
                    subtitle: Text('Year ${user.year}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Peer Score'),
                    subtitle: Text('${user.peerScore}'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Me',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    user.bio.isNotEmpty
                        ? user.bio
                        : 'This student has not added a bio yet.',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: user.id == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestTutoringPage(
                              requesterId: requesterId,
                              tutorId: user.id!,
                              tutorName: user.name,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.school),
                label: const Text('Request Tutoring'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

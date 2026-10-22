import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const ProfileImage({
    super.key,
    required this.imageUrl,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person),
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: ApiService.getImageHeaders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(
            url.startsWith('http') ? url : '${ApiService.baseUrl}$url',
            headers: snapshot.data!,
          ),
          onBackgroundImageError: (exception, stackTrace) {
            debugPrint('Profile image error: $exception');
          },
          child: null,
        );
      },
    );
  }
}

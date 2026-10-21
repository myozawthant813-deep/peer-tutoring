import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/Services/api_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final userId = await AuthSession.getUserId();

      if (userId == null) {
        throw Exception('No logged-in user found.');
      }

      final result = await ApiService.getUserProfile(userId);

      if (!mounted) return;

      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> editProfile() async {
    if (profile == null) return;

    final nameController = TextEditingController(
      text: profile!['name']?.toString() ?? '',
    );
    final universityController = TextEditingController(
      text: profile!['university']?.toString() ?? '',
    );
    final majorController = TextEditingController(
      text: profile!['major']?.toString() ?? '',
    );
    final yearController = TextEditingController(
      text: profile!['year']?.toString() ?? '',
    );
    final bioController = TextEditingController(
      text: profile!['bio']?.toString() ?? '',
    );
    final imageController = TextEditingController(
      text: profile!['profileImage']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField(
                      nameController,
                      'Full Name',
                      requiredField: true,
                    ),
                    _buildField(
                      universityController,
                      'University',
                    ),
                    _buildField(
                      majorController,
                      'Major',
                    ),
                    _buildField(
                      yearController,
                      'Academic Year',
                      keyboardType: TextInputType.number,
                      requiredField: true,
                    ),
                    _buildField(
                      bioController,
                      'Bio',
                      maxLines: 3,
                    ),
                    _buildField(
                      imageController,
                      'Profile Image URL',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !mounted) {
      _disposeControllers([
        nameController,
        universityController,
        majorController,
        yearController,
        bioController,
        imageController,
      ]);
      return;
    }

    final userId = await AuthSession.getUserId();

    if (userId == null) {
      _disposeControllers([
        nameController,
        universityController,
        majorController,
        yearController,
        bioController,
        imageController,
      ]);
      return;
    }

    setState(() => isSaving = true);

    try {
      final updatedProfile = await ApiService.updateUserProfile(
        userId: userId,
        name: nameController.text.trim(),
        university: universityController.text.trim(),
        major: majorController.text.trim(),
        year: int.parse(yearController.text.trim()),
        bio: bioController.text.trim(),
        profileImage: imageController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        profile = updatedProfile;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      _disposeControllers([
        nameController,
        universityController,
        majorController,
        yearController,
        bioController,
        imageController,
      ]);
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }

          if (label == 'Academic Year' && int.tryParse(value ?? '') == null) {
            return 'Enter a valid year';
          }

          return null;
        },
      ),
    );
  }

  void _disposeControllers(
    List<TextEditingController> controllers,
  ) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load your profile.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => isLoading = true);
                  loadProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final imageUrl = profile!['profileImage']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: isSaving ? null : editProfile,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.shade100,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blue,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile!['name']?.toString() ?? 'Student',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                profile!['email']?.toString() ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            _profileCard(
              Icons.school,
              'University',
              profile!['university']?.toString() ?? 'Not provided',
            ),
            _profileCard(
              Icons.menu_book,
              'Major',
              profile!['major']?.toString() ?? 'Not provided',
            ),
            _profileCard(
              Icons.calendar_month,
              'Academic Year',
              profile!['year']?.toString() ?? 'Not provided',
            ),
            _profileCard(
              Icons.person_outline,
              'About Me',
              profile!['bio']?.toString() ?? 'No bio yet',
            ),
            _profileCard(
              Icons.star_outline,
              'Peer Score',
              profile!['peerScore']?.toString() ?? '0',
            ),
            if (isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isSaving ? null : editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

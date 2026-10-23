import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isUploadingImage = false;

  static const Color backgroundColor = Color(0xFFF3F1FA);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF292943);
  static const Color mutedColor = Color(0xFF77758D);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  String get imageUrl {
    final imagePath = profile?['profileImage']?.toString().trim() ?? '';

    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    return '${ApiService.baseUrl}$imagePath';
  }

  String get userName {
    final name = profile?['name']?.toString().trim() ?? '';
    return name.isEmpty ? 'Student' : name;
  }

  String get userInitial {
    final name = userName.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
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

  Future<void> pickAndUploadProfileImage() async {
    try {
      final XFile? selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (selectedImage == null || !mounted) return;

      final userId = await AuthSession.getUserId();

      if (userId == null) {
        throw Exception('No logged-in user found.');
      }

      setState(() => isUploadingImage = true);

      final imagePath = await ApiService.uploadProfileImage(
        userId: userId,
        imageFile: selectedImage,
      );

      if (!mounted) return;

      setState(() {
        profile = {
          ...?profile,
          'profileImage': imagePath,
        };
      });

      await loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  Future<void> editProfile() async {
    if (profile == null || isSaving) return;

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

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SizedBox(
              width: 420,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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

      if (shouldSave != true || !mounted) return;

      final userId = await AuthSession.getUserId();

      if (userId == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logged-in user found.')),
        );
        return;
      }

      setState(() => isSaving = true);

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
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: primaryColor.withValues(alpha: 0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
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

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 135),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.trim().isEmpty ? 'Not provided' : value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.12),
                ),
                child: CircleAvatar(
                  radius: 57,
                  backgroundColor: const Color(0xFFE8E5FF),
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  onBackgroundImageError: imageUrl.isNotEmpty
                      ? (exception, stackTrace) {
                          debugPrint('Profile image error: $exception');
                        }
                      : null,
                  child: imageUrl.isEmpty
                      ? Text(
                          userInitial,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 38,
                          ),
                        )
                      : null,
                ),
              ),
              Material(
                color: primaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isUploadingImage ? null : pickAndUploadProfileImage,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isUploadingImage
                          ? Icons.hourglass_top_rounded
                          : Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textColor,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            profile?['email']?.toString() ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(
                Icons.school_rounded,
                profile?['major']?.toString().trim().isNotEmpty == true
                    ? profile!['major'].toString()
                    : 'Student',
              ),
              _badge(
                Icons.calendar_month_rounded,
                'Year ${profile?['year']?.toString() ?? '-'}',
              ),
            ],
          ),
          if (isUploadingImage) ...[
            const SizedBox(height: 18),
            const LinearProgressIndicator(
              color: primaryColor,
              backgroundColor: Color(0xFFE8E5FF),
            ),
            const SizedBox(height: 6),
            const Text(
              'Uploading profile picture...',
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isUploadingImage ? null : pickAndUploadProfileImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.photo_camera_back_rounded),
              label: Text(
                isUploadingImage ? 'Uploading...' : 'Change Profile Picture',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerScore() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFFFE7B0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8B5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFE6A323),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peer Score',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your community learning score',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            profile?['peerScore']?.toString() ?? '0',
            style: const TextStyle(
              color: Color(0xFFB77A0B),
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMe() {
    final bio = profile?['bio']?.toString().trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              bio.isNotEmpty
                  ? bio
                  : 'You have not added a bio yet. Tell others a little about yourself!',
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: const Text('My Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_off_rounded,
                    color: primaryColor,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Unable to load your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedColor),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => isLoading = true);
                    loadProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: isSaving ? null : editProfile,
            icon: const Icon(Icons.edit_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: loadProfile,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 26),
                _sectionTitle(
                  'Academic Information',
                  subtitle: 'Your university and study details',
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.account_balance_rounded,
                        title: 'University',
                        value: profile!['university']?.toString() ?? '',
                        iconColor: primaryColor,
                        iconBackground: const Color(0xFFECE9FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Major',
                        value: profile!['major']?.toString() ?? '',
                        iconColor: const Color(0xFF219EBC),
                        iconBackground: const Color(0xFFDFF5FA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Academic Year',
                  value: profile!['year']?.toString() ?? '',
                  iconColor: const Color(0xFF2D9D78),
                  iconBackground: const Color(0xFFDFF7ED),
                ),
                const SizedBox(height: 26),
                _sectionTitle('About Me'),
                const SizedBox(height: 14),
                _buildAboutMe(),
                const SizedBox(height: 26),
                _buildPeerScore(),
                if (isSaving) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    color: primaryColor,
                    backgroundColor: Color(0xFFE8E5FF),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saving your changes...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : editProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          primaryColor.withValues(alpha: 0.3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

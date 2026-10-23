import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/profile/student_profile_page.dart';

const Color clayBackground = Color(0xFFF3F1FA);
const Color clayPrimary = Color(0xFF6C63FF);
const Color clayText = Color(0xFF292943);
const Color clayMuted = Color(0xFF85859B);

class FindTutorsPage extends StatefulWidget {
  final int requesterId;

  const FindTutorsPage({
    super.key,
    required this.requesterId,
  });

  @override
  State<FindTutorsPage> createState() => _FindTutorsPageState();
}

class _FindTutorsPageState extends State<FindTutorsPage> {
  List<User> users = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getUsers();

      if (!mounted) return;

      setState(() {
        users = result.where((user) => user.id != widget.requesterId).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load students. Please try again.';
      });

      debugPrint('Failed to load tutors: $e');
    }
  }

  List<User> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.major.toLowerCase().contains(query) ||
          user.university.toLowerCase().contains(query) ||
          user.bio.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBackground,
      appBar: AppBar(
        backgroundColor: clayBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: clayText),
        title: const Text(
          'Find Tutors',
          style: TextStyle(
            color: clayText,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                    Expanded(
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8179FF),
              Color(0xFF6558E8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: clayPrimary.withValues(alpha: 0.22),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LEARN TOGETHER',
                    style: TextStyle(
                      color: Color(0xFFE4E1FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Find your study partner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${users.length} students available to explore',
                    style: const TextStyle(
                      color: Color(0xFFF0EEFF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: clayBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Color(0xFFDCD9E8),
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          style: const TextStyle(
            color: clayText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search name, major or university...',
            hintStyle: const TextStyle(
              color: clayMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: clayPrimary,
              size: 24,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: clayMuted,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: clayPrimary,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: errorMessage!,
        buttonText: 'Try again',
        onPressed: loadUser,
      );
    }

    final results = filteredUsers;

    if (results.isEmpty) {
      return _buildMessage(
        icon: searchQuery.isEmpty
            ? Icons.people_outline_rounded
            : Icons.search_off_rounded,
        title:
            searchQuery.isEmpty ? 'No students found' : 'No matching students',
        message: searchQuery.isEmpty
            ? 'There are no other students to display yet.'
            : 'Try another name, major or university.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 2 : 1;

        if (columns == 1) {
          return RefreshIndicator(
            color: clayPrimary,
            onRefresh: loadUser,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildTutorCard(results[index]);
              },
            ),
          );
        }

        return RefreshIndicator(
          color: clayPrimary,
          onRefresh: loadUser,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 220,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildTutorCard(results[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildTutorCard(User user) {
    final imagePath = user.profileImage?.trim() ?? '';

    final imageUrl = imagePath.isEmpty
        ? ''
        : imagePath.startsWith('http')
            ? imagePath
            : '${ApiService.baseUrl}$imagePath';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: clayBackground,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFFDCD9E8),
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () => _openProfile(user),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: clayBackground,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3, -3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color(0xFFDCD9E8),
                      offset: Offset(3, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 31,
                  backgroundColor: const Color(0xFFE3E0FF),
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  onBackgroundImageError: imageUrl.isNotEmpty
                      ? (exception, stackTrace) {
                          debugPrint('Tutor image error: $exception');
                        }
                      : null,
                  child: imageUrl.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: clayPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: clayText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      Icons.school_rounded,
                      user.major,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoChip(
                      Icons.menu_book_rounded,
                      'Year ${user.year}',
                    ),
                    if (user.university.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildInfoChip(
                        Icons.account_balance_rounded,
                        user.university,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      user.bio.trim().isEmpty
                          ? 'Ready to learn together.'
                          : user.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: clayMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: clayPrimary,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: clayPrimary.withValues(alpha: 0.20),
                              offset: const Offset(2, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: clayPrimary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.isEmpty ? 'Not specified' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: clayMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: clayBackground,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Color(0xFFDCD9E8),
                    offset: Offset(5, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 40,
                color: clayPrimary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: clayText,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: clayMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: clayPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentProfilePage(
          user: user,
          requesterId: widget.requesterId,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/auth/login_page.dart';
import 'package:peer_tutoring/pages/my_profile_page.dart';
import 'package:peer_tutoring/pages/study_group_page.dart';
import 'package:peer_tutoring/pages/study_materials_page.dart';
import 'package:peer_tutoring/pages/tutors/find_tutors.dart';
import 'package:peer_tutoring/pages/tutors/incoming_request_page.dart';
import 'package:peer_tutoring/pages/tutors/my_tutoring_request_page.dart';
import 'package:peer_tutoring/pages/tutors/tutoring_sessions_page.dart';

const Color clayBackground = Color(0xFFF3F1FA);
const Color clayPrimary = Color(0xFF6C63FF);
const Color clayText = Color(0xFF292943);
const Color clayMuted = Color(0xFF85859B);

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
      backgroundColor: clayBackground,
      appBar: AppBar(
        backgroundColor: clayBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: clayPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: clayPrimary.withValues(alpha: 0.25),
                    offset: const Offset(3, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'PeerLink',
              style: TextStyle(
                color: clayText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: clayBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 7,
                ),
                BoxShadow(
                  color: Color(0xFFD9D6E5),
                  offset: Offset(4, 4),
                  blurRadius: 7,
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: () => logout(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: clayPrimary,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 20,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(context),
                    const SizedBox(height: 28),
                    _buildProfileCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Your learning space',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: clayText,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything you need to learn and grow together.',
                      style: TextStyle(
                        fontSize: 14,
                        color: clayMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, gridConstraints) {
                        final width = gridConstraints.maxWidth;

                        final columns = width >= 1000
                            ? 4
                            : width >= 650
                                ? 3
                                : width >= 400
                                    ? 2
                                    : 1;

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: columns == 1
                              ? 2.5
                              : columns == 2
                                  ? 1.15
                                  : 1.05,
                          children: [
                            _buildFeatureCard(
                              context,
                              icon: Icons.search_rounded,
                              title: 'Find Tutors',
                              subtitle: 'Learn from your peers',
                              color: const Color(0xFFE3E0FF),
                              iconColor: const Color(0xFF6C63FF),
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
                                    builder: (_) => FindTutorsPage(
                                      requesterId: user.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.event_available_rounded,
                              title: 'My Sessions',
                              subtitle: 'View your tutoring sessions',
                              color: const Color(0xFFDDF5E8),
                              iconColor: const Color(0xFF239B70),
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
                                    builder: (_) => TutoringSessionsPage(
                                      userId: user.id!,
                                      isTutor: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.assignment_rounded,
                              title: 'My Requests',
                              subtitle: 'Track your tutoring requests',
                              color: const Color(0xFFFFE9D7),
                              iconColor: const Color(0xFFE78B45),
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
                                    builder: (_) => MyTutoringRequestsPage(
                                      requesterId: user.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.inbox_rounded,
                              title: 'Incoming Requests',
                              subtitle: 'Manage tutoring requests',
                              color: const Color(0xFFFFDFE8),
                              iconColor: const Color(0xFFD95782),
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
                                    builder: (_) => IncomingRequestsPage(
                                      tutorId: user.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.groups_rounded,
                              title: 'Study Groups',
                              subtitle: 'Study better together',
                              color: const Color(0xFFDCEBFF),
                              iconColor: const Color(0xFF4285D4),
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
                                    builder: (_) => StudyGroupsPage(
                                      userId: user.id!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.menu_book_rounded,
                              title: 'Study Materials',
                              subtitle: 'Explore learning resources',
                              color: const Color(0xFFF4E2FF),
                              iconColor: const Color(0xFF9B59B6),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StudyMaterialsPage(),
                                  ),
                                );
                              },
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.person_rounded,
                              title: 'My Profile',
                              subtitle: 'Manage your information',
                              color: const Color(0xFFFFF0C9),
                              iconColor: const Color(0xFFB88922),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Made for learners, powered by community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: clayMuted.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8179FF),
            Color(0xFF6558E8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: clayPrimary.withValues(alpha: 0.22),
            offset: const Offset(0, 9),
            blurRadius: 20,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
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
                  'YOUR LEARNING JOURNEY',
                  style: TextStyle(
                    color: Color(0xFFE4E1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  'Welcome back, ${user.name}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Let\'s learn together.\nGrow together.',
                  style: TextStyle(
                    color: Color(0xFFF0EEFF),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: clayBackground,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFDCD9E8),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E0FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Color(0xFFD3CFF1),
                  offset: Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: clayPrimary,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: clayText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${user.major} • Year ${user.year}',
                  style: const TextStyle(
                    color: clayMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF6C63FF),
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: clayBackground,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                offset: Offset(-6, -6),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Color(0xFFDCD9E8),
                offset: Offset(6, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.10),
                        offset: const Offset(3, 4),
                        blurRadius: 8,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: clayText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: clayMuted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: iconColor,
                      size: 17,
                    ),
                  ],
                ),
              ],
            ),
          ),
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

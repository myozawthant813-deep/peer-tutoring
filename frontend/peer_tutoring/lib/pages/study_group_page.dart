import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/auth_session.dart';
import 'package:peer_tutoring/models/user.dart';
import 'package:peer_tutoring/pages/create_study_group_page.dart';
import 'package:peer_tutoring/pages/study_group_deatils_page.dart';
import '../Services/api_service.dart';

class StudyGroupsPage extends StatefulWidget {
  final int userId;

  const StudyGroupsPage({
    super.key,
    required this.userId,
  });

  @override
  State<StudyGroupsPage> createState() => _StudyGroupsPageState();
}

class _StudyGroupsPageState extends State<StudyGroupsPage> {
  static const Color backgroundColor = Color(0xFFF3F1FA);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF292943);
  static const Color mutedColor = Color(0xFF85859B);
  static const Color cardColor = Colors.white;
  static const Color softPurple = Color(0xFFEAE7FF);
  static const Color softGreen = Color(0xFFE0F5E9);

  List<dynamic> groups = [];
  bool isLoading = true;
  bool isLoadingUser = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();

  User? currentUser;

  @override
  void initState() {
    super.initState();
    loadGroups();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final user = await AuthSession.getUser();

    if (!mounted) return;

    setState(() {
      currentUser = user;
      isLoadingUser = false;
    });

    if (user == null) {
      _showMessage('Please log in to access study groups.');
    }
  }

  Future<void> loadGroups({String subject = ''}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = subject.trim().isEmpty
          ? await ApiService.getStudyGroups()
          : await ApiService.searchStudyGroups(subject.trim());

      if (!mounted) return;

      setState(() {
        groups = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> createGroup() async {
    final user = currentUser;

    if (isLoadingUser) return;

    if (user == null || user.id == null) {
      _showMessage('Please log in again.');
      return;
    }

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateStudyGroupPage(
          userId: user.id!,
        ),
      ),
    );

    if (created == true && mounted) {
      await loadGroups(subject: searchController.text);
    }
  }

  Future<void> openGroup(Map<String, dynamic> group) async {
    final user = currentUser;

    if (user == null || user.id == null) {
      _showMessage('Please log in again.');
      return;
    }

    final groupId = int.tryParse(group['id']?.toString() ?? '');

    if (groupId == null) {
      _showMessage('Invalid study group.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyGroupDetailsPage(
          groupId: groupId,
          userId: user.id!,
        ),
      ),
    );

    if (mounted) {
      await loadGroups(subject: searchController.text);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  String _initial(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? '?' : text[0].toUpperCase();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Study Groups',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading
                ? null
                : () => loadGroups(subject: searchController.text),
            icon: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoadingUser ? null : createGroup,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Group',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeroBanner(),
            _buildSearchBar(),
            Expanded(child: _buildGroupList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                    'Learn together ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Find your study partners, share knowledge, and reach your goals together.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${groups.length} ${groups.length == 1 ? 'group' : 'groups'} available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 37,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => loadGroups(subject: value),
        decoration: InputDecoration(
          hintText: 'Search by subject...',
          hintStyle: const TextStyle(color: mutedColor),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryColor,
          ),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: mutedColor,
                  ),
                  onPressed: () {
                    searchController.clear();
                    loadGroups();
                  },
                ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide(
              color: primaryColor.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load groups',
            subtitle: errorMessage!,
            buttonText: 'Try Again',
            onPressed: () => loadGroups(
              subject: searchController.text,
            ),
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState(
            icon: Icons.groups_rounded,
            title: 'No study groups found',
            subtitle: searchController.text.trim().isEmpty
                ? 'Create the first group and start learning together.'
                : 'Try another subject or clear your search.',
            buttonText: searchController.text.trim().isEmpty
                ? 'Create Group'
                : 'Clear Search',
            onPressed: searchController.text.trim().isEmpty
                ? createGroup
                : () {
                    searchController.clear();
                    loadGroups();
                  },
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => loadGroups(
        subject: searchController.text,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 650
                  ? 2
                  : 1;

          if (columns == 1) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = Map<String, dynamic>.from(
                  groups[index] as Map,
                );

                return _buildGroupCard(group);
              },
            );
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 250,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = Map<String, dynamic>.from(
                groups[index] as Map,
              );

              return _buildGroupCard(group);
            },
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final name = (group['name'] ?? 'Untitled Group').toString();
    final subject = (group['subject'] ?? 'General').toString();
    final description = (group['description'] ?? '').toString().trim();
    final memberCount = group['memberCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => openGroup(group),
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      color: softPurple,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Center(
                      child: Text(
                        _initial(subject),
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: softPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: mutedColor,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Expanded(
                child: Text(
                  description.isEmpty
                      ? 'No description provided yet.'
                      : description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 17,
                          color: Color(0xFF258653),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$memberCount members',
                          style: const TextStyle(
                            color: Color(0xFF258653),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View group',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

String _initial(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '?';
  }

  return value.trim()[0].toUpperCase();
}

import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class StudyGroupDetailsPage extends StatefulWidget {
  final int groupId;
  final int userId;

  const StudyGroupDetailsPage({
    super.key,
    required this.groupId,
    required this.userId,
  });

  @override
  State<StudyGroupDetailsPage> createState() => _StudyGroupDetailsPageState();
}

class _StudyGroupDetailsPageState extends State<StudyGroupDetailsPage> {
  static const Color backgroundColor = Color(0xFFF3F1FA);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF292943);
  static const Color mutedColor = Color(0xFF77758B);
  static const Color borderColor = Color(0xFFE8E5F2);

  Map<String, dynamic>? group;
  List<dynamic> members = [];

  bool isLoading = true;
  bool isLoadingMembers = true;
  bool isProcessingMembership = false;
  String? errorMessage;

  bool get isMember {
    return members.any((member) {
      final data = Map<String, dynamic>.from(member as Map);
      return int.tryParse('${data['id']}') == widget.userId;
    });
  }

  @override
  void initState() {
    super.initState();
    loadGroupDetails();
  }

  Future<void> loadGroupDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isLoadingMembers = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getStudyGroupDetails(widget.groupId),
        ApiService.getStudyGroupMembers(widget.groupId),
      ]);

      if (!mounted) return;

      setState(() {
        group = Map<String, dynamic>.from(results[0] as Map);
        members = results[1] as List<dynamic>;
        isLoading = false;
        isLoadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        isLoadingMembers = false;
      });
    }
  }

  Future<void> changeMembership() async {
    if (isProcessingMembership) return;

    final wasMember = isMember;

    setState(() {
      isProcessingMembership = true;
    });

    try {
      if (wasMember) {
        await ApiService.leaveStudyGroup(
          groupId: widget.groupId,
          userId: widget.userId,
        );
      } else {
        await ApiService.joinStudyGroup(
          groupId: widget.groupId,
          userId: widget.userId,
        );
      }

      await loadGroupDetails();

      if (!mounted) return;

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Membership updated, but refreshing the group failed.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasMember
                  ? 'You left the study group.'
                  : 'You joined the study group!',
            ),
            backgroundColor: const Color(0xFF389777),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membership update failed: $e'),
          backgroundColor: const Color(0xFFD95369),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessingMembership = false;
        });
      }
    }
  }

  String _initial(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) return '?';

    return text.substring(0, 1).toUpperCase();
  }

  String _groupName(Map<String, dynamic> data) {
    return (data['name'] ?? 'Study Group').toString();
  }

  String _subject(Map<String, dynamic> data) {
    final subject = (data['subject'] ?? '').toString().trim();

    return subject.isEmpty ? 'General Study' : subject;
  }

  String _description(Map<String, dynamic> data) {
    final description = (data['description'] ?? '').toString().trim();

    return description.isEmpty ? 'No description provided yet.' : description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Group Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadGroupDetails,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage != null
              ? _buildErrorState()
              : group == null
                  ? _buildErrorState()
                  : _buildDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9EC),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFFD95369),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not load group',
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ?? 'Group information is unavailable.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: loadGroupDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final groupData = group!;
    final memberCount =
        int.tryParse('${groupData['memberCount']}') ?? members.length;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: loadGroupDetails,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(groupData, memberCount),
              const SizedBox(height: 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildAboutCard(groupData),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildMembersCard(),
                    ),
                  ],
                )
              else ...[
                _buildAboutCard(groupData),
                const SizedBox(height: 20),
                _buildMembersCard(),
              ],
              const SizedBox(height: 24),
            ],
          );

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 18,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    Map<String, dynamic> data,
    int memberCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF9188FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                _initial(_subject(data)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _groupName(data),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _subject(data),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heroStat(
                Icons.people_alt_rounded,
                '$memberCount',
                memberCount == 1 ? 'Member' : 'Members',
              ),
              Container(
                width: 1,
                height: 38,
                margin: const EdgeInsets.symmetric(horizontal: 26),
                color: Colors.white.withValues(alpha: 0.35),
              ),
              _heroStat(
                Icons.person_rounded,
                '${data['creatorName'] ?? 'Unknown'}',
                'Group creator',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isProcessingMembership ? null : changeMembership,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    isMember ? const Color(0xFFD95369) : primaryColor,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isProcessingMembership
                  ? const SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: primaryColor,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isMember
                              ? Icons.logout_rounded
                              : Icons.group_add_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          isMember ? 'Leave Group' : 'Join Group',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (isMember) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'You are a member of this group',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Flexible(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(Map<String, dynamic> data) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            Icons.info_outline_rounded,
            'About this group',
          ),
          const SizedBox(height: 18),
          Text(
            _description(data),
            style: const TextStyle(
              color: mutedColor,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: borderColor, height: 1),
          const SizedBox(height: 18),
          _detailRow(
            Icons.person_outline_rounded,
            'Created by',
            '${data['creatorName'] ?? 'Unknown'}',
          ),
          const SizedBox(height: 18),
          _detailRow(
            Icons.menu_book_outlined,
            'Subject',
            _subject(data),
          ),
          const SizedBox(height: 18),
          _detailRow(
            Icons.people_outline_rounded,
            'Total members',
            '${data['memberCount'] ?? members.length}',
          ),
        ],
      ),
    );
  }

  Widget _buildMembersCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeading(
                  Icons.groups_rounded,
                  'Group Members',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE9FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${members.length}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isLoadingMembers)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            )
          else if (members.isEmpty)
            _emptyMembers()
          else
            ...members.map((item) {
              final member = Map<String, dynamic>.from(item as Map);
              final name = (member['name'] ?? 'Unknown').toString();
              final email = (member['email'] ?? '').toString();
              final memberId = int.tryParse('${member['id']}');
              final isCurrentUser = memberId == widget.userId;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? primaryColor.withValues(alpha: 0.13)
                            : const Color(0xFFE5F4EF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          _initial(name),
                          style: TextStyle(
                            color: isCurrentUser
                                ? primaryColor
                                : const Color(0xFF389777),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: mutedColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE9FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _emptyMembers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.group_outlined,
            color: mutedColor,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No members found yet',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Join the group to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeading(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFECE9FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

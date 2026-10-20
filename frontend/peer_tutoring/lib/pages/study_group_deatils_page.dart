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
  Map<String, dynamic>? group;
  List<dynamic> members = [];

  bool isLoading = true;
  bool isLoadingMembers = true;
  bool isProcessingMembership = false;
  String? errorMessage;

  bool get isMember {
    return members.any(
      (member) => int.tryParse(member['id'].toString()) == widget.userId,
    );
  }

  @override
  void initState() {
    super.initState();
    loadGroupDetails();
  }

  Future<void> loadGroupDetails() async {
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
        group = Map<String, dynamic>.from(
          results[0] as Map,
        );
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
    setState(() {
      isProcessingMembership = true;
    });

    try {
      if (isMember) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMember
                ? 'You joined the study group!'
                : 'You left the study group.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membership update failed: $e'),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        actions: [
          IconButton(
            onPressed: loadGroupDetails,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: loadGroupDetails,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final groupData = group!;

    return RefreshIndicator(
      onRefresh: loadGroupDetails,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              child: Text(
                _initial(groupData['subject']),
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (groupData['name'] ?? 'Study Group').toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subject: ${groupData['subject'] ?? 'N/A'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (groupData['description'] ?? '').toString().isEmpty
                        ? 'No description provided.'
                        : groupData['description'].toString(),
                  ),
                  const Divider(height: 28),
                  _infoRow(
                    Icons.person_outline,
                    'Created by',
                    (groupData['creatorName'] ?? 'Unknown').toString(),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    Icons.people_outline,
                    'Members',
                    '${groupData['memberCount'] ?? members.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isProcessingMembership ? null : changeMembership,
              icon: isProcessingMembership
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isMember ? Icons.exit_to_app : Icons.group_add,
                    ),
              label: Text(
                isProcessingMembership
                    ? 'Please wait...'
                    : isMember
                        ? 'Leave Group'
                        : 'Join Group',
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Group Members',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoadingMembers)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No members found.'),
            )
          else
            ...members.map((item) {
              final member = Map<String, dynamic>.from(item as Map);

              final memberName = (member['name'] ?? 'Unknown').toString();

              final memberId = int.tryParse(member['id'].toString());

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(_initial(memberName)),
                  ),
                  title: Text(memberName),
                  subtitle: Text(
                    (member['email'] ?? '').toString(),
                  ),
                  trailing: memberId == widget.userId
                      ? const Chip(label: Text('You'))
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text('$label: '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _initial(dynamic value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? '?' : text[0].toUpperCase();
  }
}

import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';

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
  late Future<List<dynamic>> groupsFuture;

  final Set<int> processing = {};
  final Map<int, Future<bool>> membershipChecks = {};

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    groupsFuture = ApiService.getStudyGroups();
    membershipChecks.clear();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadGroups();
    });

    await groupsFuture;
  }

  // Check whether the current student belongs to this group.
  Future<bool> _isMember(int groupId) {
    return membershipChecks.putIfAbsent(
      groupId,
      () async {
        try {
          final members = await ApiService.getStudyGroupMembers(groupId);

          return members.any((member) {
            final memberId = member['userId'] ??
                member['user']?['id'] ??
                member['studentId'] ??
                member['id'];

            return memberId != null &&
                memberId.toString() == widget.userId.toString();
          });
        } catch (e) {
          debugPrint(
            'Failed to check membership for group $groupId: $e',
          );

          rethrow;
        }
      },
    );
  }

  Future<void> _joinGroup(int groupId) async {
    if (processing.contains(groupId)) return;

    setState(() {
      processing.add(groupId);
    });

    try {
      await ApiService.joinStudyGroup(
        groupId: groupId,
        userId: widget.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined study group!'),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not join group: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processing.remove(groupId);
        });
      }
    }
  }

  Future<void> _leaveGroup(int groupId) async {
    if (processing.contains(groupId)) return;

    setState(() {
      processing.add(groupId);
    });

    try {
      await ApiService.leaveStudyGroup(
        groupId: groupId,
        userId: widget.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Left study group.'),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not leave group: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processing.remove(groupId);
        });
      }
    }
  }

  Future<void> _showMembers(
    int groupId,
    String groupName,
  ) async {
    try {
      final members = await ApiService.getStudyGroupMembers(groupId);

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return SizedBox(
            height: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$groupName — Members',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: members.isEmpty
                      ? const Center(
                          child: Text('No members yet.'),
                        )
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];

                            final user =
                                member['user'] is Map ? member['user'] : null;

                            final name = member['name'] ??
                                member['userName'] ??
                                user?['name'] ??
                                'Student';

                            final email =
                                member['email'] ?? user?['email'] ?? '';

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(name.toString()),
                              subtitle: Text(email.toString()),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load members: $e'),
        ),
      );
    }
  }

  Widget _buildMembershipButton(
    int groupId,
    bool busy,
  ) {
    return FutureBuilder<bool>(
      future: _isMember(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        // Don't incorrectly show Join if membership couldn't
        // be checked because of an API error.
        if (snapshot.hasError) {
          return TextButton(
            onPressed: () {
              setState(() {
                membershipChecks.remove(groupId);
              });
            },
            child: const Text('Retry'),
          );
        }

        final isMember = snapshot.data ?? false;

        return ElevatedButton(
          onPressed: busy
              ? null
              : () {
                  if (isMember) {
                    _leaveGroup(groupId);
                  } else {
                    _joinGroup(groupId);
                  }
                },
          child: Text(
            busy
                ? 'Please wait...'
                : isMember
                    ? 'Leave Group'
                    : 'Join Group',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Center(
                    child: Text(
                      'Could not load study groups.',
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              );
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      'No study groups available yet.',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];

                final groupId = (group['id'] as num).toInt();

                final name = group['name']?.toString() ?? 'Study Group';

                final subject = group['subject']?.toString() ?? '';

                final description = group['description']?.toString() ?? '';

                final count = group['memberCount'] ?? 0;

                final busy = processing.contains(groupId);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (subject.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Subject: $subject'),
                        ],
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(description),
                        ],
                        const SizedBox(height: 8),
                        Text('Members: $count'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showMembers(
                                groupId,
                                name,
                              ),
                              icon: const Icon(
                                Icons.people,
                              ),
                              label: const Text(
                                'View Members',
                              ),
                            ),
                            _buildMembershipButton(
                              groupId,
                              busy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

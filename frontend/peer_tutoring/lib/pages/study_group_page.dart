import 'package:flutter/material.dart';
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
  List<dynamic> groups = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGroups();
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => loadGroups(
              subject: searchController.text,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by subject...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    loadGroups();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) => loadGroups(subject: value),
            ),
          ),
          Expanded(
            child: buildGroupList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create Group page is coming next!'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),
    );
  }

  Widget buildGroupList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
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
                onPressed: () => loadGroups(
                  subject: searchController.text,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (groups.isEmpty) {
      return const Center(
        child: Text(
          'No study groups found.\nCreate one to get started!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => loadGroups(
        subject: searchController.text,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = Map<String, dynamic>.from(
            groups[index] as Map,
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                child: Text(
                  (group['subject'] ?? '?')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),
              title: Text(
                (group['name'] ?? 'Untitled Group').toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${group['subject'] ?? 'N/A'}'),
                    const SizedBox(height: 4),
                    Text(
                      (group['description'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text('${group['memberCount'] ?? 0} members'),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selected group ID: ${group['id']}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

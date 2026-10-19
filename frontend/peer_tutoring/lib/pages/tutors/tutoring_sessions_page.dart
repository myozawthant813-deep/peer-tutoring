import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TutoringSessionsPage extends StatefulWidget {
  final int userId;
  final bool isTutor;

  const TutoringSessionsPage({
    super.key,
    required this.userId,
    required this.isTutor,
  });

  @override
  State<TutoringSessionsPage> createState() => _TutoringSessionsPageState();
}

class _TutoringSessionsPageState extends State<TutoringSessionsPage> {
  late Future<List<dynamic>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = widget.isTutor
        ? ApiService.getTutorSessions(widget.userId)
        : ApiService.getStudentSessions(widget.userId);
  }

  Future<void> _refreshSessions() async {
    setState(() {
      _loadSessions();
    });

    await _sessionsFuture;
  }

  String _formatDateTime(String value) {
    final dateTime = DateTime.parse(value);

    final date = '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$date • $hour:$minute $period';
  }

  Future<void> _openMeetingLink(String link) async {
    final uri = Uri.tryParse(link);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid meeting link is available.'),
        ),
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the meeting link.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the meeting link.'),
        ),
      );
    }
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final otherPersonName = widget.isTutor
        ? session['studentName']?.toString() ?? 'Student'
        : session['tutorName']?.toString() ?? 'Tutor';

    final subject = session['subject']?.toString() ?? 'Tutoring';

    final meetingLink = session['meetingLink']?.toString() ?? '';

    final scheduledAt = session['scheduledAt']?.toString() ?? '';

    final status = session['status']?.toString() ?? 'SCHEDULED';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.school),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.isTutor ? 'Student' : 'Tutor'}: '
                        '$otherPersonName',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scheduledAt.isEmpty
                        ? 'Date not available'
                        : _formatDateTime(scheduledAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text('Status: $status'),
              ],
            ),
            if (meetingLink.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMeetingLink(meetingLink),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Meeting'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Text(
                'No meeting link provided.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoring Sessions'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load tutoring sessions.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshSessions,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshSessions,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No tutoring sessions scheduled yet.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSessions,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = Map<String, dynamic>.from(
                  sessions[index] as Map,
                );

                return _buildSessionCard(session);
              },
            ),
          );
        },
      ),
    );
  }
}

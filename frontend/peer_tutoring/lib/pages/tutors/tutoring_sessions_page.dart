import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

const Color clayBackground = Color(0xFFF3F1FA);
const Color clayPrimary = Color(0xFF6C63FF);
const Color clayText = Color(0xFF292943);
const Color clayMuted = Color(0xFF85859B);
const Color clayCard = Color(0xFFF8F7FC);

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

  String searchQuery = '';
  String selectedFilter = 'All';

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
    final future = widget.isTutor
        ? ApiService.getTutorSessions(widget.userId)
        : ApiService.getStudentSessions(widget.userId);

    setState(() {
      _sessionsFuture = future;
    });

    await future;
  }

  String _formatDateTime(String value) {
    try {
      final dateTime = DateTime.parse(value).toLocal();

      final date = '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';

      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$date • $hour:$minute $period';
    } catch (_) {
      return value;
    }
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

  List<Map<String, dynamic>> _filterSessions(
    List<Map<String, dynamic>> sessions,
  ) {
    return sessions.where((session) {
      final subject = session['subject']?.toString() ?? '';
      final personName = widget.isTutor
          ? session['studentName']?.toString() ?? 'Student'
          : session['tutorName']?.toString() ?? 'Tutor';
      final status = session['status']?.toString() ?? 'SCHEDULED';

      final query = searchQuery.toLowerCase();

      final matchesSearch = subject.toLowerCase().contains(query) ||
          personName.toLowerCase().contains(query);

      final matchesStatus = selectedFilter == 'All' ||
          status.toLowerCase() == selectedFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBackground,
      appBar: AppBar(
        backgroundColor: clayBackground,
        foregroundColor: clayText,
        elevation: 0,
        title: Text(
          widget.isTutor ? 'My Teaching Sessions' : 'My Tutoring Sessions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: clayPrimary),
              );
            }

            if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: _refreshSessions,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 130),
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: clayMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load tutoring sessions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: clayText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _refreshSessions,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                      ),
                    ),
                  ],
                ),
              );
            }

            final rawSessions = snapshot.data ?? [];

            final allSessions = rawSessions
                .map(
                  (session) => Map<String, dynamic>.from(session as Map),
                )
                .toList();

            final sessions = _filterSessions(allSessions);

            return RefreshIndicator(
              color: clayPrimary,
              onRefresh: _refreshSessions,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _buildHeader(allSessions),
                  const SizedBox(height: 22),
                  _buildSearchField(),
                  const SizedBox(height: 18),
                  _buildFilters(),
                  const SizedBox(height: 22),
                  if (allSessions.isEmpty)
                    _buildEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'No sessions scheduled',
                      message:
                          'Your scheduled tutoring sessions will appear here.',
                    )
                  else if (sessions.isEmpty)
                    _buildEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching sessions',
                      message: 'Try another search term or status filter.',
                    )
                  else
                    ...sessions.map(_buildSessionCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<Map<String, dynamic>> sessions) {
    final scheduledCount = sessions.where((session) {
      final status = (session['status']?.toString() ?? '').toUpperCase();
      return status == 'SCHEDULED';
    }).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8178FF), Color(0xFF6559E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: clayPrimary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isTutor ? 'Your Teaching Space' : 'Your Learning Space',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stay organized and never miss\na tutoring session.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  Icons.event_note_rounded,
                  '${sessions.length}',
                  'Total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStat(
                  Icons.event_available_rounded,
                  '$scheduledCount',
                  'Scheduled',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 23),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: clayBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim();
          });
        },
        style: const TextStyle(color: clayText),
        decoration: InputDecoration(
          hintText:
              'Search subject or ${widget.isTutor ? 'student' : 'tutor'}...',
          hintStyle: const TextStyle(color: clayMuted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: clayPrimary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
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
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Scheduled', 'Completed', 'Cancelled'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? clayPrimary : clayCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: clayPrimary.withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : clayMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final otherPersonName = widget.isTutor
        ? session['studentName']?.toString() ?? 'Student'
        : session['tutorName']?.toString() ?? 'Tutor';

    final subject = session['subject']?.toString() ?? 'Tutoring';
    final meetingLink = session['meetingLink']?.toString() ?? '';
    final scheduledAt = session['scheduledAt']?.toString() ?? '';
    final status = session['status']?.toString() ?? 'SCHEDULED';

    final normalizedStatus = status.toUpperCase();

    final Color statusColor;
    final Color statusBackground;
    final IconData statusIcon;

    switch (normalizedStatus) {
      case 'COMPLETED':
        statusColor = const Color(0xFF23865A);
        statusBackground = const Color(0xFFE1F5E9);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'CANCELLED':
        statusColor = const Color(0xFFC44545);
        statusBackground = const Color(0xFFFFE8E8);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFB7791F);
        statusBackground = const Color(0xFFFFF2D5);
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: clayCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8B5C9).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(5, 7),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E5FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: clayPrimary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        color: clayText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.isTutor ? 'Student' : 'Tutor'}: $otherPersonName',
                      style: const TextStyle(
                        color: clayMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: clayBackground,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: clayPrimary,
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DATE & TIME',
                            style: TextStyle(
                              color: clayMuted,
                              fontSize: 10,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            scheduledAt.isEmpty
                                ? 'Date not available'
                                : _formatDateTime(scheduledAt),
                            style: const TextStyle(
                              color: clayText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: clayPrimary,
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'SESSION STATUS',
                        style: TextStyle(
                          color: clayMuted,
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 15,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (meetingLink.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: clayPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _openMeetingLink(meetingLink),
                icon: const Icon(Icons.video_call_rounded),
                label: const Text(
                  'Join Meeting',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: clayBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.link_off_rounded,
                    color: clayMuted,
                    size: 19,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No meeting link provided.',
                      style: TextStyle(color: clayMuted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: clayCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 58, color: clayPrimary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: clayText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: clayMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

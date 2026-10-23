import 'package:flutter/material.dart';
import 'package:peer_tutoring/pages/tutors/schedule_tutoring_session_page.dart';
import 'package:peer_tutoring/pages/tutors/tutoring_sessions_page.dart';

import '../../Services/api_service.dart';
import '../../models/incoming_tutoring_request.dart';

const Color clayBackground = Color(0xFFF3F1FA);
const Color clayPrimary = Color(0xFF6C63FF);
const Color clayText = Color(0xFF292943);
const Color clayMuted = Color(0xFF85859B);
const Color clayCard = Color(0xFFF8F7FC);

class IncomingRequestsPage extends StatefulWidget {
  final int tutorId;

  const IncomingRequestsPage({
    super.key,
    required this.tutorId,
  });

  @override
  State<IncomingRequestsPage> createState() => _IncomingRequestsPageState();
}

class _IncomingRequestsPageState extends State<IncomingRequestsPage> {
  late Future<List<IncomingTutoringRequest>> requestsFuture;

  final Set<int> processingRequests = {};
  final Map<int, Future<bool>> sessionCheck = {};

  String searchQuery = '';
  String selectedFilter = 'All';

  Future<bool> checkSession(int requestId) {
    return sessionCheck.putIfAbsent(
      requestId,
      () => ApiService.hasScheduleSession(requestId),
    );
  }

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  void loadRequests() {
    requestsFuture = ApiService.getIncomingRequests(widget.tutorId);
  }

  Future<void> handleRequest(int requestId, String status) async {
    setState(() {
      processingRequests.add(requestId);
    });

    try {
      await ApiService.updateTutoringRequestStatus(
        requestId: requestId,
        tutorId: widget.tutorId,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        sessionCheck.remove(requestId);
        loadRequests();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              status == 'ACCEPTED' ? Colors.green.shade700 : clayText,
          content: Text(
            status == 'ACCEPTED'
                ? 'Tutoring request accepted!'
                : 'Tutoring request rejected.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingRequests.remove(requestId);
        });
      }
    }
  }

  Future<void> refreshRequests() async {
    final future = ApiService.getIncomingRequests(widget.tutorId);

    setState(() {
      requestsFuture = future;
      sessionCheck.clear();
    });

    await future;
  }

  List<IncomingTutoringRequest> filterRequests(
    List<IncomingTutoringRequest> requests,
  ) {
    return requests.where((request) {
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          request.requesterName.toLowerCase().contains(query) ||
              request.subject.toLowerCase().contains(query) ||
              request.message.toLowerCase().contains(query);

      final matchesStatus = selectedFilter == 'All' ||
          request.status.toLowerCase() == selectedFilter.toLowerCase();

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
        title: const Text(
          'Incoming Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<IncomingTutoringRequest>>(
          future: requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: clayPrimary),
              );
            }

            if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: refreshRequests,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 130),
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 60,
                      color: clayMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Could not load incoming requests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: clayText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pull down to try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: clayMuted),
                    ),
                  ],
                ),
              );
            }

            final allRequests = snapshot.data ?? [];
            final requests = filterRequests(allRequests);

            return RefreshIndicator(
              color: clayPrimary,
              onRefresh: refreshRequests,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _buildHeader(allRequests),
                  const SizedBox(height: 22),
                  _buildSearchField(),
                  const SizedBox(height: 18),
                  _buildFilters(),
                  const SizedBox(height: 22),
                  if (allRequests.isEmpty)
                    _buildEmptyState(
                      icon: Icons.inbox_rounded,
                      title: 'No incoming requests',
                      message: 'New tutoring requests will appear here.',
                    )
                  else if (requests.isEmpty)
                    _buildEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching requests',
                      message: 'Try another search term or status filter.',
                    )
                  else
                    ...requests.map(_buildRequestCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<IncomingTutoringRequest> requests) {
    final pendingCount = requests
        .where((request) => request.status.toUpperCase() == 'PENDING')
        .length;

    final acceptedCount = requests
        .where((request) => request.status.toUpperCase() == 'ACCEPTED')
        .length;

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
          const Text(
            'Your Teaching Space',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with learners and manage\nyour tutoring requests.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  Icons.inbox_rounded,
                  '${requests.length}',
                  'Total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStat(
                  Icons.schedule_rounded,
                  '$pendingCount',
                  'Pending',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStat(
                  Icons.check_circle_rounded,
                  '$acceptedCount',
                  'Accepted',
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
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
          hintText: 'Search student or subject...',
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
                  icon: const Icon(Icons.close_rounded, color: clayMuted),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Pending', 'Accepted', 'Rejected'];

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

  Widget _buildRequestCard(IncomingTutoringRequest request) {
    final status = request.status.toUpperCase();
    final isPending = status == 'PENDING';
    final isProcessing = processingRequests.contains(request.id);

    final Color statusColor;
    final Color statusBackground;
    final IconData statusIcon;

    switch (status) {
      case 'ACCEPTED':
        statusColor = const Color(0xFF23865A);
        statusBackground = const Color(0xFFE1F5E9);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E5FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: clayPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  request.requesterName,
                  style: const TextStyle(
                    color: clayText,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: clayBackground,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUBJECT',
                  style: TextStyle(
                    color: clayMuted,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.subject,
                  style: const TextStyle(
                    color: clayText,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'MESSAGE',
                  style: TextStyle(
                    color: clayMuted,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.message.trim().isEmpty
                      ? 'No message provided.'
                      : request.message,
                  style: const TextStyle(
                    color: clayText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23865A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () => handleRequest(request.id, 'ACCEPTED'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC44545),
                      side: const BorderSide(color: Color(0xFFFFCACA)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () => handleRequest(request.id, 'REJECTED'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
          if (isProcessing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: clayPrimary,
              backgroundColor: Color(0xFFE8E5FF),
            ),
          ],
          if (status == 'ACCEPTED') ...[
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: checkSession(request.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(
                    color: clayPrimary,
                    backgroundColor: Color(0xFFE8E5FF),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          sessionCheck.remove(request.id);
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Check Session Status'),
                    ),
                  );
                }

                final hasSession = snapshot.data ?? false;

                if (hasSession) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: clayPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutoringSessionsPage(
                              userId: widget.tutorId,
                              isTutor: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text('View Sessions'),
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: clayPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScheduleTutoringSessionPage(
                                  requestId: request.id,
                                  tutorId: widget.tutorId,
                                  studentName: request.requesterName,
                                  subject: request.subject,
                                ),
                              ),
                            );

                            if (result == true && mounted) {
                              setState(() {
                                sessionCheck[request.id] =
                                    Future<bool>.value(true);
                              });
                            }
                          },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Schedule Session'),
                  ),
                );
              },
            ),
          ],
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

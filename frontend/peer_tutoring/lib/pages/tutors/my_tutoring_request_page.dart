import 'package:flutter/material.dart';

import '../../Services/api_service.dart';
import '../../models/my_tutoring_request.dart';

const Color clayBackground = Color(0xFFF3F1FA);
const Color clayPrimary = Color(0xFF6C63FF);
const Color clayText = Color(0xFF292943);
const Color clayMuted = Color(0xFF85859B);
const Color clayCard = Color(0xFFF8F7FC);

class MyTutoringRequestsPage extends StatefulWidget {
  final int requesterId;

  const MyTutoringRequestsPage({
    super.key,
    required this.requesterId,
  });

  @override
  State<MyTutoringRequestsPage> createState() => _MyTutoringRequestsPageState();
}

class _MyTutoringRequestsPageState extends State<MyTutoringRequestsPage> {
  late Future<List<MyTutoringRequest>> requestsFuture;

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    requestsFuture = ApiService.getMyRequests(widget.requesterId);
  }

  Future<void> refreshRequests() async {
    final future = ApiService.getMyRequests(widget.requesterId);

    setState(() {
      requestsFuture = future;
    });

    await future;
  }

  List<MyTutoringRequest> filterRequests(
    List<MyTutoringRequest> requests,
  ) {
    return requests.where((request) {
      final query = searchQuery.toLowerCase();

      final matchesSearch = request.subject.toLowerCase().contains(query) ||
          request.tutorName.toLowerCase().contains(query) ||
          request.message.toLowerCase().contains(query);

      final status = request.status.toLowerCase();

      final matchesStatus =
          selectedFilter == 'All' || status == selectedFilter.toLowerCase();

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
          'My Tutoring Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<MyTutoringRequest>>(
          future: requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: clayPrimary,
                ),
              );
            }

            if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: refreshRequests,
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
                      'Could not load your requests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: clayText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _buildHeader(allRequests.length),
                  const SizedBox(height: 22),
                  _buildSearchField(),
                  const SizedBox(height: 18),
                  _buildFilters(),
                  const SizedBox(height: 22),
                  if (allRequests.isEmpty)
                    _buildEmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'No tutoring requests yet',
                      message:
                          'Find a tutor and send your first tutoring request.',
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

  Widget _buildHeader(int totalRequests) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8178FF),
            Color(0xFF6559E8),
          ],
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keep learning!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your tutoring requests\nand their latest status.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$totalRequests ${totalRequests == 1 ? 'Request' : 'Requests'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: Colors.white,
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
          hintText: 'Search subject, tutor, or message...',
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

  Widget _buildRequestCard(MyTutoringRequest request) {
    final status = request.status.toLowerCase();

    final Color statusColor;
    final Color statusBackground;
    final IconData statusIcon;

    switch (status) {
      case 'accepted':
        statusColor = const Color(0xFF23865A);
        statusBackground = const Color(0xFFE1F5E9);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
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
                  Icons.menu_book_rounded,
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
                      request.subject,
                      style: const TextStyle(
                        color: clayText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tutor: ${request.tutorName}',
                      style: const TextStyle(
                        color: clayMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: statusBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: clayBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR MESSAGE',
                  style: TextStyle(
                    color: clayMuted,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  request.message.trim().isEmpty
                      ? 'No message provided.'
                      : request.message,
                  style: const TextStyle(
                    color: clayText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'STATUS',
                style: TextStyle(
                  color: clayMuted,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
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

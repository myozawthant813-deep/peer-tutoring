import 'package:flutter/material.dart';

import '../../Services/api_service.dart';
import '../../models/incoming_tutoring_request.dart';

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
        loadRequests();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        SnackBar(
          content: Text('Error: $e'),
        ),
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
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshRequests,
        child: FutureBuilder<List<IncomingTutoringRequest>>(
          future: requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      'Failed to load requests. Pull down to retry.',
                    ),
                  ),
                ],
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text('No incoming requests yet.'),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final isProcessing = processingRequests.contains(request.id);
                final isPending = request.status == 'PENDING';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                request.requesterName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          request.subject,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.message.isEmpty
                              ? 'No message provided.'
                              : request.message,
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(request.status),
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isProcessing
                                      ? null
                                      : () => handleRequest(
                                            request.id,
                                            'ACCEPTED',
                                          ),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isProcessing
                                      ? null
                                      : () => handleRequest(
                                            request.id,
                                            'REJECTED',
                                          ),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isProcessing)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(),
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

import 'package:flutter/material.dart';

import '../../Services/api_service.dart';
import '../../models/my_tutoring_request.dart';

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

  @override
  void initState() {
    super.initState();
    requestsFuture = ApiService.getMyRequests(widget.requesterId);
  }

  Future<void> refreshRequests() async {
    setState(() {
      requestsFuture = ApiService.getMyRequests(widget.requesterId);
    });

    await requestsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tutoring Requests'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshRequests,
        child: FutureBuilder<List<MyTutoringRequest>>(
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
                    child: Text('You have no tutoring requests yet.'),
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.menu_book),
                    ),
                    title: Text(request.subject),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Tutor: ${request.tutorName}'),
                        Text('Message: ${request.message}'),
                        const SizedBox(height: 6),
                        Text('Status: ${request.status}'),
                      ],
                    ),
                    isThreeLine: true,
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

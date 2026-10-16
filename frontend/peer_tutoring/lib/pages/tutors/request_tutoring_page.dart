import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/models/tutoring_request.dart';

class RequestTutoringPage extends StatefulWidget {
  final int requesterId;
  final int tutorId;
  final String tutorName;
  const RequestTutoringPage(
      {super.key,
      required this.requesterId,
      required this.tutorId,
      required this.tutorName});

  @override
  State<RequestTutoringPage> createState() => _RequestTutoringPage();
}

class _RequestTutoringPage extends State<RequestTutoringPage> {
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  bool isLoading = false;

  Future<void> sendRequest() async {
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter a subject')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final request = TutoringRequest(
          requesterId: widget.requesterId,
          tutorId: widget.tutorId,
          subject: subject,
          message: message);

      await ApiService.createTutoringRequest(request);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tutoring request send successfully!")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request tutoring"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request tutor help from ${widget.tutorName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 24,
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                hintText: 'e.g Java Programming',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: "Message",
                  hintText: 'Expalin what you need help with',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: isLoading ? null : sendRequest,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('SEND REQUest')),
            )
          ],
        ),
      ),
    );
  }
}

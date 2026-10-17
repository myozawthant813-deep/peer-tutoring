import 'package:flutter/material.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/models/tutoring_session.dart';

class ScheduleTutoringSessionPage extends StatefulWidget {
  final int requestId;
  final int tutorId;
  final String studentName;
  final String subject;

  const ScheduleTutoringSessionPage({
    super.key,
    required this.requestId,
    required this.tutorId,
    required this.studentName,
    required this.subject,
  });

  @override
  State<ScheduleTutoringSessionPage> createState() =>
      _ScheduleTutoringSessionPageState();
}

class _ScheduleTutoringSessionPageState
    extends State<ScheduleTutoringSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _meetingLinkController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;

  @override
  void dispose() {
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _scheduleSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time.'),
        ),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!scheduledAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final session = TutoringSession(
        requestId: widget.requestId,
        tutorId: widget.tutorId,
        scheduledAt: scheduledAt,
        meetingLink: _meetingLinkController.text.trim(),
      );

      await ApiService.scheduleTutoringSession(session);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutoring session scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Tutoring'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Student: ${widget.studentName}'),
              Text('Subject: ${widget.subject}'),
              const SizedBox(height: 24),

              // Date picker
              const Text(
                'Session Date',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _selectedDate == null
                        ? 'Choose Date'
                        : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time picker
              const Text(
                'Session Time',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _selectedTime == null
                        ? 'Choose Time'
                        : _selectedTime!.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Meeting link
              TextFormField(
                controller: _meetingLinkController,
                enabled: !_isLoading,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Meeting Link (optional)',
                  hintText: 'https://meet.google.com/...',
                  prefixIcon: Icon(Icons.video_call),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final link = value?.trim() ?? '';

                  if (link.isEmpty) return null;

                  final uri = Uri.tryParse(link);

                  if (uri == null ||
                      !uri.hasScheme ||
                      (uri.scheme != 'http' && uri.scheme != 'https') ||
                      uri.host.isEmpty) {
                    return 'Enter a valid HTTP or HTTPS URL.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Schedule button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scheduleSession,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.event_available),
                  label: Text(
                    _isLoading ? 'Scheduling...' : 'Schedule Session',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

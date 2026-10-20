import 'package:flutter/material.dart';
import '../Services/api_service.dart';

class CreateStudyGroupPage extends StatefulWidget {
  final int userId;

  const CreateStudyGroupPage({
    super.key,
    required this.userId,
  });

  @override
  State<CreateStudyGroupPage> createState() => _CreateStudyGroupPageState();
}

class _CreateStudyGroupPageState extends State<CreateStudyGroupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.createStudyGroup(
        name: nameController.text.trim(),
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
        creatorId: widget.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study group created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to the Study Groups page.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    nameController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              const Text(
                'Start a Study Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a group and study together with other students.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Group name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'e.g. Java Programming Study Group',
                  prefixIcon: Icon(Icons.groups_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Subject
              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g. Java, Database, Mathematics',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What will your group study?',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : createGroup,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    isLoading ? 'Creating...' : 'Create Group',
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

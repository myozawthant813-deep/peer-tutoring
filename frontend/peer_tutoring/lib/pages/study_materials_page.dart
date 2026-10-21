import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peer_tutoring/Services/api_service.dart';
import 'package:peer_tutoring/Services/auth_session.dart';

class StudyMaterialsPage extends StatefulWidget {
  const StudyMaterialsPage({super.key});

  @override
  State<StudyMaterialsPage> createState() => _StudyMaterialsPageState();
}

class _StudyMaterialsPageState extends State<StudyMaterialsPage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> materials = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> deleteMaterial(
    Map<String, dynamic> material,
  ) async {
    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please log in again.');
      return;
    }

    final uploaderId = int.tryParse(
      material['uploadedById'].toString(),
    );

    if (uploaderId != userId) {
      _showMessage('You can only delete your own materials.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Material?'),
        content: Text(
          'Are you sure you want to delete "${material['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteStudyMaterial(
        materialId: int.parse(material['id'].toString()),
        userId: userId,
      );

      if (!mounted) return;

      await loadMaterials(subject: searchController.text);

      if (mounted) {
        _showMessage('Material deleted successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Could not delete material: $e');
      }
    }
  }

  Future<void> loadMaterials({String subject = ''}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = subject.trim().isEmpty
          ? await ApiService.getStudyMaterials()
          : await ApiService.searchStudyMaterials(subject.trim());

      if (!mounted) return;

      setState(() {
        materials = result;
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

  Future<void> openMaterial(String fileUrl) async {
    final uri = Uri.tryParse(fileUrl);

    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      _showMessage('This material has an invalid URL.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showMessage('Could not open this material.');
      }
    } catch (_) {
      _showMessage('Could not open this material.');
    }
  }

  Future<void> showAddMaterialDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final subjectController = TextEditingController();
    final urlController = TextEditingController();

    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please log in again to share materials.');
      return;
    }

    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Share Study Material'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a title'
                                : null,
                      ),
                      TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a subject'
                                : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                      ),
                      TextFormField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'Material URL',
                          hintText: 'https://...',
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          final uri = Uri.tryParse(value?.trim() ?? '');

                          if (uri == null ||
                              !uri.hasAuthority ||
                              (uri.scheme != 'http' && uri.scheme != 'https')) {
                            return 'Enter a valid HTTP or HTTPS URL';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSaving = true);

                          try {
                            await ApiService.createStudyMaterial(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              subject: subjectController.text.trim(),
                              fileUrl: urlController.text.trim(),
                              uploadedById: userId,
                            );

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);

                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not share material: $e',
                                    ),
                                  ),
                                );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    urlController.dispose();

    if (shouldRefresh == true && mounted) {
      await loadMaterials();
      if (mounted) _showMessage('Study material shared successfully!');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> editMaterial(
    Map<String, dynamic> material,
  ) async {
    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to edit materials.'),
        ),
      );
      return;
    }

    if (userId.toString() != material['uploadedById'].toString()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit your own materials.'),
        ),
      );
      return;
    }

    final titleController = TextEditingController(
      text: material['title']?.toString() ?? '',
    );
    final subjectController = TextEditingController(
      text: material['subject']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: material['description']?.toString() ?? '',
    );
    final fileUrlController = TextEditingController(
      text: material['fileUrl']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Study Material'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a title'
                        : null,
                  ),
                  TextFormField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a subject'
                        : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: fileUrlController,
                    decoration: const InputDecoration(
                      labelText: 'File URL',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a file URL'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !mounted) {
      titleController.dispose();
      subjectController.dispose();
      descriptionController.dispose();
      fileUrlController.dispose();
      return;
    }

    try {
      await ApiService.updateStudyMaterial(
        materialId: int.parse(material['id'].toString()),
        userId: userId,
        title: titleController.text.trim(),
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
        fileUrl: fileUrlController.text.trim(),
      );

      if (!mounted) return;

      await loadMaterials();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study material updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
        ),
      );
    } finally {
      titleController.dispose();
      subjectController.dispose();
      descriptionController.dispose();
      fileUrlController.dispose();
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
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => loadMaterials(
              subject: searchController.text,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddMaterialDialog,
        icon: const Icon(Icons.add),
        label: const Text('Share Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by subject',
                hintText: 'e.g. Java, Database, Networking',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    loadMaterials();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) => loadMaterials(subject: value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Could not load materials.\n$errorMessage',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => loadMaterials(
                                  subject: searchController.text,
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : materials.isEmpty
                          ? const Center(
                              child: Text(
                                'No study materials found.\nShare the first one!',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: materials.length,
                              itemBuilder: (context, index) {
                                final material =
                                    materials[index] as Map<String, dynamic>;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.menu_book),
                                    ),
                                    title: Text(
                                      material['title']?.toString() ??
                                          'Untitled',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Subject: ${material['subject'] ?? 'Unknown'}',
                                          ),
                                          if ((material['description']
                                                      ?.toString() ??
                                                  '')
                                              .isNotEmpty)
                                            Text(
                                              material['description']
                                                  .toString(),
                                            ),
                                          Text(
                                            'Shared by: ${material['uploadedByName'] ?? 'Unknown'}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: FutureBuilder<int?>(
                                      future: AuthSession.getUserId(),
                                      builder: (context, snapshot) {
                                        final currentUserId = snapshot.data;
                                        final uploaderId = int.tryParse(
                                          material['uploadedById'].toString(),
                                        );

                                        final isOwner = currentUserId != null &&
                                            uploaderId != null &&
                                            currentUserId == uploaderId;

                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: 'Open material',
                                              icon:
                                                  const Icon(Icons.open_in_new),
                                              onPressed: () => openMaterial(
                                                material['fileUrl'].toString(),
                                              ),
                                            ),
                                            if (isOwner) ...[
                                              IconButton(
                                                tooltip: 'Edit material',
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    editMaterial(material),
                                              ),
                                              IconButton(
                                                tooltip: 'Delete material',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    deleteMaterial(material),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                    onTap: () => openMaterial(
                                      material['fileUrl']?.toString() ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

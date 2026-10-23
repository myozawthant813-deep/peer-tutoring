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
  static const Color backgroundColor = Color(0xFFF3F1FA);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF292943);
  static const Color mutedColor = Color(0xFF85859B);
  static const Color cardColor = Colors.white;
  static const Color softPurple = Color(0xFFEAE7FF);
  static const Color softGreen = Color(0xFFE0F5E9);
  static const Color softOrange = Color(0xFFFFF0DF);
  static const Color softRed = Color(0xFFFFE8E8);

  final TextEditingController searchController = TextEditingController();

  List<dynamic> materials = [];

  bool isLoading = true;
  String? errorMessage;

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    currentUserId = await AuthSession.getUserId();

    if (!mounted) return;

    await loadMaterials(subject: searchController.text);
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

  Future<void> refreshMaterials() async {
    currentUserId = await AuthSession.getUserId();

    if (!mounted) return;

    await loadMaterials(subject: searchController.text);
  }

  Future<void> openMaterial(String fileUrl) async {
    final uri = Uri.tryParse(fileUrl.trim());

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
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
    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please log in again to share materials.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final subjectController = TextEditingController();
    final urlController = TextEditingController();

    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.library_add_rounded,
                    color: primaryColor,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Share Material',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(
                        controller: titleController,
                        label: 'Title',
                        hint: 'e.g. Java Programming Notes',
                        icon: Icons.title_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a title'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: subjectController,
                        label: 'Subject',
                        hint: 'e.g. Java',
                        icon: Icons.menu_book_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a subject'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: descriptionController,
                        label: 'Description',
                        hint: 'What will students learn?',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: urlController,
                        label: 'Material URL',
                        hint: 'https://...',
                        icon: Icons.link_rounded,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
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
                  icon: isSaving
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_rounded),
                  label: Text(isSaving ? 'Sharing...' : 'Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
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
      await refreshMaterials();

      if (mounted) {
        _showMessage('Study material shared successfully!');
      }
    }
  }

  Future<void> editMaterial(Map<String, dynamic> material) async {
    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please log in to edit materials.');
      return;
    }

    final uploaderId = int.tryParse(material['uploadedById']?.toString() ?? '');

    if (uploaderId != userId) {
      _showMessage('You can only edit your own materials.');
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
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit_rounded, color: primaryColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Edit Material',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(
                        controller: titleController,
                        label: 'Title',
                        icon: Icons.title_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a title'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: subjectController,
                        label: 'Subject',
                        icon: Icons.menu_book_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a subject'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _dialogField(
                        controller: fileUrlController,
                        label: 'Material URL',
                        icon: Icons.link_rounded,
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                            await ApiService.updateStudyMaterial(
                              materialId: int.parse(material['id'].toString()),
                              userId: userId,
                              title: titleController.text.trim(),
                              subject: subjectController.text.trim(),
                              description: descriptionController.text.trim(),
                              fileUrl: fileUrlController.text.trim(),
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
                                    content: Text('Update failed: $e'),
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
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    fileUrlController.dispose();

    if (shouldSave == true && mounted) {
      await refreshMaterials();

      if (mounted) {
        _showMessage('Study material updated successfully!');
      }
    }
  }

  Future<void> deleteMaterial(Map<String, dynamic> material) async {
    final userId = await AuthSession.getUserId();

    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please log in again.');
      return;
    }

    final uploaderId = int.tryParse(material['uploadedById']?.toString() ?? '');

    if (uploaderId != userId) {
      _showMessage('You can only delete your own materials.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: 38,
          color: Colors.redAccent,
        ),
        title: const Text(
          'Delete Material?',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${material['title'] ?? 'this material'}"?',
          style: const TextStyle(
            color: mutedColor,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
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

      await refreshMaterials();

      if (mounted) {
        _showMessage('Material deleted successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Could not delete material: $e');
      }
    }
  }

  String? _validateUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a valid HTTP or HTTPS URL';
    }

    return null;
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Study Materials',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : refreshMaterials,
            icon: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddMaterialDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Share Material',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildMaterialsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                    'Learn something new ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Discover notes, links, and resources shared by your peers.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${materials.length} ${materials.length == 1 ? 'resource' : 'resources'} available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => loadMaterials(subject: value),
        decoration: InputDecoration(
          hintText: 'Search by subject...',
          hintStyle: const TextStyle(color: mutedColor),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryColor,
          ),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: mutedColor,
                  ),
                  onPressed: () {
                    searchController.clear();
                    loadMaterials();
                  },
                ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide(
              color: primaryColor.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load materials',
            subtitle: errorMessage!,
            buttonLabel: 'Try Again',
            onPressed: () => loadMaterials(subject: searchController.text),
          ),
        ),
      );
    }

    if (materials.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildEmptyState(
            icon: Icons.menu_book_rounded,
            title: 'No materials found',
            subtitle: searchController.text.trim().isEmpty
                ? 'Be the first to share a useful study resource with your peers.'
                : 'Try another subject or clear your search.',
            buttonLabel: searchController.text.trim().isEmpty
                ? 'Share Material'
                : 'Clear Search',
            onPressed: searchController.text.trim().isEmpty
                ? showAddMaterialDialog
                : () {
                    searchController.clear();
                    loadMaterials();
                  },
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: refreshMaterials,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 650
                  ? 2
                  : 1;

          if (columns == 1) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = Map<String, dynamic>.from(
                  materials[index] as Map,
                );
                return _buildMaterialCard(material);
              },
            );
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 270,
            ),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = Map<String, dynamic>.from(
                materials[index] as Map,
              );
              return _buildMaterialCard(material);
            },
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final title = (material['title'] ?? 'Untitled Material').toString();
    final subject = (material['subject'] ?? 'General').toString();
    final description = (material['description'] ?? '').toString().trim();
    final uploader = (material['uploadedByName'] ?? 'Unknown').toString();

    final uploaderId = int.tryParse(material['uploadedById']?.toString() ?? '');

    final isOwner = currentUserId != null && uploaderId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => openMaterial(
          material['fileUrl']?.toString() ?? '',
        ),
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                      color: softPurple,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: primaryColor,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: softPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      tooltip: 'Material options',
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          editMaterial(material);
                        } else if (value == 'delete') {
                          deleteMaterial(material);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: mutedColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Text(
                  description.isEmpty
                      ? 'No description provided.'
                      : description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: mutedColor,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      uploader,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => openMaterial(
                    material['fileUrl']?.toString() ?? '',
                  ),
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Open Material',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softPurple,
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

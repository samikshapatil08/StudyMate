import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';
import '../blocs/notes/notes_bloc.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          /// 🔹 HEADER ROW
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Your Notes",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),

                /// 🔽 SORT & FILTER BUTTON
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    NoteSortOption currentSort = NoteSortOption.newest;
                    NoteFilterOption currentFilter = NoteFilterOption.all;

                    if (state is NotesLoaded) {
                      currentSort = state.sortOption;
                      currentFilter = state.filterOption;
                    }

                    return PopupMenuButton<dynamic>(
                      icon: Icon(Icons.sort, color: theme.iconTheme.color),
                      color: theme.cardColor,
                      onSelected: (value) {
                        if (value is NoteSortOption) {
                          context.read<NotesBloc>().add(
                            NotesSortChanged(value),
                          );
                        } else if (value is NoteFilterOption) {
                          context.read<NotesBloc>().add(
                            NotesFilterChanged(value),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        // --- SORTING SECTION ---
                        const PopupMenuItem(
                          enabled: false,
                          child: Text(
                            "SORT BY",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteSortOption.newest,
                          checked: currentSort == NoteSortOption.newest,
                          child: const Text("Newest First"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteSortOption.oldest,
                          checked: currentSort == NoteSortOption.oldest,
                          child: const Text("Oldest First"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteSortOption.aToZ,
                          checked: currentSort == NoteSortOption.aToZ,
                          child: const Text("A - Z"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteSortOption.zToA,
                          checked: currentSort == NoteSortOption.zToA,
                          child: const Text("Z - A"),
                        ),

                        const PopupMenuDivider(),

                        // --- FILTER SECTION ---
                        const PopupMenuItem(
                          enabled: false,
                          child: Text(
                            "FILTER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteFilterOption.all,
                          checked: currentFilter == NoteFilterOption.all,
                          child: const Text("All Notes"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteFilterOption.hasImage,
                          checked: currentFilter == NoteFilterOption.hasImage,
                          child: const Text("Has Images"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteFilterOption.textOnly,
                          checked: currentFilter == NoteFilterOption.textOnly,
                          child: const Text("Text Only"),
                        ),
                      ],
                    );
                  },
                ),

                /// ➕ ADD BUTTON
                TextButton.icon(
                  onPressed: () => _showNoteDialog(context, null),
                  icon: const Icon(Icons.add, color: Colors.red),
                  label: Text(
                    "Add",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onChanged: (val) =>
                    context.read<NotesBloc>().add(NotesSearchChanged(val)),
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: GoogleFonts.inter(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          /// 📋 GRID VIEW
          Flexible(
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                List<dynamic> notes = [];
                if (state is NotesLoaded) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploading) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploadSuccess) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploadFailure) {
                  notes = state.filteredNotes;
                } else {
                  return const Center(child: CircularProgressIndicator());
                }

                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      "No notes found",
                      style: GoogleFonts.inter(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final data = note.data() as Map<String, dynamic>;
                    final attachments = List<Map<String, dynamic>>.from(
                      data['attachments'] ?? [],
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailScreen(
                              noteId: note.id,
                              title: data['title'] ?? '',
                              content: data['content'] ?? '',
                              attachments: attachments,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              AppTheme().colorPalette[index %
                                  AppTheme().colorPalette.length],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppTheme.textOnColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['content'] ?? '',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppTheme.textOnColor,
                              ),
                            ),
                            if (attachments.isNotEmpty) ...[
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attachment,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${attachments.length}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    Map<String, dynamic>? existingData,
  ) {
    final titleController = TextEditingController(
      text: existingData?['title'] ?? '',
    );
    final contentController = TextEditingController(
      text: existingData?['content'] ?? '',
    );
    List<Map<String, dynamic>> currentAttachments = existingData != null
        ? List<Map<String, dynamic>>.from(existingData['attachments'] ?? [])
        : [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NotesBloc>(context),
          child: StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              return BlocListener<NotesBloc, NotesState>(
                listener: (context, state) {
                  if (state is NoteAttachmentUploadSuccess) {
                    setState(() {
                      currentAttachments.add({
                        'url': state.downloadUrl,
                        'type': state.type,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Attachment uploaded!")),
                    );
                  }
                },
                child: AlertDialog(
                  title: Text(
                    existingData == null ? "New Note" : "Edit Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(labelText: "Content"),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Attachments:"),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.image,
                                  color: AppTheme.primaryPurple,
                                ),
                                onPressed: () =>
                                    _pickFile(context, FileType.image, 'image'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  color: AppTheme.accentRed,
                                ),
                                onPressed: () =>
                                    _pickFile(context, FileType.custom, 'pdf'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (currentAttachments.isNotEmpty)
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentAttachments.length,
                            itemBuilder: (context, index) {
                              final att = currentAttachments[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: att['type'] == 'image'
                                      ? DecorationImage(
                                          image: NetworkImage(att['url']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: att['type'] == 'pdf'
                                    ? const Center(
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      BlocBuilder<NotesBloc, NotesState>(
                        builder: (context, state) =>
                            state is NoteAttachmentUploading
                            ? const LinearProgressIndicator()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        if (existingData == null) {
                          context.read<NotesBloc>().add(
                            NotesAddRequested(
                              titleController.text,
                              contentController.text,
                              attachments: currentAttachments,
                            ),
                          );
                        } else {
                          context.read<NotesBloc>().add(
                            NotesUpdateRequested(
                              existingData['id'],
                              titleController.text,
                              contentController.text,
                              attachments: currentAttachments,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: Text(existingData == null ? "Save" : "Update"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickFile(
    BuildContext context,
    FileType type,
    String customType,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom ? ['pdf'] : null,
    );
    if (!context.mounted) return;
    if (result != null && result.files.single.path != null) {
      context.read<NotesBloc>().add(
        NotesUploadAttachmentRequested(
          filePath: result.files.single.path!,
          fileType: customType,
        ),
      );
    }
  }
}

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  final String title;
  final String content;
  final List<Map<String, dynamic>> attachments;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
    required this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: const Text("Note"),
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNoteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.accentRed),
            onPressed: () {
              context.read<NotesBloc>().add(NotesDeleteRequested(noteId));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            if (attachments.isNotEmpty) ...[
              const Divider(),
              const Text(
                "Attachments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: attachments.map((att) {
                  return GestureDetector(
                    onTap: () {
                      if (att['type'] == 'image') {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              Dialog(child: Image.network(att['url'])),
                        );
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: att['type'] == 'image'
                            ? DecorationImage(
                                image: NetworkImage(att['url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: att['type'] == 'pdf'
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.red),
                                  Text("PDF", style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Full Edit Dialog with Add/Remove Attachment Support
  void _editNoteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);
    // Deep copy to allow editing without affecting original until saved
    List<Map<String, dynamic>> currentAttachments =
        List<Map<String, dynamic>>.from(attachments);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NotesBloc>(context),
          child: StatefulBuilder(
            builder: (context, setState) {
              return BlocListener<NotesBloc, NotesState>(
                listener: (context, state) {
                  if (state is NoteAttachmentUploadSuccess) {
                    setState(() {
                      currentAttachments.add({
                        'url': state.downloadUrl,
                        'type': state.type,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Attachment uploaded!")),
                    );
                  }
                },
                child: AlertDialog(
                  title: Text(
                    "Edit Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: "Title"),
                        ),
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: "Content",
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // 📎 ATTACHMENT BUTTONS (Restored)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Attachments:"),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.image,
                                    color: AppTheme.primaryPurple,
                                  ),
                                  onPressed: () => _pickFile(
                                    context,
                                    FileType.image,
                                    'image',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: AppTheme.accentRed,
                                  ),
                                  onPressed: () => _pickFile(
                                    context,
                                    FileType.custom,
                                    'pdf',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 📋 ATTACHMENT LIST (Restored with Delete)
                        if (currentAttachments.isNotEmpty)
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: currentAttachments.length,
                              itemBuilder: (context, index) {
                                final att = currentAttachments[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    image: att['type'] == 'image'
                                        ? DecorationImage(
                                            image: NetworkImage(att['url']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (att['type'] == 'pdf')
                                        const Center(
                                          child: Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.red,
                                          ),
                                        ),
                                      // ❌ Delete Attachment Button
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentAttachments.removeAt(
                                                index,
                                              );
                                            });
                                          },
                                          child: const CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Colors.red,
                                            child: Icon(
                                              Icons.close,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        BlocBuilder<NotesBloc, NotesState>(
                          builder: (context, state) =>
                              state is NoteAttachmentUploading
                              ? const LinearProgressIndicator()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(
                          NotesUpdateRequested(
                            noteId,
                            titleController.text,
                            contentController.text,
                            attachments: currentAttachments,
                          ),
                        );
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to list
                      },
                      child: const Text("Update"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ SHARED: File Picker Logic
  Future<void> _pickFile(
    BuildContext context,
    FileType type,
    String customType,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom ? ['pdf'] : null,
    );
    if (!context.mounted) return;
    if (result != null && result.files.single.path != null) {
      context.read<NotesBloc>().add(
        NotesUploadAttachmentRequested(
          filePath: result.files.single.path!,
          fileType: customType,
        ),
      );
    }
  }
}

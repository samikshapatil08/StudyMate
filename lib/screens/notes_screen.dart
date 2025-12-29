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
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Column(
        children: [
          /// 🔹 HEADER ROW (Title + Sort + Add)
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                
                /// 🔽 SORT & FILTER BUTTON
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    // Defaults
                    var currentSort = NoteSortOption.newest;
                    var currentFilter = NoteFilterOption.all;
                    
                    if (state is NotesLoaded) {
                      currentSort = state.sortOption;
                      currentFilter = state.filterOption;
                    }

                    return PopupMenuButton<dynamic>(
                      icon: const Icon(Icons.sort, color: AppTheme.textSecondary),
                      onSelected: (value) {
                        if (value is NoteSortOption) {
                          context.read<NotesBloc>().add(NotesSortChanged(value));
                        } else if (value is NoteFilterOption) {
                          context.read<NotesBloc>().add(NotesFilterChanged(value));
                        }
                      },
                      itemBuilder: (context) => [
                        // --- SORTING SECTION ---
                        const PopupMenuItem(enabled: false, child: Text("SORT BY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                        const PopupMenuItem(enabled: false, child: Text("FILTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        CheckedPopupMenuItem(
                          value: NoteFilterOption.all,
                          checked: currentFilter == NoteFilterOption.all,
                          child: const Text("All Notes"),
                        ),
                        CheckedPopupMenuItem(
                          value: NoteFilterOption.hasImage,
                          checked: currentFilter == NoteFilterOption.hasImage,
                          child: const Text("Has Image"),
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
                  label: Text("Add",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      )),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) {
                  context.read<NotesBloc>().add(NotesSearchChanged(val));
                },
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
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
                // HANDLE STATES
                List<dynamic> notes = [];
                if (state is NotesLoaded) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploading) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploadSuccess) {
                  notes = state.filteredNotes;
                } else if (state is NoteAttachmentUploadFailure) {
                  notes = state.filteredNotes;
                } else if (state is NotesLoading || state is NotesInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NotesError) {
                  return Center(child: Text(state.message));
                }

                if (notes.isEmpty) {
                  return Center(child: Text("No notes found", style: GoogleFonts.inter()));
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
                    final attachments = List<Map<String, dynamic>>.from(data['attachments'] ?? []);

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
                          color: AppTheme().colorPalette[index % AppTheme().colorPalette.length],
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
                                  const Icon(Icons.attachment, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${attachments.length}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              )
                            ]
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

  // 🛠 Unified Dialog for Add/Edit
  void _showNoteDialog(BuildContext context, Map<String, dynamic>? existingData) {
    final titleController = TextEditingController(text: existingData?['title'] ?? '');
    final contentController = TextEditingController(text: existingData?['content'] ?? '');
    
    List<Map<String, dynamic>> currentAttachments = 
        existingData != null ? List<Map<String, dynamic>>.from(existingData['attachments'] ?? []) : [];

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
                  } else if (state is NoteAttachmentUploadFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: AlertDialog(
                  title: Text(existingData == null ? "New Note" : "Edit Note", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                        TextField(controller: contentController, decoration: const InputDecoration(labelText: "Content"), maxLines: 3),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.image, color: AppTheme.primaryPurple),
                                  onPressed: () => _pickFile(context, FileType.image, 'image'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf, color: AppTheme.accentRed),
                                  onPressed: () => _pickFile(context, FileType.custom, 'pdf'),
                                ),
                              ],
                            )
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
                                      ? DecorationImage(image: NetworkImage(att['url']), fit: BoxFit.cover)
                                      : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (att['type'] == 'pdf')
                                        const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 30)),
                                      Positioned(
                                        right: 0, top: 0,
                                        child: InkWell(
                                          onTap: () => setState(() => currentAttachments.removeAt(index)),
                                          child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        BlocBuilder<NotesBloc, NotesState>(
                          builder: (context, state) {
                            if (state is NoteAttachmentUploading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: LinearProgressIndicator(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    BlocBuilder<NotesBloc, NotesState>(
                      builder: (context, state) {
                        bool isUploading = state is NoteAttachmentUploading;
                        return TextButton(
                          onPressed: isUploading ? null : () {
                            if (existingData == null) {
                              context.read<NotesBloc>().add(
                                NotesAddRequested(titleController.text, contentController.text, attachments: currentAttachments),
                              );
                            } else {
                              context.read<NotesBloc>().add(
                                NotesUpdateRequested(existingData['id'], titleController.text, contentController.text, attachments: currentAttachments),
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: Text(existingData == null ? "Save" : "Update"),
                        );
                      },
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

  Future<void> _pickFile(BuildContext context, FileType type, String customType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom ? ['pdf'] : null,
    );

    if (result != null && result.files.single.path != null) {
      // ignore: use_build_context_synchronously
      context.read<NotesBloc>().add(
        NotesUploadAttachmentRequested(
          filePath: result.files.single.path!, 
          fileType: customType
        )
      );
    }
  }
}

// 📌 NOTE DETAIL SCREEN
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
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text("Note"),
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
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            
            if (attachments.isNotEmpty) ...[
              const Divider(),
              const Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: attachments.map((att) {
                  return GestureDetector(
                    onTap: () {
                      if (att['type'] == 'image') {
                        showDialog(context: context, builder: (_) => Dialog(child: Image.network(att['url'])));
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: att['type'] == 'image' 
                            ? DecorationImage(image: NetworkImage(att['url']), fit: BoxFit.cover)
                            : null,
                      ),
                      child: att['type'] == 'pdf' 
                          ? const Center(child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.picture_as_pdf, color: Colors.red, size: 40), Text("PDF", style: TextStyle(fontSize: 10))],
                            ))
                          : null,
                    ),
                  );
                }).toList(),
              )
            ]
          ],
        ),
      ),
    );
  }

  void _editNoteDialog(BuildContext context) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);
    List<Map<String, dynamic>> currentAttachments = List.from(attachments);

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
                  } else if (state is NoteAttachmentUploadFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: AlertDialog(
                  title: Text("Edit Note", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                        TextField(controller: contentController, decoration: const InputDecoration(labelText: "Content"), maxLines: 3),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.image, color: AppTheme.primaryPurple),
                                  onPressed: () => _pickFile(context, FileType.image, 'image'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf, color: AppTheme.accentRed),
                                  onPressed: () => _pickFile(context, FileType.custom, 'pdf'),
                                ),
                              ],
                            )
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
                                      ? DecorationImage(image: NetworkImage(att['url']), fit: BoxFit.cover)
                                      : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (att['type'] == 'pdf')
                                        const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 30)),
                                      Positioned(
                                        right: 0, top: 0,
                                        child: InkWell(
                                          onTap: () => setState(() => currentAttachments.removeAt(index)),
                                          child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        BlocBuilder<NotesBloc, NotesState>(
                          builder: (context, state) {
                            if (state is NoteAttachmentUploading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: LinearProgressIndicator(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    BlocBuilder<NotesBloc, NotesState>(
                      builder: (context, state) {
                        bool isUploading = state is NoteAttachmentUploading;
                        return TextButton(
                          onPressed: isUploading ? null : () {
                            context.read<NotesBloc>().add(
                              NotesUpdateRequested(
                                noteId,
                                titleController.text,
                                contentController.text,
                                attachments: currentAttachments
                              ),
                            );
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Back to list
                          },
                          child: const Text("Update"),
                        );
                      },
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

  Future<void> _pickFile(BuildContext context, FileType type, String customType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom ? ['pdf'] : null,
    );

    if (result != null && result.files.single.path != null) {
      // ignore: use_build_context_synchronously
      context.read<NotesBloc>().add(
        NotesUploadAttachmentRequested(
          filePath: result.files.single.path!, 
          fileType: customType
        )
      );
    }
  }
}
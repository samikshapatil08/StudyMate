import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../blocs/notes/notes_bloc.dart';
import 'pdf_viewer_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 1200
        ? 4
        : width > 800
            ? 3
            : 2;
    final double aspectRatio = width < 400 ? 0.75 : 0.85;
    final double fontScale = (width / 400).clamp(0.85, 1.2);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
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
                      
                      fontSize: 18 * fontScale,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    NoteSortOption currentSort = NoteSortOption.newest;
                    NoteFilterOption currentFilter = NoteFilterOption.all;
                    if (state is NotesLoaded) {
                      currentSort = state.sortOption;
                      currentFilter = state.filterOption;
                    }
                    return PopupMenuButton<dynamic>(
                      icon: Icon(Icons.sort, color: theme.iconTheme.color,size: 24 * fontScale),
                      color: theme.cardColor,
                      onSelected: (value) {
                        if (value is NoteSortOption) {
                          context
                              .read<NotesBloc>()
                              .add(NotesSortChanged(value));
                        } else if (value is NoteFilterOption) {
                          context
                              .read<NotesBloc>()
                              .add(NotesFilterChanged(value));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            enabled: false,
                            child: Text("SORT BY",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                        CheckedPopupMenuItem(
                            value: NoteSortOption.newest,
                            checked: currentSort == NoteSortOption.newest,
                            child: const Text("Newest First")),
                        CheckedPopupMenuItem(
                            value: NoteSortOption.oldest,
                            checked: currentSort == NoteSortOption.oldest,
                            child: const Text("Oldest First")),
                        CheckedPopupMenuItem(
                            value: NoteSortOption.aToZ,
                            checked: currentSort == NoteSortOption.aToZ,
                            child: const Text("A - Z")),
                        CheckedPopupMenuItem(
                            value: NoteSortOption.zToA,
                            checked: currentSort == NoteSortOption.zToA,
                            child: const Text("Z - A")),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                            enabled: false,
                            child: Text("FILTER",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                        CheckedPopupMenuItem(
                            value: NoteFilterOption.all,
                            checked: currentFilter == NoteFilterOption.all,
                            child: const Text("All Notes")),
                        CheckedPopupMenuItem(
                            value: NoteFilterOption.hasImage,
                            checked: currentFilter == NoteFilterOption.hasImage,
                            child: const Text("Has Images")),
                        CheckedPopupMenuItem(
                            value: NoteFilterOption.textOnly,
                            checked: currentFilter == NoteFilterOption.textOnly,
                            child: const Text("Text Only")),
                      ],
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () => _showNoteDialog(context, null),
                  icon: const Icon(Icons.add, color: Colors.red),
                  label: Text("Add", 
                      style: GoogleFonts.inter( fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w600, color: Colors.red)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyLarge?.color,fontSize: 14 * fontScale),
                onChanged: (val) =>
                    context.read<NotesBloc>().add(NotesSearchChanged(val)),
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: GoogleFonts.inter( fontSize: 14 * fontScale,
                      color: theme.textTheme.bodyMedium?.color),
                  prefixIcon: Icon(Icons.search,
                  size: 20 * fontScale,
                      color: theme.textTheme.bodyMedium?.color,),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),
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
                      child: Text("No notes found",
                          style: GoogleFonts.inter( fontSize: 16 * fontScale,
                              color: theme.textTheme.bodyMedium?.color)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final data = note.data() as Map<String, dynamic>;
                    final attachments = List<Map<String, dynamic>>.from(
                        data['attachments'] ?? []);

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
                          color: AppTheme().colorPalette[
                              index % AppTheme().colorPalette.length],
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
                                  fontSize: 16 * fontScale,
                                  color: AppTheme.textOnColor),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                data['content'] ?? '',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    color: AppTheme.textOnColor, fontSize: 13 * fontScale,),
                              ),
                            ),
                            if (attachments.isNotEmpty) ...[
                              const Spacer(),
                              Row(
                                children: [
                                Icon(Icons.attachment,
                                      size: 14 * fontScale, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text("${attachments.length}",
                                      style:  TextStyle(
                                          color: Colors.white70, fontSize: 11 * fontScale)),
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
      BuildContext context, Map<String, dynamic>? existingData) {
    final titleController =
        TextEditingController(text: existingData?['title'] ?? '');
    final contentController =
        TextEditingController(text: existingData?['content'] ?? '');
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
                      currentAttachments
                          .add({'url': state.downloadUrl, 'type': state.type});
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Attachment uploaded!")));
                  }
                },
                child: AlertDialog(
                  title: Text(existingData == null ? "New Note" : "Edit Note",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                                controller: titleController,
                                decoration:
                                    const InputDecoration(labelText: "Title")),
                            TextField(
                                controller: contentController,
                                decoration:
                                    const InputDecoration(labelText: "Content"),
                                maxLines: 3),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Attachments:"),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.image,
                                            color: AppTheme.primaryPurple),
                                        onPressed: () => _pickFile(
                                            context, FileType.image, 'image')),
                                    IconButton(
                                        icon: const Icon(Icons.picture_as_pdf,
                                            color: AppTheme.accentRed),
                                        onPressed: () => _pickFile(
                                            context, FileType.custom, 'pdf')),
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
                                                fit: BoxFit.cover)
                                            : null,
                                      ),
                                      child: att['type'] == 'pdf'
                                          ? const Center(
                                              child: Icon(Icons.picture_as_pdf,
                                                  color: Colors.red))
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
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        if (existingData == null) {
                          context.read<NotesBloc>().add(NotesAddRequested(
                              titleController.text, contentController.text,
                              attachments: currentAttachments));
                        } else {
                          context.read<NotesBloc>().add(NotesUpdateRequested(
                              existingData['id'],
                              titleController.text,
                              contentController.text,
                              attachments: currentAttachments));
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
      BuildContext context, FileType type, String customType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: type == FileType.custom ? ['pdf'] : null,
        withData: true);
    if (!context.mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        context.read<NotesBloc>().add(NotesUploadAttachmentRequested(
            fileBytes: file.bytes!, fileName: file.name, fileType: customType));
      }
    }
  }
}

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  final String title;
  final String content;
  final List<Map<String, dynamic>> attachments;

  const NoteDetailScreen(
      {super.key,
      required this.noteId,
      required this.title,
      required this.content,
      required this.attachments});

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
              onPressed: () => _editNoteDialog(context)),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.accentRed),
            onPressed: () {
              context.read<NotesBloc>().add(NotesDeleteRequested(noteId));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                Text(content,
                    style: TextStyle(
                        fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 24),
                if (attachments.isNotEmpty) ...[
                  const Divider(),
                  const Text("Attachments",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: attachments.map((att) {
                      return GestureDetector(
                        onTap: () async {
                          if (att['type'] == 'image') {
                            showDialog(
                                context: context,
                                builder: (_) =>
                                    Dialog(child: Image.network(att['url'])));
                          } else if (att['type'] == 'pdf') {
                            final bool isDesktop = !kIsWeb &&
                                (defaultTargetPlatform ==
                                        TargetPlatform.windows ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.linux ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.macOS);

                            if (isDesktop) {
                              final uri = Uri.parse(att['url']);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Could not open PDF on Windows")),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerScreen(
                                      url: att['url'], title: title),
                                ),
                              );
                            }
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
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: att['type'] == 'pdf'
                              ? const Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                      Icon(Icons.picture_as_pdf,
                                          color: Colors.red),
                                      Text("PDF",
                                          style: TextStyle(fontSize: 10))
                                    ]))
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editNoteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);
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
                      currentAttachments
                          .add({'url': state.downloadUrl, 'type': state.type});
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Attachment uploaded!")));
                  }
                },
                child: AlertDialog(
                  title: Text("Edit Note",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                                controller: titleController,
                                decoration:
                                    const InputDecoration(labelText: "Title")),
                            TextField(
                                controller: contentController,
                                decoration:
                                    const InputDecoration(labelText: "Content"),
                                maxLines: 3),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Attachments:"),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.image,
                                            color: AppTheme.primaryPurple),
                                        onPressed: () => _pickFile(
                                            context, FileType.image, 'image')),
                                    IconButton(
                                        icon: const Icon(Icons.picture_as_pdf,
                                            color: AppTheme.accentRed),
                                        onPressed: () => _pickFile(
                                            context, FileType.custom, 'pdf')),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: att['type'] == 'image'
                                              ? DecorationImage(
                                                  image:
                                                      NetworkImage(att['url']),
                                                  fit: BoxFit.cover)
                                              : null),
                                      child: Stack(children: [
                                        if (att['type'] == 'pdf')
                                          const Center(
                                              child: Icon(Icons.picture_as_pdf,
                                                  color: Colors.red)),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                currentAttachments
                                                    .removeAt(index);
                                              });
                                            },
                                            child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.red,
                                                child: Icon(Icons.close,
                                                    size: 12,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ]),
                                    );
                                  },
                                ),
                              ),
                            BlocBuilder<NotesBloc, NotesState>(
                                builder: (context, state) =>
                                    state is NoteAttachmentUploading
                                        ? const LinearProgressIndicator()
                                        : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(NotesUpdateRequested(
                            noteId,
                            titleController.text,
                            contentController.text,
                            attachments: currentAttachments));
                        Navigator.pop(context);
                        Navigator.pop(context);
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

  Future<void> _pickFile(
      BuildContext context, FileType type, String customType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: type == FileType.custom ? ['pdf'] : null,
        withData: true);
    if (!context.mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        context.read<NotesBloc>().add(NotesUploadAttachmentRequested(
            fileBytes: file.bytes!, fileName: file.name, fileType: customType));
      }
    }
  }
}

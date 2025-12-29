import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
                
                /// 🔽 SORT BUTTON
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    NoteSortOption currentSort = NoteSortOption.newest;
                    if (state is NotesLoaded) currentSort = state.sortOption;

                    return PopupMenuButton<NoteSortOption>(
                      icon: const Icon(Icons.sort, color: AppTheme.textSecondary),
                      initialValue: currentSort,
                      onSelected: (option) {
                        context.read<NotesBloc>().add(NotesSortChanged(option));
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: NoteSortOption.newest,
                          child: Text("Newest First"),
                        ),
                        const PopupMenuItem(
                          value: NoteSortOption.oldest,
                          child: Text("Oldest First"),
                        ),
                        const PopupMenuItem(
                          value: NoteSortOption.aToZ,
                          child: Text("A - Z"),
                        ),
                        const PopupMenuItem(
                          value: NoteSortOption.zToA,
                          child: Text("Z - A"),
                        ),
                      ],
                    );
                  },
                ),

                /// ➕ ADD BUTTON
                TextButton.icon(
                  onPressed: () => _addNoteDialog(context),
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
                if (state is NotesLoading || state is NotesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotesError) {
                  return Center(child: Text(state.message));
                }

                // USE FILTERED LIST
                final notes = (state as NotesLoaded).filteredNotes;

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

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailScreen(
                              noteId: note.id,
                              title: data['title'] ?? '',
                              content: data['content'] ?? '',
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

  void _addNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("New Note", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: "Content"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(
                    NotesAddRequested(titleController.text, contentController.text),
                  );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  final String title;
  final String content;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(content),
          ],
        ),
      ),
    );
  }

  void _editNoteDialog(BuildContext context) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
             TextField(controller: contentController, maxLines: 3, decoration: const InputDecoration(labelText: "Content")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotesBloc>().add(
                NotesUpdateRequested(noteId, titleController.text, contentController.text)
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
}
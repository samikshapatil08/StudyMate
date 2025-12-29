part of 'notes_bloc.dart';

enum NoteSortOption { newest, oldest, aToZ, zToA }
// ✅ NEW: Filter Options
enum NoteFilterOption { all, hasImage, textOnly }

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<QueryDocumentSnapshot> allNotes; // Raw data
  final List<QueryDocumentSnapshot> filteredNotes; // UI data
  final String searchQuery;
  final NoteSortOption sortOption;
  // ✅ NEW: Track current filter
  final NoteFilterOption filterOption;

  NotesLoaded({
    required this.allNotes,
    required this.filteredNotes,
    this.searchQuery = '',
    this.sortOption = NoteSortOption.newest,
    this.filterOption = NoteFilterOption.all,
  });
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}

// UPLOAD STATES (Unchanged)
class NoteAttachmentUploading extends NotesState {
  final List<QueryDocumentSnapshot> allNotes; 
  final List<QueryDocumentSnapshot> filteredNotes;

  NoteAttachmentUploading({
    required this.allNotes, 
    required this.filteredNotes
  });
}

class NoteAttachmentUploadSuccess extends NotesState {
  final String downloadUrl;
  final String type;
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;

  NoteAttachmentUploadSuccess({
    required this.downloadUrl,
    required this.type,
    required this.allNotes,
    required this.filteredNotes,
  });
}

class NoteAttachmentUploadFailure extends NotesState {
  final String message;
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;

  NoteAttachmentUploadFailure({
    required this.message,
    required this.allNotes,
    required this.filteredNotes,
  });
}
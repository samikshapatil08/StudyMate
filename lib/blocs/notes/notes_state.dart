part of 'notes_bloc.dart';

enum NoteSortOption { newest, oldest, aToZ, zToA }

enum NoteFilterOption { all, hasImage, textOnly }

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;
  final String searchQuery;
  final NoteSortOption sortOption;

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

class NoteAttachmentUploading extends NotesState {
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;
  final NoteFilterOption filterOption;

  NoteAttachmentUploading({
    required this.allNotes,
    required this.filteredNotes,
    this.filterOption = NoteFilterOption.all,
  });
}

class NoteAttachmentUploadSuccess extends NotesState {
  final String downloadUrl;
  final String type;
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;
  final NoteFilterOption filterOption;

  NoteAttachmentUploadSuccess({
    required this.downloadUrl,
    required this.type,
    required this.allNotes,
    required this.filteredNotes,
    this.filterOption = NoteFilterOption.all,
  });
}

class NoteAttachmentUploadFailure extends NotesState {
  final String message;
  final List<QueryDocumentSnapshot> allNotes;
  final List<QueryDocumentSnapshot> filteredNotes;
  final NoteFilterOption filterOption;

  NoteAttachmentUploadFailure({
    required this.message,
    required this.allNotes,
    required this.filteredNotes,
    this.filterOption = NoteFilterOption.all,
  });
}

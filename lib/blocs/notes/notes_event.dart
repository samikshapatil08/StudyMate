part of 'notes_bloc.dart';

abstract class NotesEvent {}

class NotesSubscriptionRequested extends NotesEvent {}

class NotesAddRequested extends NotesEvent {
  final String title;
  final String content;
  final List<Map<String, dynamic>> attachments;
  
  NotesAddRequested(this.title, this.content, {this.attachments = const []});
}

class NotesUpdateRequested extends NotesEvent {
  final String noteId;
  final String title;
  final String content;
  final List<Map<String, dynamic>> attachments;

  NotesUpdateRequested(this.noteId, this.title, this.content, {this.attachments = const []});
}

class NotesDeleteRequested extends NotesEvent {
  final String noteId;
  NotesDeleteRequested(this.noteId);
}

class NotesSearchChanged extends NotesEvent {
  final String query;
  NotesSearchChanged(this.query);
}

class NotesSortChanged extends NotesEvent {
  final NoteSortOption option;
  NotesSortChanged(this.option);
}

// ✅ NEW: Filter Event
class NotesFilterChanged extends NotesEvent {
  final NoteFilterOption option;
  NotesFilterChanged(this.option);
}

// CLOUDINARY EVENTS
class NotesUploadAttachmentRequested extends NotesEvent {
  final String filePath;
  final String fileType;

  NotesUploadAttachmentRequested({required this.filePath, required this.fileType});
}

class NotesRemoveAttachmentRequested extends NotesEvent {
  final String attachmentUrl;
  NotesRemoveAttachmentRequested(this.attachmentUrl);
}
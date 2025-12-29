part of 'notes_bloc.dart';

abstract class NotesEvent {}

class NotesSubscriptionRequested extends NotesEvent {}

class NotesAddRequested extends NotesEvent {
  final String title;
  final String content;
  NotesAddRequested(this.title, this.content);
}

class NotesUpdateRequested extends NotesEvent {
  final String noteId;
  final String title;
  final String content;
  NotesUpdateRequested(this.noteId, this.title, this.content);
}

class NotesDeleteRequested extends NotesEvent {
  final String noteId;
  NotesDeleteRequested(this.noteId);
}

// 🔍 NEW EVENTS
class NotesSearchChanged extends NotesEvent {
  final String query;
  NotesSearchChanged(this.query);
}

class NotesSortChanged extends NotesEvent {
  final NoteSortOption option;
  NotesSortChanged(this.option);
}
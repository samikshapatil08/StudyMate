part of 'notes_bloc.dart';

enum NoteSortOption { newest, oldest, aToZ, zToA }

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<QueryDocumentSnapshot> allNotes; // Raw data
  final List<QueryDocumentSnapshot> filteredNotes; // UI data
  final String searchQuery;
  final NoteSortOption sortOption;

  NotesLoaded({
    required this.allNotes,
    required this.filteredNotes,
    this.searchQuery = '',
    this.sortOption = NoteSortOption.newest,
  });
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}
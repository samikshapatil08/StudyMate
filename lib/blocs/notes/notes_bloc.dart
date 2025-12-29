import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'notes_event.dart';
part 'notes_state.dart';

// Internal Event
class _NotesUpdated extends NotesEvent {
  final List<QueryDocumentSnapshot> docs;
  _NotesUpdated(this.docs);
}

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _notesSubscription;

  NotesBloc() : super(NotesInitial()) {
    on<NotesSubscriptionRequested>(_onSubscriptionRequested);
    on<NotesAddRequested>(_onAddRequested);
    on<NotesUpdateRequested>(_onUpdateRequested);
    on<NotesDeleteRequested>(_onDeleteRequested);
    on<NotesSearchChanged>(_onSearchChanged);
    on<NotesSortChanged>(_onSortChanged);
    // ✅ FIX: Register the internal event handler
    on<_NotesUpdated>(_onNotesUpdated); 
  }

  String get _uid => _auth.currentUser!.uid;

  Future<void> _onSubscriptionRequested(
      NotesSubscriptionRequested event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    await _notesSubscription?.cancel();
    
    _notesSubscription = _db
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .snapshots()
        .listen((snapshot) {
      // ✅ Pass raw data to internal event
      add(_NotesUpdated(snapshot.docs));
    });
  }

  // ✅ Handler for stream updates
  Future<void> _onNotesUpdated(_NotesUpdated event, Emitter<NotesState> emit) async {
    final currentQuery = state is NotesLoaded ? (state as NotesLoaded).searchQuery : '';
    final currentSort = state is NotesLoaded ? (state as NotesLoaded).sortOption : NoteSortOption.newest;
    
    final filtered = _processList(event.docs, currentQuery, currentSort);
    emit(NotesLoaded(
      allNotes: event.docs, 
      filteredNotes: filtered,
      searchQuery: currentQuery,
      sortOption: currentSort,
    ));
  }

  Future<void> _onSearchChanged(NotesSearchChanged event, Emitter<NotesState> emit) async {
    if (state is NotesLoaded) {
      final loaded = state as NotesLoaded;
      final filtered = _processList(loaded.allNotes, event.query, loaded.sortOption);
      emit(NotesLoaded(
        allNotes: loaded.allNotes,
        filteredNotes: filtered,
        searchQuery: event.query,
        sortOption: loaded.sortOption,
      ));
    }
  }

  Future<void> _onSortChanged(NotesSortChanged event, Emitter<NotesState> emit) async {
    if (state is NotesLoaded) {
      final loaded = state as NotesLoaded;
      final filtered = _processList(loaded.allNotes, loaded.searchQuery, event.option);
      emit(NotesLoaded(
        allNotes: loaded.allNotes,
        filteredNotes: filtered,
        searchQuery: loaded.searchQuery,
        sortOption: event.option,
      ));
    }
  }

  // 🧠 CORE LOGIC: Filter & Sort
  List<QueryDocumentSnapshot> _processList(
    List<QueryDocumentSnapshot> docs, 
    String query, 
    NoteSortOption sort
  ) {
    // 1. Filter
    var list = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final search = query.toLowerCase();
      return title.contains(search) || content.contains(search);
    }).toList();

    // 2. Sort
    list.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      
      switch (sort) {
        case NoteSortOption.aToZ:
          return (dataA['title'] ?? '').toString().compareTo(dataB['title'] ?? '');
        case NoteSortOption.zToA:
          return (dataB['title'] ?? '').toString().compareTo(dataA['title'] ?? '');
        case NoteSortOption.oldest:
          final tA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final tB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return tA.compareTo(tB);
        case NoteSortOption.newest:
          final tA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final tB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return tB.compareTo(tA);
      }
    });

    return list;
  }

  Future<void> _onAddRequested(NotesAddRequested event, Emitter<NotesState> emit) async {
    if (event.title.trim().isEmpty && event.content.trim().isEmpty) return;
    await _db.collection('users').doc(_uid).collection('notes').add({
      'title': event.title,
      'content': event.content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _onUpdateRequested(NotesUpdateRequested event, Emitter<NotesState> emit) async {
    await _db.collection('users').doc(_uid).collection('notes').doc(event.noteId).update({
      'title': event.title,
      'content': event.content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _onDeleteRequested(NotesDeleteRequested event, Emitter<NotesState> emit) async {
    await _db.collection('users').doc(_uid).collection('notes').doc(event.noteId).delete();
  }
}
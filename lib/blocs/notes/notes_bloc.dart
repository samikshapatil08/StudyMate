import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  
  // ☁️ Cloudinary Configuration
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'jb-demo', 
    'notes_preset', 
    cache: false,
  );

  StreamSubscription? _notesSubscription;

  NotesBloc() : super(NotesInitial()) {
    on<NotesSubscriptionRequested>(_onSubscriptionRequested);
    on<NotesAddRequested>(_onAddRequested);
    on<NotesUpdateRequested>(_onUpdateRequested);
    on<NotesDeleteRequested>(_onDeleteRequested);
    on<NotesSearchChanged>(_onSearchChanged);
    on<NotesSortChanged>(_onSortChanged);
    // ✅ Register Filter Handler
    on<NotesFilterChanged>(_onFilterChanged);
    on<_NotesUpdated>(_onNotesUpdated);
    on<NotesUploadAttachmentRequested>(_onUploadAttachmentRequested);
  }

  String get _uid => _auth.currentUser!.uid;

  // --- EXISTING LOGIC ---

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
      add(_NotesUpdated(snapshot.docs));
    });
  }

  Future<void> _onNotesUpdated(_NotesUpdated event, Emitter<NotesState> emit) async {
    String currentQuery = '';
    NoteSortOption currentSort = NoteSortOption.newest;
    NoteFilterOption currentFilter = NoteFilterOption.all; // Default

    if (state is NotesLoaded) {
      final s = state as NotesLoaded;
      currentQuery = s.searchQuery;
      currentSort = s.sortOption;
      currentFilter = s.filterOption;
    }

    final filtered = _processList(event.docs, currentQuery, currentSort, currentFilter);
    emit(NotesLoaded(
      allNotes: event.docs, 
      filteredNotes: filtered,
      searchQuery: currentQuery,
      sortOption: currentSort,
      filterOption: currentFilter,
    ));
  }

  Future<void> _onSearchChanged(NotesSearchChanged event, Emitter<NotesState> emit) async {
    final currentState = _getSafeLoadedState(state);
    if (currentState != null) {
      final filtered = _processList(currentState.allNotes, event.query, currentState.sortOption, currentState.filterOption);
      emit(NotesLoaded(
        allNotes: currentState.allNotes,
        filteredNotes: filtered,
        searchQuery: event.query,
        sortOption: currentState.sortOption,
        filterOption: currentState.filterOption,
      ));
    }
  }

  Future<void> _onSortChanged(NotesSortChanged event, Emitter<NotesState> emit) async {
    final currentState = _getSafeLoadedState(state);
    if (currentState != null) {
      final filtered = _processList(currentState.allNotes, currentState.searchQuery, event.option, currentState.filterOption);
      emit(NotesLoaded(
        allNotes: currentState.allNotes,
        filteredNotes: filtered,
        searchQuery: currentState.searchQuery,
        sortOption: event.option,
        filterOption: currentState.filterOption,
      ));
    }
  }

  // ✅ Handle Filter Change
  Future<void> _onFilterChanged(NotesFilterChanged event, Emitter<NotesState> emit) async {
    final currentState = _getSafeLoadedState(state);
    if (currentState != null) {
      final filtered = _processList(currentState.allNotes, currentState.searchQuery, currentState.sortOption, event.option);
      emit(NotesLoaded(
        allNotes: currentState.allNotes,
        filteredNotes: filtered,
        searchQuery: currentState.searchQuery,
        sortOption: currentState.sortOption,
        filterOption: event.option,
      ));
    }
  }

  // --- CLOUDINARY LOGIC ---

  Future<void> _onUploadAttachmentRequested(
      NotesUploadAttachmentRequested event, Emitter<NotesState> emit) async {
    
    final currentState = _getSafeLoadedState(state);
    if (currentState == null) return; 

    emit(NoteAttachmentUploading(
      allNotes: currentState.allNotes,
      filteredNotes: currentState.filteredNotes
    ));

    try {
      File fileToUpload = File(event.filePath);

      if (event.fileType == 'image') {
        final targetPath = '${event.filePath}_compressed.jpg';
        try {
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            event.filePath,
            targetPath,
            quality: 70, 
          );
          if (compressedFile != null) {
            fileToUpload = File(compressedFile.path);
          }
        } catch (e) {
          debugPrint("Compression failed: $e");
        }
      }

      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          fileToUpload.path, 
          resourceType: CloudinaryResourceType.Auto
        ),
      );

      emit(NoteAttachmentUploadSuccess(
        downloadUrl: response.secureUrl,
        type: event.fileType,
        allNotes: currentState.allNotes,
        filteredNotes: currentState.filteredNotes,
      ));

    } catch (e) {
      debugPrint("Upload Error: $e");
      
      emit(NoteAttachmentUploadFailure(
        message: "Upload failed: $e",
        allNotes: currentState.allNotes,
        filteredNotes: currentState.filteredNotes,
      ));
      
      // Revert to Loaded state
      emit(NotesLoaded(
        allNotes: currentState.allNotes,
        filteredNotes: currentState.filteredNotes,
        // Safe to use defaults or previous if stored, usually fine here
      ));
    }
  }

  // --- CRUD OPERATIONS ---

  Future<void> _onAddRequested(NotesAddRequested event, Emitter<NotesState> emit) async {
    if (event.title.trim().isEmpty && event.content.trim().isEmpty && event.attachments.isEmpty) {
      return;
    }
    
    await _db.collection('users').doc(_uid).collection('notes').add({
      'title': event.title,
      'content': event.content,
      'attachments': event.attachments, 
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _onUpdateRequested(NotesUpdateRequested event, Emitter<NotesState> emit) async {
    await _db.collection('users').doc(_uid).collection('notes').doc(event.noteId).update({
      'title': event.title,
      'content': event.content,
      'attachments': event.attachments,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _onDeleteRequested(NotesDeleteRequested event, Emitter<NotesState> emit) async {
    await _db.collection('users').doc(_uid).collection('notes').doc(event.noteId).delete();
  }

  // --- HELPERS ---

  NotesLoaded? _getSafeLoadedState(NotesState state) {
    if (state is NotesLoaded) return state;
    if (state is NoteAttachmentUploading) {
      return NotesLoaded(allNotes: state.allNotes, filteredNotes: state.filteredNotes);
    }
    if (state is NoteAttachmentUploadSuccess) {
      return NotesLoaded(allNotes: state.allNotes, filteredNotes: state.filteredNotes);
    }
    if (state is NoteAttachmentUploadFailure) {
      return NotesLoaded(allNotes: state.allNotes, filteredNotes: state.filteredNotes);
    }
    return null;
  }

  // 🧠 CORE LOGIC: Filter & Sort
  List<QueryDocumentSnapshot> _processList(
    List<QueryDocumentSnapshot> docs, 
    String query, 
    NoteSortOption sort,
    NoteFilterOption filter, // ✅ Add Filter Param
  ) {
    // 1. Search Query
    var list = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final search = query.toLowerCase();
      return title.contains(search) || content.contains(search);
    }).toList();

    // 2. ✅ Filter (Has Image / Text Only)
    list = list.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final attachments = List<Map<String, dynamic>>.from(data['attachments'] ?? []);
      
      if (filter == NoteFilterOption.hasImage) {
        // Must have at least one image
        return attachments.any((att) => att['type'] == 'image');
      } else if (filter == NoteFilterOption.textOnly) {
        // Must have NO attachments (or strictly no images, usually "Text Only" means clean text)
        return attachments.isEmpty; 
      }
      return true; // All
    }).toList();

    // 3. Sort
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
}
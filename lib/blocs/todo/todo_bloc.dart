import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'todo_event.dart';
part 'todo_state.dart';

// Internal Event
class _TodosUpdated extends TodoEvent {
  final List<QueryDocumentSnapshot> docs;
  _TodosUpdated(this.docs);
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _todoSubscription;

  TodoBloc() : super(TodosInitial()) {
    on<TodosSubscriptionRequested>(_onSubscriptionRequested);
    on<TodoAddRequested>(_onAddRequested);
    on<TodoToggleRequested>(_onToggleRequested);
    on<TodoDeleteRequested>(_onDeleteRequested);
    on<TodoSearchChanged>(_onSearchChanged);
    on<TodoSortChanged>(_onSortChanged);
    on<TodoFilterChanged>(_onFilterChanged);
    // ✅ FIX: Register internal event
    on<_TodosUpdated>(_onTodosUpdated);
  }

  String get _uid => _auth.currentUser!.uid;

  Future<void> _onSubscriptionRequested(
      TodosSubscriptionRequested event, Emitter<TodoState> emit) async {
    emit(TodosLoading());
    await _todoSubscription?.cancel();
    _todoSubscription = _db
        .collection('users')
        .doc(_uid)
        .collection('todos')
        .snapshots()
        .listen((snapshot) {
      add(_TodosUpdated(snapshot.docs));
    });
  }

  // ✅ Handler for stream updates
  Future<void> _onTodosUpdated(_TodosUpdated event, Emitter<TodoState> emit) async {
    String query = '';
    TodoSortOption sort = TodoSortOption.newest;
    TodoFilterStatus filter = TodoFilterStatus.all;

    if (state is TodosLoaded) {
      final s = state as TodosLoaded;
      query = s.searchQuery;
      sort = s.sortOption;
      filter = s.filterStatus;
    }

    final filtered = _processList(event.docs, query, sort, filter);
    emit(TodosLoaded(
      allTodos: event.docs,
      filteredTodos: filtered,
      searchQuery: query,
      sortOption: sort,
      filterStatus: filter,
    ));
  }

  Future<void> _onSearchChanged(TodoSearchChanged event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final s = state as TodosLoaded;
      final filtered = _processList(s.allTodos, event.query, s.sortOption, s.filterStatus);
      emit(TodosLoaded(
        allTodos: s.allTodos,
        filteredTodos: filtered,
        searchQuery: event.query,
        sortOption: s.sortOption,
        filterStatus: s.filterStatus,
      ));
    }
  }

  Future<void> _onSortChanged(TodoSortChanged event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final s = state as TodosLoaded;
      final filtered = _processList(s.allTodos, s.searchQuery, event.option, s.filterStatus);
      emit(TodosLoaded(
        allTodos: s.allTodos,
        filteredTodos: filtered,
        searchQuery: s.searchQuery,
        sortOption: event.option,
        filterStatus: s.filterStatus,
      ));
    }
  }

  Future<void> _onFilterChanged(TodoFilterChanged event, Emitter<TodoState> emit) async {
    if (state is TodosLoaded) {
      final s = state as TodosLoaded;
      final filtered = _processList(s.allTodos, s.searchQuery, s.sortOption, event.status);
      emit(TodosLoaded(
        allTodos: s.allTodos,
        filteredTodos: filtered,
        searchQuery: s.searchQuery,
        sortOption: s.sortOption,
        filterStatus: event.status,
      ));
    }
  }

  // 🧠 CORE LOGIC
  List<QueryDocumentSnapshot> _processList(
    List<QueryDocumentSnapshot> docs,
    String query,
    TodoSortOption sort,
    TodoFilterStatus filter,
  ) {
    // 1. Filter by Status
    var list = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final isDone = data['isDone'] == true;
      if (filter == TodoFilterStatus.completed && !isDone) return false;
      if (filter == TodoFilterStatus.pending && isDone) return false;
      return true;
    }).toList();

    // 2. Filter by Search Query
    if (query.isNotEmpty) {
      list = list.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    }

    // 3. Sort
    list.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      switch (sort) {
        case TodoSortOption.aToZ:
          return (dataA['title'] ?? '').toString().compareTo(dataB['title'] ?? '');
        case TodoSortOption.zToA:
          return (dataB['title'] ?? '').toString().compareTo(dataA['title'] ?? '');
        case TodoSortOption.oldest:
          final tA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final tB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return tA.compareTo(tB);
        case TodoSortOption.newest:
          final tA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final tB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return tB.compareTo(tA);
      }
    });

    return list;
  }

  Future<void> _onAddRequested(TodoAddRequested event, Emitter<TodoState> emit) async {
    if (event.title.trim().isEmpty) return;
    await _db.collection('users').doc(_uid).collection('todos').add({
      'title': event.title,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _onToggleRequested(TodoToggleRequested event, Emitter<TodoState> emit) async {
    await _db.collection('users').doc(_uid).collection('todos').doc(event.todoId).update({
      'isDone': event.value,
    });
  }

  Future<void> _onDeleteRequested(TodoDeleteRequested event, Emitter<TodoState> emit) async {
    await _db.collection('users').doc(_uid).collection('todos').doc(event.todoId).delete();
  }
}
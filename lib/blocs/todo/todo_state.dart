part of 'todo_bloc.dart';

// ✅ RESTORED: 'urgency' sort option
enum TodoSortOption { newest, oldest, aToZ, zToA, urgency }
enum TodoFilterStatus { all, completed, pending }

abstract class TodoState {}

class TodosInitial extends TodoState {}

class TodosLoading extends TodoState {}

class TodosLoaded extends TodoState {
  final List<QueryDocumentSnapshot> allTodos;
  final List<QueryDocumentSnapshot> filteredTodos;
  final String searchQuery;
  final TodoSortOption sortOption;
  final TodoFilterStatus filterStatus;
  // ✅ RESTORED: View State
  final bool isCalendarView;

  TodosLoaded({
    required this.allTodos,
    required this.filteredTodos,
    this.searchQuery = '',
    this.sortOption = TodoSortOption.newest,
    this.filterStatus = TodoFilterStatus.all,
    this.isCalendarView = false,
  });
}

class TodosError extends TodoState {
  final String message;
  TodosError(this.message);
}
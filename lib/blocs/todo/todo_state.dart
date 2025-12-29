part of 'todo_bloc.dart';

enum TodoSortOption { newest, oldest, aToZ, zToA }
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

  TodosLoaded({
    required this.allTodos,
    required this.filteredTodos,
    this.searchQuery = '',
    this.sortOption = TodoSortOption.newest,
    this.filterStatus = TodoFilterStatus.all,
  });
}

class TodosError extends TodoState {
  final String message;
  TodosError(this.message);
}
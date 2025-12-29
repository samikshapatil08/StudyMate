part of 'todo_bloc.dart';

abstract class TodoEvent {}

class TodosSubscriptionRequested extends TodoEvent {}

class TodoAddRequested extends TodoEvent {
  final String title;
  TodoAddRequested(this.title);
}

class TodoToggleRequested extends TodoEvent {
  final String todoId;
  final bool value;
  TodoToggleRequested(this.todoId, this.value);
}

class TodoDeleteRequested extends TodoEvent {
  final String todoId;
  TodoDeleteRequested(this.todoId);
}

// 🔍 NEW EVENTS
class TodoSearchChanged extends TodoEvent {
  final String query;
  TodoSearchChanged(this.query);
}

class TodoSortChanged extends TodoEvent {
  final TodoSortOption option;
  TodoSortChanged(this.option);
}

class TodoFilterChanged extends TodoEvent {
  final TodoFilterStatus status;
  TodoFilterChanged(this.status);
}
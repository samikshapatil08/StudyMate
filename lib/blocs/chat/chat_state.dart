part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<QueryDocumentSnapshot> messages;
  final bool isSending;
  ChatLoaded(this.messages, {this.isSending = false});
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
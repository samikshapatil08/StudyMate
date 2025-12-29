part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatSubscriptionRequested extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String text;
  ChatMessageSent(this.text);
}
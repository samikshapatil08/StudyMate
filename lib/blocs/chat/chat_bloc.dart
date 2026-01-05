import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../gemini_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GeminiService _gemini = GeminiService();

  ChatBloc() : super(ChatInitial()) {
    on<ChatSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatMessageSent>(_onMessageSent);
  }

  String get _uid => _auth.currentUser!.uid;

  Future<void> _onSubscriptionRequested(
      ChatSubscriptionRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await emit.forEach<QuerySnapshot>(
      _db
          .collection('users')
          .doc(_uid)
          .collection('chats')
          .orderBy('timestamp')
          .snapshots(),
      onData: (snapshot) {
        bool isSending = false;
        if (state is ChatLoaded) {
          isSending = (state as ChatLoaded).isSending;
        }
        return ChatLoaded(snapshot.docs, isSending: isSending);
      },
      onError: (error, stackTrace) => ChatError("Failed to load chat"),
    );
  }

  Future<void> _onMessageSent(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    List<QueryDocumentSnapshot> currentMsgs = [];
    if (state is ChatLoaded) {
      currentMsgs = (state as ChatLoaded).messages;
    }
    emit(ChatLoaded(currentMsgs, isSending: true));

    try {
      await _db.collection('users').doc(_uid).collection('chats').add({
        'role': 'user',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final reply = await _gemini.getResponse(text);

      await _db.collection('users').doc(_uid).collection('chats').add({
        'role': 'model',
        'text': reply,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (state is ChatLoaded) {
        currentMsgs = (state as ChatLoaded).messages;
      }
      emit(ChatLoaded(currentMsgs, isSending: false));
    } catch (e) {
      emit(ChatError("Failed to send message"));
    }
  }
}

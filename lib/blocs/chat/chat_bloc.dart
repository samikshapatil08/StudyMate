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
        // Preserve isSending state if we were already in ChatLoaded
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

    // 1. Update UI to sending state (keep existing messages)
    List<QueryDocumentSnapshot> currentMsgs = [];
    if (state is ChatLoaded) {
      currentMsgs = (state as ChatLoaded).messages;
    }
    emit(ChatLoaded(currentMsgs, isSending: true));

    try {
      // 2. Save user message
      await _db.collection('users').doc(_uid).collection('chats').add({
        'role': 'user',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Call Gemini
      final reply = await _gemini.getResponse(text);

      // 4. Save AI response
      await _db.collection('users').doc(_uid).collection('chats').add({
        'role': 'model',
        'text': reply,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // 5. Turn off isSending (Stream will update the messages list automatically)
      // We assume the stream listener (onSubscriptionRequested) will fire with new data
      // but we need to reset the flag manually here if the stream doesn't emit immediately, 
      // though typically Firestore streams are fast. 
      // However, to be safe, we rely on the stream emission to carry the new data.
      // We just need to ensure the next state emission has isSending: false.
      // Since stream listener runs independently, we can't easily "inject" false there 
      // without storing it in a variable.
      // In BLoC, we can't easily modify the state emitted by the stream subscription handler from here.
      // TRICK: We don't need to emit here if the stream updates. 
      // BUT we need to clear `isSending`. 
      // Since `isSending` is UI state not DB state, we MUST emit.
      
      // Let's refetch current messages from state to be safe
      if (state is ChatLoaded) {
         currentMsgs = (state as ChatLoaded).messages;
       }
       emit(ChatLoaded(currentMsgs, isSending: false));

    } catch (e) {
      emit(ChatError("Failed to send message"));
    }
  }
}
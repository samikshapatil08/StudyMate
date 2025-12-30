import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../blocs/chat/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(ChatMessageSent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
            top: 5,
            bottom: 55,
          ),
          child: Column(
            children: [
              /// 🔹 CHAT HISTORY
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading || state is ChatInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state is ChatError) {
                      return Center(child: Text(state.message, style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
                    }

                    final docs = (state as ChatLoaded).messages;
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final msg = docs[index];
                        final isUser = msg['role'] == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppTheme.accentGreen // ✅ Keep Brand Color
                                  : AppTheme.secondaryBlue, // ✅ Keep Brand Color
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text'],
                              style: GoogleFonts.inter(
                                color: AppTheme.textOnColor, // ✅ Always White
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// 🔹 TYPING INDICATOR
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  bool isSending = false;
                  if (state is ChatLoaded) {
                    isSending = state.isSending;
                  }
                  if (isSending) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text("Gemini is typing...", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              /// 🔹 INPUT BAR
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor, // ✅ Dynamic
                  borderRadius: BorderRadius.circular(40),
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color), // ✅ Input Color
                        decoration: const InputDecoration(
                          hintText: "Ask anything...",
                          hintStyle: TextStyle(color: AppTheme.accentGreen),
                          border: InputBorder.none,
                        ),
                        cursorColor: AppTheme.accentGreen,
                      ),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        bool isSending = false;
                        if (state is ChatLoaded) {
                          isSending = state.isSending;
                        }
                        return IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppTheme.accentGreen,
                          ),
                          onPressed: isSending ? null : _sendMessage,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
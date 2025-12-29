import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/notes/notes_bloc.dart';
import '../blocs/todo/todo_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import 'chat_screen.dart';
import 'login.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    NotesScreen(),
    TodoScreen(),
    ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data streams when Home loads
    context.read<NotesBloc>().add(NotesSubscriptionRequested());
    context.read<TodoBloc>().add(TodosSubscriptionRequested());
    context.read<ChatBloc>().add(ChatSubscriptionRequested());
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "StudyMate",
            style: GoogleFonts.poppins(color: AppTheme.primaryPurple),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        extendBody: true,

        /// 🌟 Custom Floating Bottom Navigation
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: "Home",
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
                ),
                _NavItem(
                  icon: Icons.check_circle,
                  label: "To-Dos",
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
                ),
                _NavItem(
                  icon: Icons.chat_bubble,
                  label: "Chat",
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onTap: _onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  bool get isActive => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
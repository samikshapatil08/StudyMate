import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/notes/notes_bloc.dart';
import '../blocs/todo/todo_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/theme/theme_bloc.dart';
import 'chat_screen.dart';
import 'login.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';
import 'fun/fun_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NotesScreen(),
    const TodoScreen(),
    const ChatScreen(),
    const FunHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ThemeBloc>().add(ThemeLoadRequested(authState.uid));
    }

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
    final theme = Theme.of(context);

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
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            "StudyMate",
            style: GoogleFonts.poppins(
                color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final isDark = state.themeMode == ThemeMode.dark;
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  color: theme.iconTheme.color,
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context
                          .read<ThemeBloc>()
                          .add(ThemeToggleRequested(authState.uid));
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: theme.iconTheme.color,
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  height: 64,
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                          icon: Icons.edit_outlined,
                          label: "Notes",
                          index: 0,
                          selectedIndex: _selectedIndex,
                          onTap: _onTap),
                      _NavItem(
                          icon: Icons.check_circle_outline,
                          label: "To-Do",
                          index: 1,
                          selectedIndex: _selectedIndex,
                          onTap: _onTap),
                      _NavItem(
                          icon: Icons.chat_bubble_outline,
                          label: "Chat",
                          index: 2,
                          selectedIndex: _selectedIndex,
                          onTap: _onTap),
                      _NavItem(
                          icon: Icons.celebration_outlined,
                          label: "Fun",
                          index: 3,
                          selectedIndex: _selectedIndex,
                          onTap: _onTap),
                    ],
                  ),
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final inactiveColor = theme.brightness == Brightness.dark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? Colors.white : inactiveColor,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
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

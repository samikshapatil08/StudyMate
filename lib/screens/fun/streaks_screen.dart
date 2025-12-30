import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../blocs/fun/streaks/streaks_bloc.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Trigger data fetch on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreaksBloc>().add(StreaksSubscriptionRequested());
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Daily Streaks"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: Center(
        child: BlocBuilder<StreaksBloc, StreaksState>(
          builder: (context, state) {
            if (state is StreaksLoading || state is StreaksInitial) {
              return const CircularProgressIndicator();
            }
            
            int streak = 0;
            if (state is StreaksLoaded) {
              streak = state.currentStreak;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, size: 100, color: AppTheme.accentRed),
                const SizedBox(height: 20),
                Text(
                  "$streak Days",
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Current Streak",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Keep completing tasks daily to increase your streak!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
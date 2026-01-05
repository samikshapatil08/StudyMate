import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../blocs/fun/timer/timer_bloc.dart';

class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Focus Timer"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              final duration = state.duration;
              final minutesStr =
                  ((duration / 60) % 60).floor().toString().padLeft(2, '0');
              final secondsStr =
                  (duration % 60).floor().toString().padLeft(2, '0');

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$minutesStr:$secondsStr',
                    style: GoogleFonts.inter(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (state is TimerInitial) ...[
                    FloatingActionButton(
                      heroTag: "start",
                      backgroundColor: AppTheme.primaryPurple,
                      onPressed: () => context
                          .read<TimerBloc>()
                          .add(TimerStarted(duration: state.duration)),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                  if (state is TimerRunInProgress) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          heroTag: "pause",
                          backgroundColor: AppTheme.secondaryBlue,
                          onPressed: () =>
                              context.read<TimerBloc>().add(TimerPaused()),
                          child: const Icon(Icons.pause, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: "reset",
                          backgroundColor: Colors.grey,
                          onPressed: () =>
                              context.read<TimerBloc>().add(TimerReset()),
                          child: const Icon(Icons.replay, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                  if (state is TimerRunPause) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          heroTag: "resume",
                          backgroundColor: AppTheme.primaryPurple,
                          onPressed: () =>
                              context.read<TimerBloc>().add(TimerResumed()),
                          child:
                              const Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: "reset",
                          backgroundColor: Colors.grey,
                          onPressed: () =>
                              context.read<TimerBloc>().add(TimerReset()),
                          child: const Icon(Icons.replay, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                  if (state is TimerRunComplete) ...[
                    Column(
                      children: [
                        Text(
                          "Focus Session Complete! 🎉",
                          style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 20),
                        FloatingActionButton(
                          heroTag: "reset",
                          backgroundColor: Colors.grey,
                          onPressed: () =>
                              context.read<TimerBloc>().add(TimerReset()),
                          child: const Icon(Icons.replay, color: Colors.white),
                        ),
                      ],
                    )
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

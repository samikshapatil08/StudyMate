import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../blocs/fun/fact/fact_bloc.dart';

class FactScreen extends StatelessWidget {
  const FactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FactBloc>().state is FactInitial) {
        context.read<FactBloc>().add(FactRequested());
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Useless Fact"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<FactBloc, FactState>(
                builder: (context, state) {
                  if (state is FactLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is FactLoaded) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10, 
                            color: Colors.black.withValues(alpha: 0.12)
                          )
                        ],
                      ),
                      child: Text(
                        state.fact,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18, 
                          height: 1.5,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  } else if (state is FactError) {
                    return Text(state.message, style: const TextStyle(color: Colors.red));
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => context.read<FactBloc>().add(FactRequested()),
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text("Next Fact"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
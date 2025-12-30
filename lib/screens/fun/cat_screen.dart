import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../blocs/fun/cat/cat_bloc.dart';

class CatScreen extends StatelessWidget {
  const CatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fetch initial cat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CatBloc>().state is CatInitial) {
        context.read<CatBloc>().add(CatImageRequested());
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Random Cat"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.12))
                  ],
                ),
                child: BlocBuilder<CatBloc, CatState>(
                  builder: (context, state) {
                    if (state is CatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CatLoaded) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(state.imageUrl, fit: BoxFit.cover),
                      );
                    } else if (state is CatError) {
                      return Center(
                        child: Text(
                          state.message, 
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        "Ready for cats?",
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => context.read<CatBloc>().add(CatImageRequested()),
                icon: const Icon(Icons.refresh),
                label: const Text("New Cat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
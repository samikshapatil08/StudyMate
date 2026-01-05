import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'screens/splash.dart';
import 'theme.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/notes/notes_bloc.dart';
import 'blocs/todo/todo_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/fun/timer/timer_bloc.dart';
import 'blocs/fun/cat/cat_bloc.dart';
import 'blocs/fun/fact/fact_bloc.dart';
import 'blocs/fun/streaks/streaks_bloc.dart';
import 'blocs/theme/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => NotesBloc()),
        BlocProvider(create: (_) => TodoBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => TimerBloc()),
        BlocProvider(create: (_) => CatBloc()),
        BlocProvider(create: (_) => FactBloc()),
        BlocProvider(create: (_) => StreaksBloc()),
        BlocProvider(create: (_) => ThemeBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'StudyMate',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

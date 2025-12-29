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
//import 'package:cloudinary_flutter/cloudinary_context.dart';
//import 'package:cloudinary_flutter/image/cld_image.dart';
//import 'package:cloudinary_url_gen/cloudinary.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ThemeBloc() : super(ThemeState(ThemeMode.light)) {
    on<ThemeLoadRequested>(_onLoadRequested);
    on<ThemeToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
      ThemeLoadRequested event, Emitter<ThemeState> emit) async {
    try {
      final doc = await _db.collection('users').doc(event.uid).get();
      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('isDarkMode')) {
        final isDark = doc.data()!['isDarkMode'] as bool;
        emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
      } else {
        emit(ThemeState(ThemeMode.light));
      }
    } catch (_) {
      emit(ThemeState(ThemeMode.light));
    }
  }

  Future<void> _onToggleRequested(
      ThemeToggleRequested event, Emitter<ThemeState> emit) async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final isDark = newMode == ThemeMode.dark;

    emit(ThemeState(newMode));

    try {
      await _db.collection('users').doc(event.uid).set(
        {'isDarkMode': isDark},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}

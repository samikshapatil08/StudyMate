part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ThemeLoadRequested extends ThemeEvent {
  final String uid;
  ThemeLoadRequested(this.uid);
}

class ThemeToggleRequested extends ThemeEvent {
  final String uid;
  ThemeToggleRequested(this.uid);
}
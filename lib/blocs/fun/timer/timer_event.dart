part of 'timer_bloc.dart';

abstract class TimerEvent {}

class TimerStarted extends TimerEvent {
  final int duration;
  TimerStarted({required this.duration});
}

class TimerPaused extends TimerEvent {}
class TimerResumed extends TimerEvent {}
class TimerReset extends TimerEvent {}
class _TimerTicked extends TimerEvent {
  final int duration;
  _TimerTicked({required this.duration});
}
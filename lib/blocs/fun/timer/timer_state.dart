part of 'timer_bloc.dart';

abstract class TimerState {
  final int duration;
  const TimerState(this.duration);
}

class TimerInitial extends TimerState {
  const TimerInitial(super.duration);
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(super.duration);
}

class TimerRunPause extends TimerState {
  const TimerRunPause(super.duration);
}

class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}
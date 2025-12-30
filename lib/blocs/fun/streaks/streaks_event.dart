part of 'streaks_bloc.dart';

abstract class StreaksEvent {}
class StreaksSubscriptionRequested extends StreaksEvent {}
class _StreaksUpdated extends StreaksEvent {
  final int streakCount;
  _StreaksUpdated(this.streakCount);
}
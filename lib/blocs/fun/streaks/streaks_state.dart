part of 'streaks_bloc.dart';

abstract class StreaksState {}
class StreaksInitial extends StreaksState {}
class StreaksLoading extends StreaksState {}
class StreaksLoaded extends StreaksState {
  final int currentStreak;
  StreaksLoaded(this.currentStreak);
}
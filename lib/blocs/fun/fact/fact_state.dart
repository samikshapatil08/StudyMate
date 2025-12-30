part of 'fact_bloc.dart';

abstract class FactState {}
class FactInitial extends FactState {}
class FactLoading extends FactState {}
class FactLoaded extends FactState {
  final String fact;
  FactLoaded(this.fact);
}
class FactError extends FactState {
  final String message;
  FactError(this.message);
}
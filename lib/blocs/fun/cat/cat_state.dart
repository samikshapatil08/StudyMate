
part of 'cat_bloc.dart';

abstract class CatState {}
class CatInitial extends CatState {}
class CatLoading extends CatState {}
class CatLoaded extends CatState {
  final String imageUrl;
  CatLoaded(this.imageUrl);
}
class CatError extends CatState {
  final String message;
  CatError(this.message);
}
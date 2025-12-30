import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part 'cat_event.dart';
part 'cat_state.dart';

class CatBloc extends Bloc<CatEvent, CatState> {
  CatBloc() : super(CatInitial()) {
    on<CatImageRequested>(_onCatImageRequested);
  }

  Future<void> _onCatImageRequested(CatImageRequested event, Emitter<CatState> emit) async {
    emit(CatLoading());
    try {
      final response = await http.get(Uri.parse('https://api.thecatapi.com/v1/images/search'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          emit(CatLoaded(data[0]['url']));
        } else {
          emit(CatError("No cats found 😿"));
        }
      } else {
        emit(CatError("Failed to fetch cat"));
      }
    } catch (e) {
      emit(CatError("Network error: $e"));
    }
  }
}
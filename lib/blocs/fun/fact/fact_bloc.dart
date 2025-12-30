import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part 'fact_event.dart';
part 'fact_state.dart';

class FactBloc extends Bloc<FactEvent, FactState> {
  FactBloc() : super(FactInitial()) {
    on<FactRequested>(_onFactRequested);
  }

  Future<void> _onFactRequested(FactRequested event, Emitter<FactState> emit) async {
    emit(FactLoading());
    try {
      final response = await http.get(Uri.parse('https://uselessfacts.jsph.pl/api/v2/facts/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(FactLoaded(data['text']));
      } else {
        emit(FactError("Failed to learn something useless"));
      }
    } catch (e) {
      emit(FactError("Network error: $e"));
    }
  }
}
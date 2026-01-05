import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'streaks_event.dart';
part 'streaks_state.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _streaksSubscription;

  StreaksBloc() : super(StreaksInitial()) {
    on<StreaksSubscriptionRequested>(_onSubscriptionRequested);
    on<_StreaksUpdated>(
        (event, emit) => emit(StreaksLoaded(event.streakCount)));
  }

  Future<void> _onSubscriptionRequested(
      StreaksSubscriptionRequested event, Emitter<StreaksState> emit) async {
    emit(StreaksLoading());
    await _streaksSubscription?.cancel();

    final uid = _auth.currentUser!.uid;

    _streaksSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .where('isDone', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final completedDates = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final timestamp = data['createdAt'] as Timestamp;
            final date = timestamp.toDate();
            return DateTime(date.year, date.month, date.day);
          })
          .toSet()
          .toList();

      completedDates.sort((a, b) => b.compareTo(a));

      int streak = 0;
      if (completedDates.isEmpty) {
        add(_StreaksUpdated(0));
        return;
      }

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      if (completedDates.first.isAtSameMomentAs(todayDate) ||
          completedDates.first.isAtSameMomentAs(yesterdayDate)) {
        streak = 1;
        DateTime checkDate =
            completedDates.first.subtract(const Duration(days: 1));

        for (int i = 1; i < completedDates.length; i++) {
          if (completedDates[i].isAtSameMomentAs(checkDate)) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }

      add(_StreaksUpdated(streak));
    });
  }

  @override
  Future<void> close() {
    _streaksSubscription?.cancel();
    return super.close();
  }
}

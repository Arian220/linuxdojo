import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/domain/review_state.dart';
import 'package:linuxdojo/features/study/domain/sm2_engine.dart';

class ReviewRepository {
  ReviewRepository(this._database, {this.engine = const Sm2Engine()});

  final AppDatabase _database;
  final Sm2Engine engine;

  Future<ReviewState?> getState(int cardId) async {
    final query = _database.select(_database.reviews)
      ..where((review) => review.cardId.equals(cardId));
    final review = await query.getSingleOrNull();
    return review == null ? null : _toState(review);
  }

  Stream<ReviewState?> watchState(int cardId) {
    final query = _database.select(_database.reviews)
      ..where((review) => review.cardId.equals(cardId));
    return query.watchSingleOrNull().map(
      (review) => review == null ? null : _toState(review),
    );
  }

  Future<ReviewState> applyGrade({
    required int cardId,
    required ReviewGrade grade,
    DateTime? reviewedAt,
  }) async {
    final now = reviewedAt ?? DateTime.now();
    final current = await getState(cardId) ?? ReviewState.initial(now);
    final next = engine.schedule(
      current: current,
      grade: grade,
      reviewedAt: now,
    );

    await _database
        .into(_database.reviews)
        .insertOnConflictUpdate(
          ReviewsCompanion.insert(
            cardId: Value(cardId),
            interval: Value(next.interval),
            easeFactor: Value(next.easeFactor),
            repetitions: Value(next.repetitions),
            nextReview: next.nextReview,
            lastReview: Value(next.lastReview),
          ),
        );

    return next;
  }

  ReviewState _toState(Review review) {
    return ReviewState(
      interval: review.interval,
      easeFactor: review.easeFactor,
      repetitions: review.repetitions,
      nextReview: review.nextReview,
      lastReview: review.lastReview,
    );
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(appDatabaseProvider));
});

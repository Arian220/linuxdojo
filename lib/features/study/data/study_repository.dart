import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

class StudyRepository {
  const StudyRepository(this._database);

  final AppDatabase _database;

  Future<List<CardEntry>> getDueCards({DateTime? at}) async {
    final rows = await _dueCardsQuery(at).get();
    return rows
        .map((row) => row.readTable(_database.cards))
        .toList(growable: false);
  }

  Stream<List<CardEntry>> watchDueCards({DateTime? at}) {
    return _dueCardsQuery(at).watch().map(
      (rows) => rows
          .map((row) => row.readTable(_database.cards))
          .toList(growable: false),
    );
  }

  Future<int> countDueCards({DateTime? at}) async {
    final count = _database.reviews.cardId.count();
    final query = _database.selectOnly(_database.reviews)
      ..addColumns([count])
      ..where(
        _database.reviews.nextReview.isSmallerOrEqualValue(
          at ?? DateTime.now(),
        ),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<Review?> getReview(int cardId) {
    final query = _database.select(_database.reviews)
      ..where((review) => review.cardId.equals(cardId));
    return query.getSingleOrNull();
  }

  Selectable<TypedResult> _dueCardsQuery(DateTime? at) {
    final query =
        _database.select(_database.cards).join([
          innerJoin(
            _database.reviews,
            _database.reviews.cardId.equalsExp(_database.cards.id),
          ),
        ])..where(
          _database.reviews.nextReview.isSmallerOrEqualValue(
            at ?? DateTime.now(),
          ),
        );
    return query;
  }
}

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepository(ref.watch(appDatabaseProvider));
});

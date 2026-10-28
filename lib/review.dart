/// A tiny Leitner system: koans the learner struggled with come back for
/// review at growing intervals until they are answered right the first time
/// often enough to graduate.
library;

class ReviewCard {
  const ReviewCard({required this.box, required this.due});

  /// How many reviews in a row went right; also picks the next interval.
  final int box;
  final DateTime due;

  Map<String, Object> toJson() => {'box': box, 'due': due.millisecondsSinceEpoch};

  static ReviewCard fromJson(Map<String, Object?> json) => ReviewCard(
        box: json['box'] as int,
        due: DateTime.fromMillisecondsSinceEpoch(json['due'] as int),
      );
}

class ReviewQueue {
  ReviewQueue([Map<String, ReviewCard>? cards]) : cards = cards ?? {};

  /// When a card in each box comes back. Passing the last box graduates it.
  static const intervals = [
    Duration(minutes: 10),
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 21),
  ];

  /// Koans answered with this many misses, or revealed, need review.
  static const struggleThreshold = 2;

  final Map<String, ReviewCard> cards;

  /// Starts (or restarts) reviewing [key].
  void struggled(String key, DateTime now) =>
      cards[key] = ReviewCard(box: 0, due: now.add(intervals.first));

  /// Records a review: right first time moves the card along, otherwise it
  /// starts over.
  void reviewed(String key, {required bool firstTry, required DateTime now}) {
    final card = cards[key];
    if (card == null) return;
    if (!firstTry) {
      struggled(key, now);
      return;
    }
    final box = card.box + 1;
    if (box >= intervals.length) {
      cards.remove(key);
    } else {
      cards[key] = ReviewCard(box: box, due: now.add(intervals[box]));
    }
  }

  /// Keys due now under [prefix] (a Way, e.g. `dart/`), soonest first.
  List<String> due(String prefix, DateTime now) {
    final keys = [
      for (final MapEntry(:key, :value) in cards.entries)
        if (key.startsWith(prefix) && !value.due.isAfter(now)) key,
    ];
    keys.sort((a, b) => cards[a]!.due.compareTo(cards[b]!.due));
    return keys;
  }

  int pending(String prefix) => cards.keys.where((k) => k.startsWith(prefix)).length;

  /// When the next card under [prefix] comes due, if any.
  DateTime? nextDue(String prefix) {
    DateTime? next;
    for (final MapEntry(:key, :value) in cards.entries) {
      if (key.startsWith(prefix) && (next == null || value.due.isBefore(next))) next = value.due;
    }
    return next;
  }

  Map<String, Object> toJson() => {for (final e in cards.entries) e.key: e.value.toJson()};

  static ReviewQueue fromJson(Map<String, Object?> json) => ReviewQueue({
        for (final e in json.entries) e.key: ReviewCard.fromJson((e.value as Map).cast<String, Object?>()),
      });
}

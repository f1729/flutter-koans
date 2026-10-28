import 'package:flutter_koans/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 9);

  test('a struggled koan comes back after ten minutes', () {
    final q = ReviewQueue()..struggled('dart/maps/3', t0);
    expect(q.due('dart/', t0), isEmpty);
    expect(q.due('dart/', t0.add(const Duration(minutes: 10))), ['dart/maps/3']);
    expect(q.due('flutter/', t0.add(const Duration(days: 1))), isEmpty);
  });

  test('right first time moves along, until it graduates', () {
    final q = ReviewQueue()..struggled('k', t0);
    var now = t0;
    for (var i = 1; i < ReviewQueue.intervals.length; i++) {
      now = q.cards['k']!.due;
      q.reviewed('k', firstTry: true, now: now);
      expect(q.cards['k']!.box, i);
    }
    q.reviewed('k', firstTry: true, now: q.cards['k']!.due);
    expect(q.cards, isEmpty);
  });

  test('a miss starts over', () {
    final q = ReviewQueue()..struggled('k', t0);
    q.reviewed('k', firstTry: true, now: t0);
    q.reviewed('k', firstTry: false, now: t0);
    expect(q.cards['k']!.box, 0);
  });

  test('round-trips through JSON', () {
    final q = ReviewQueue()..struggled('a', t0)..struggled('b', t0.add(const Duration(hours: 1)));
    final back = ReviewQueue.fromJson(q.toJson());
    expect(back.due('', t0.add(const Duration(days: 1))), ['a', 'b']);
  });
}

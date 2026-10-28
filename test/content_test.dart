import 'package:flutter/material.dart';
import 'package:flutter_koans/content/ways.dart';
import 'package:flutter_koans/engine/evaluator.dart';
import 'package:flutter_koans/engine/koan.dart';
import 'package:flutter_koans/engine/parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deep equality that also tells ints from doubles, as the VM does.
bool strictEquals(Object? a, Object? b) {
  if (a is num && b is num) return a.runtimeType == b.runtimeType && a == b;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!strictEquals(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Set && b is Set) {
    return a.length == b.length && a.every((x) => b.any((y) => strictEquals(x, y)));
  }
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((k) => b.containsKey(k) && strictEquals(a[k], b[k]));
  }
  return a == b;
}

void main() {
  for (final way in ways) {
    group(way.id, () {
      test('has unique category ids', () {
        final ids = way.categories.map((c) => c.id).toList();
        expect(ids.toSet().length, ids.length);
      });

      for (final category in way.categories) {
        group(category.id, () {
          test('has translated title and intro', () {
            for (final t in [category.title, category.intro]) {
              expect(t.en.trim(), isNotEmpty);
              expect(t.id.trim(), isNotEmpty);
            }
          });

          for (final (i, koan) in category.koans.indexed) {
            group('#${i + 1}', () {
              test('is well formed', () {
                expect(koan.prompt.en.trim(), isNotEmpty);
                expect(koan.prompt.id.trim(), isNotEmpty);
                if (koan.hint case final hint?) {
                  expect(hint.en.trim(), isNotEmpty);
                  expect(hint.id.trim(), isNotEmpty);
                }
                expect(koan.blankCount, koan.answers.length,
                    reason: 'one answer per blank');
              });

              test('explains itself', () {
                final why = koan.explanation;
                expect(why, isNotNull, reason: 'every koan needs an explanation');
                expect(why!.en.trim(), isNotEmpty);
                expect(why.id.trim(), isNotEmpty);
                if (koan.docs case final docs?) {
                  expect(docs, startsWith('https://'));
                }
              });

              test('anticipates real mistakes', () {
                for (final m in koan.mistakes) {
                  expect(m.answers.length, koan.blankCount);
                  expect(m.answers.any((a) => a != null), isTrue);
                  expect(m.why.en.trim(), isNotEmpty);
                  expect(m.why.id.trim(), isNotEmpty);
                  final inputs = [
                    for (final (j, a) in m.answers.indexed) a ?? koan.answers[j],
                  ];
                  final result = koan.check(inputs);
                  expect(result.outcome, KoanOutcome.wrong,
                      reason: '$inputs must be a wrong answer');
                  expect(identical(result.mistake, m), isTrue,
                      reason: '$inputs is caught by an earlier mistake');
                }
              });

              if (koan.capstone) {
                test('is a capstone at the end of its category', () {
                  expect(identical(category.koans.last, koan), isTrue);
                  expect(koan.blankCount, greaterThanOrEqualTo(2));
                });
              }

              test('accepts its answers', () {
                expect(koan.check(koan.answers).outcome, KoanOutcome.solved);
              });

              test('tells int from double', () {
                // Swapping 3 for 3.0 is "almost", never "solved".
                final swapped = [
                  for (final a in koan.answers)
                    RegExp(r'^-?\d+$').hasMatch(a)
                        ? '$a.0'
                        : RegExp(r'^-?\d+\.0$').hasMatch(a)
                            ? a.substring(0, a.length - 2)
                            : a,
                ];
                if (koan.accept != null || swapped.join() == koan.answers.join()) return;
                expect(koan.check(swapped).outcome, KoanOutcome.numberKind);
              });

              test('rejects empty blanks', () {
                final empty = List.filled(koan.blankCount, '');
                expect(koan.check(empty).outcome, isNot(KoanOutcome.solved));
              });

              if (koan.verify != null) {
                test('answers match what Dart computes', () async {
                  final registry = Registry.core.merge(koan.registry);
                  final actual = await koan.verify!();
                  expect(actual.length, koan.answers.length);
                  for (var j = 0; j < actual.length; j++) {
                    final typed = evaluate(parseAnswer(koan.answers[j]), registry);
                    expect(strictEquals(typed, actual[j]), isTrue,
                        reason: 'blank ${j + 1}: answer ${koan.answers[j]} '
                            'but Dart says ${actual[j]}');
                  }
                });
              }

              if (koan.preview != null) {
                testWidgets('previews its answer', (tester) async {
                  final values = koan.valuesFor(koan.answers);
                  expect(values, isNotNull);
                  await tester.pumpWidget(MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: SizedBox(
                          width: 320,
                          height: 240,
                          child: koan.preview!(values!),
                        ),
                      ),
                    ),
                  ));
                  expect(tester.takeException(), isNull);
                });
              }
            });
          }
        });
      }
    });
  }
}

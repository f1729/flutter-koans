import 'package:flutter_koans/content/flutter/registry.dart';
import 'package:flutter_koans/content/ways.dart';
import 'package:flutter_koans/engine/completion.dart';
import 'package:flutter_koans/engine/koan.dart';
import 'package:flutter_koans/engine/parser.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> labels(List<Completion> cs) => [for (final c in cs) c.label];

Koan koan(String code, List<String> answers, {Registry registry = Registry.core}) =>
    Koan(prompt: const Tr('', ''), code: code, answers: answers, registry: registry);

void main() {
  test('an enum value suggests its siblings, in declaration order', () {
    final cs = completionsFor(
        koan('Row(mainAxisAlignment: __)', ['MainAxisAlignment.center'], registry: flutterRegistry), 0);
    expect(labels(cs), [for (final v in ['start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly']) 'MainAxisAlignment.$v']);
  });

  test('a constructor suggests templates for its type', () {
    final cs = completionsFor(koan('padding: __', ['EdgeInsets.all(24)'], registry: flutterRegistry), 0);
    expect(labels(cs), ['EdgeInsets.zero', 'EdgeInsets.all', 'EdgeInsets.symmetric', 'EdgeInsets.only', 'EdgeInsets.fromLTRB']);
    final all = cs[1];
    expect(all.text, 'EdgeInsets.all()');
    expect(all.caret, 'EdgeInsets.all('.length);
    expect(all.previewText, 'EdgeInsets.all(16)');
  });

  test('keywords depend on what follows the blank', () {
    expect(labels(completionsFor(koan('__ class Light {}', ['sealed']), 0)), contains('abstract'));
    expect(labels(completionsFor(koan('__ name = 1;', ['final']), 0)), containsAll(['var', 'const', 'late']));
  });

  test('members depend on the receiver', () {
    expect(labels(completionsFor(koan("'  calm '.__()", ['trim']), 0)), contains('toUpperCase'));
    expect(labels(completionsFor(koan('[1, 2].__((x) => x)', ['map']), 0)), contains('where'));
    expect(labels(completionsFor(koan('{1}.__({2})', ['union']), 0)), contains('difference'));
  });

  test('plain values get no suggestions', () {
    for (final a in ['3', '3.0', "'koan'", '[1, 2]', '{1: 2}', 'null', '(1, 2)']) {
      expect(completionsFor(koan('expect(x, __);', [a]), 0), isEmpty, reason: a);
    }
    expect(labels(completionsFor(koan('expect(x, __);', ['true']), 0)), ['true', 'false']);
  });

  test('filter matches the whole name or its last part', () {
    final cs = completionsForPrefix('MainAxisAlignment', flutterRegistry);
    expect(labels(filterCompletions(cs, 'spa')).length, 3);
    expect(labels(filterCompletions(cs, 'MainAxisAlignment.ce')), ['MainAxisAlignment.center']);
    expect(filterCompletions(cs, 'zzz'), isEmpty);
  });

  test('every named answer in the content can be found by suggestion', () {
    final missing = <String>[];
    for (final way in ways) {
      for (final category in way.categories) {
        for (final (i, k) in category.koans.indexed) {
          for (var b = 0; b < k.blankCount; b++) {
            final answer = parseAnswer(k.answers[b]);
            if (answer is! IdentNode && answer is! CallNode && answer is! BoolNode) continue;
            final name = answer is CallNode ? answer.name : k.answers[b];
            final cs = completionsFor(k, b);
            if (!cs.any((c) => c.label == name)) {
              missing.add('${way.id}/${category.id}/${i + 1} blank ${b + 1}: $name');
            }
          }
        }
      }
    }
    expect(missing, isEmpty);
  });
}

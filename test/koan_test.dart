import 'package:flutter_koans/content/flutter/registry.dart';
import 'package:flutter_koans/engine/koan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wrongList = Mistake(['true'], Tr('Lists compare by identity.', 'List dibandingkan berdasarkan identitas.'));
  final koan = Koan(
    prompt: const Tr('', ''),
    code: 'expect([1] == [1], __);',
    answers: ['false'],
    mistakes: const [wrongList],
  );

  test('a known wrong answer carries its explanation', () {
    expect(koan.check(['true']).mistake, same(wrongList));
    expect(koan.check(['null']).mistake, isNull);
    expect(koan.check(['false']).outcome, KoanOutcome.solved);
  });

  test('dot shorthand resolves against the expected type', () {
    final fit = Koan(
      prompt: const Tr('', ''),
      code: 'Flexible(fit: __)',
      answers: ['FlexFit.tight'],
      registry: flutterRegistry,
    );
    expect(fit.check(['.tight']).outcome, KoanOutcome.solved);
    expect(fit.check(['.loose']).outcome, KoanOutcome.wrong);
    expect(fit.valuesFor(['.loose']), isNotNull);

    final padding = Koan(
      prompt: const Tr('', ''),
      code: 'Padding(padding: __)',
      answers: ['EdgeInsets.all(24)'],
      registry: flutterRegistry,
    );
    expect(padding.check(['.all(24)']).outcome, KoanOutcome.solved);
    expect(padding.check(['.symmetric(horizontal: 24, vertical: 24)']).outcome, KoanOutcome.solved);
  });
}

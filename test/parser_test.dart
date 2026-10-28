import 'package:flutter_koans/engine/evaluator.dart';
import 'package:flutter_koans/engine/parser.dart';
import 'package:flutter_test/flutter_test.dart';

bool same(String a, String b) =>
    equivalent(parseAnswer(a), parseAnswer(b), Registry.core);

Object? eval(String s) => evaluate(parseAnswer(s), Registry.core);

void main() {
  test('literals', () {
    expect(eval('42'), 42);
    expect(eval('-3.5'), -3.5);
    expect(eval('1e3'), 1000.0);
    expect(eval('0xFF'), 255);
    expect(eval('true'), true);
    expect(eval('null'), null);
    expect(eval("'it\\'s'"), "it's");
    expect(eval('"a" \'b\''), 'ab');
    expect(eval("'''multi\nline'''"), 'multi\nline');
  });

  test('collections', () {
    expect(eval('[1, 2, 3,]'), [1, 2, 3]);
    expect(eval('{1, 2}'), {1, 2});
    expect(eval("{'a': 1}"), {'a': 1});
    expect(eval('{}'), <Object?, Object?>{});
    expect(eval('const <int>[1]'), [1]);
    expect(eval('<int>{}'), <Object?>{});
    expect(eval('<String, int>{}'), <Object?, Object?>{});
    expect(eval('(1, 2)'), (1, 2));
    expect(eval('(1,)'), (1,));
    expect(eval('(1)'), 1);
  });

  test('equivalence', () {
    expect(same('5', '5'), isTrue);
    expect(same('5', '5.0'), isFalse);
    expect(same('5.0', '5.00'), isTrue);
    expect(same('"a"', "'a'"), isTrue);
    expect(same('{1, 2}', '{2, 1}'), isTrue);
    expect(same("{'a': 1, 'b': 2}", "{'b': 2, 'a': 1}"), isTrue);
    expect(same('[1, 2]', '[2, 1]'), isFalse);
    expect(same('(1, b: 2)', '(1, b: 2)'), isTrue);
    expect(same('final', 'final'), isTrue);
    expect(same('<int>{}', '{}'), isFalse);
    expect(same('final', 'const'), isFalse);
  });

  test('loose numbers', () {
    bool loose(String a, String b) => equivalent(
        parseAnswer(a), parseAnswer(b), Registry.core,
        strictNumbers: false);
    expect(loose('3', '3.0'), isTrue);
    expect(loose('[1, 2]', '[1.0, 2]'), isTrue);
    expect(loose('3', '4.0'), isFalse);
  });

  test('dot shorthand', () {
    expect(parseAnswer('.center').toString(), '.center');
    expect(parseAnswer('.all(8)').toString(), '.all(8)');
    expect(() => parseAnswer('.true'), throwsA(isA<ParseException>()));
  });

  test('errors', () {
    expect(() => parseAnswer(''), throwsA(isA<ParseException>()));
    expect(() => parseAnswer("'open"), throwsA(isA<ParseException>()));
    expect(() => parseAnswer('[1, 2'), throwsA(isA<ParseException>()));
    expect(() => parseAnswer('1 2'), throwsA(isA<ParseException>()));
    expect(() => parseAnswer('a ? b'), throwsA(isA<ParseException>()));
    expect(() => eval('nope'), throwsA(isA<EvalException>()));
  });
}

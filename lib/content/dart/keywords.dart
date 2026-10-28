import '../../engine/koan.dart';

/// A Dart keyword typed into a blank, such as `final` or `late`.
class Keyword {
  const Keyword(this.name);

  final String name;
}

const _keywords = [
  'var', 'final', 'const', 'late', 'dynamic', 'void', 'required', //
  'sealed', 'abstract', 'base', 'interface', 'mixin', 'static',
];

/// Lets learners type keywords into a blank, so a wrong keyword reads as
/// wrong rather than unknown. Pair it with [oneOf].
final keywords = Registry(symbols: {for (final k in _keywords) k: Keyword(k)});

/// Accepts a single blank answered by any of [names], each a keyword from
/// [keywords] or a core type name such as `Object`.
bool Function(List<Object?>) oneOf(Set<String> names) => (values) {
      final value = values.single;
      if (value is Keyword) return names.contains(value.name);
      return names.any((n) =>
          Registry.core.symbols.containsKey(n) &&
          Registry.core.symbols[n] == value);
    };

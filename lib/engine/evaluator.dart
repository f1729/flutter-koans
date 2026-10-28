import 'parser.dart';

class EvalException implements Exception {
  const EvalException(this.name);

  /// The identifier or call that could not be resolved.
  final String name;
  @override
  String toString() => 'EvalException($name)';
}

typedef Constructor = Object? Function(
    List<Object?> positional, Map<String, Object?> named);

/// The identifiers and calls an answer may refer to, e.g. `Colors.blue` or
/// `EdgeInsets.all(8)`. Koans extend the base registry with their own names.
class Registry {
  const Registry({this.symbols = const {}, this.constructors = const {}});

  final Map<String, Object?> symbols;
  final Map<String, Constructor> constructors;

  Registry merge(Registry other) => Registry(
        symbols: {...symbols, ...other.symbols},
        constructors: {...constructors, ...other.constructors},
      );

  static const core = Registry(symbols: {
    'int': int,
    'double': double,
    'num': num,
    'String': String,
    'bool': bool,
    'Null': Null,
    'Object': Object,
  });
}

/// Turns an answer AST into a real Dart value.
Object? evaluate(Node node, Registry registry) => switch (node) {
      NullNode() => null,
      BoolNode(:final value) => value,
      NumNode(:final value, :final isDouble) =>
        isDouble ? value.toDouble() : value.toInt(),
      StringNode(:final value) => value,
      ListNode(:final elements) =>
        [for (final e in elements) evaluate(e, registry)],
      SetNode(:final elements) =>
        {for (final e in elements) evaluate(e, registry)},
      MapNode(:final entries) => {
          for (final (k, v) in entries)
            evaluate(k, registry): evaluate(v, registry)
        },
      RecordNode(:final positional, :final named) =>
        _record([for (final e in positional) evaluate(e, registry)], {
          for (final MapEntry(:key, :value) in named.entries)
            key: evaluate(value, registry)
        }),
      IdentNode(:final name) => registry.symbols.containsKey(name)
          ? registry.symbols[name]
          : throw EvalException(name),
      CallNode(:final name, :final positional, :final named) =>
        _call(registry, name, [
          for (final e in positional) evaluate(e, registry)
        ], {
          for (final MapEntry(:key, :value) in named.entries)
            key: evaluate(value, registry)
        }),
    };

Object? _call(Registry registry, String name, List<Object?> positional,
    Map<String, Object?> named) {
  final constructor =
      registry.constructors[name] ?? (throw EvalException(name));
  try {
    return constructor(positional, named);
  } on Object catch (e) {
    if (e is EvalException) rethrow;
    // Wrong argument count or types, e.g. `EdgeInsets.all('wide')`.
    throw EvalException(name);
  }
}

/// Records cannot be built reflectively, so we support the common shapes.
Object? _record(List<Object?> p, Map<String, Object?> named) {
  if (named.isEmpty) {
    return switch (p.length) {
      0 => (),
      1 => (p[0],),
      2 => (p[0], p[1]),
      3 => (p[0], p[1], p[2]),
      4 => (p[0], p[1], p[2], p[3]),
      _ => throw const EvalException('record'),
    };
  }
  throw const EvalException('record');
}

/// Whether two answers mean the same Dart value.
///
/// Literals are compared structurally (sets and maps ignore order, `5` and
/// `5.0` differ). Identifiers compare by name unless both resolve in the
/// registry, and calls compare by their evaluated values. With
/// [strictNumbers] off, `5` and `5.0` are considered the same.
bool equivalent(Node a, Node b, Registry registry, {bool strictNumbers = true}) {
  bool eq(Node x, Node y) =>
      equivalent(x, y, registry, strictNumbers: strictNumbers);

  switch ((a, b)) {
    case (NullNode(), NullNode()):
      return true;
    case (BoolNode(value: final x), BoolNode(value: final y)):
      return x == y;
    case (NumNode(), NumNode()):
      final (x, y) = (a as NumNode, b as NumNode);
      return (!strictNumbers || x.isDouble == y.isDouble) && x.value == y.value;
    case (StringNode(value: final x), StringNode(value: final y)):
      return x == y;
    case (ListNode(elements: final x), ListNode(elements: final y)):
      if (x.length != y.length) return false;
      for (var i = 0; i < x.length; i++) {
        if (!eq(x[i], y[i])) return false;
      }
      return true;
    case (SetNode(elements: final x), SetNode(elements: final y)):
      return _sameUnordered(x, y, eq);
    case (MapNode(entries: final x), MapNode(entries: final y)):
      return _sameUnordered(
          x,
          y,
          (p, q) => eq(p.$1, q.$1) && eq(p.$2, q.$2));
    case (RecordNode(), RecordNode()):
      final (x, y) = (a as RecordNode, b as RecordNode);
      if (x.positional.length != y.positional.length ||
          x.named.length != y.named.length) {
        return false;
      }
      for (var i = 0; i < x.positional.length; i++) {
        if (!eq(x.positional[i], y.positional[i])) {
          return false;
        }
      }
      for (final MapEntry(:key, :value) in x.named.entries) {
        final other = y.named[key];
        if (other == null || !eq(value, other)) return false;
      }
      return true;
    case (IdentNode(name: final x), IdentNode(name: final y)) when x == y:
      return true;
    case (IdentNode() || CallNode(), IdentNode() || CallNode()):
      try {
        return evaluate(a, registry) == evaluate(b, registry);
      } on EvalException {
        return false;
      }
    default:
      return false;
  }
}

bool _sameUnordered<E>(List<E> x, List<E> y, bool Function(E, E) eq) {
  if (x.length != y.length) return false;
  final remaining = [...y];
  for (final e in x) {
    final i = remaining.indexWhere((r) => eq(e, r));
    if (i < 0) return false;
    remaining.removeAt(i);
  }
  return true;
}

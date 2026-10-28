import 'dart:async';

import 'package:flutter/widgets.dart';

import 'evaluator.dart';
import 'parser.dart';

export 'evaluator.dart' show Registry, Constructor;

/// A piece of text in every supported language.
class Tr {
  const Tr(this.en, this.id);

  final String en;
  final String id;

  String of(BuildContext context) => resolve(Localizations.localeOf(context));

  String resolve(Locale locale) => locale.languageCode == 'id' ? id : en;
}

/// The marker for a blank in [Koan.code].
const blank = '__';

/// Builds a live preview from the values the learner typed, one per blank.
typedef PreviewBuilder = Widget Function(List<Object?> values);

/// A predictable wrong answer, and what it reveals about the learner's model.
class Mistake {
  const Mistake(this.answers, this.why);

  /// One entry per blank, as Dart source; null matches anything.
  final List<String?> answers;

  /// Explains the misunderstanding, without giving the right answer away.
  final Tr why;
}

class Koan {
  const Koan({
    required this.prompt,
    required this.code,
    required this.answers,
    this.verify,
    this.accept,
    this.hint,
    this.explanation,
    this.docs,
    this.mistakes = const [],
    this.capstone = false,
    this.registry = Registry.core,
    this.preview,
  });

  /// What the learner should meditate on.
  final Tr prompt;

  /// Dart source shown to the learner. Every [blank] becomes an input.
  final String code;

  /// The reference answer for each blank, as Dart source.
  final List<String> answers;

  /// The real Dart values each blank must equal, computed by the compiler.
  ///
  /// Tests use this to prove [answers] are what Dart actually produces, so the
  /// shown [code] and this closure must say the same thing. It may be async,
  /// for koans about futures and streams.
  final FutureOr<List<Object?>> Function()? verify;

  /// Overrides the default "equals the reference answer" check, for blanks
  /// with more than one right answer.
  final bool Function(List<Object?> values)? accept;

  final Tr? hint;

  /// Why the answer is what it is, shown once the koan is solved.
  final Tr? explanation;

  /// Where to read more: a page on dart.dev, docs.flutter.dev or api.flutter.dev.
  final String? docs;

  /// Common wrong answers with tailored feedback.
  final List<Mistake> mistakes;

  /// Whether this koan gathers up its whole category.
  final bool capstone;

  /// Names the learner may use in their answers.
  final Registry registry;

  final PreviewBuilder? preview;

  int get blankCount => blank.allMatches(code).length;

  Registry get _registry => Registry.core.merge(registry);

  /// Parses what was typed in blank [i], resolving Dart's dot shorthand
  /// (`.center`, `.all(8)`) against the type the blank expects.
  Node parseBlank(int i, String input) =>
      resolveShorthand(parseAnswer(input), parseAnswer(answers[i]));

  KoanResult check(List<String> inputs) {
    assert(inputs.length == blankCount);
    final registry = _registry;
    final nodes = <Node>[];
    for (var i = 0; i < inputs.length; i++) {
      try {
        nodes.add(parseBlank(i, inputs[i]));
      } on ParseException catch (e) {
        return KoanResult.parseError(i, e);
      }
    }
    if (accept case final accept?) {
      final List<Object?> values;
      try {
        values = [for (final n in nodes) evaluate(n, registry)];
      } on EvalException catch (e) {
        // An anticipated mistake says more than "unknown name".
        final mistake = _mistakeFor(nodes, registry);
        return mistake == null ? KoanResult.unknown(e.name) : KoanResult.wrong(mistake);
      }
      try {
        if (accept(values)) return const KoanResult.solved();
      } on Object {
        // A value of the wrong type, e.g. a string where a number belongs.
      }
      return KoanResult.wrong(_mistakeFor(nodes, registry));
    }
    final expected = [for (final a in answers) parseAnswer(a)];
    bool all({required bool strictNumbers}) => [
          for (var i = 0; i < nodes.length; i++)
            equivalent(nodes[i], expected[i], registry,
                strictNumbers: strictNumbers),
        ].every((ok) => ok);
    if (all(strictNumbers: true)) return const KoanResult.solved();
    // Right value, wrong kind of number: `3` where Dart gives `3.0`.
    if (all(strictNumbers: false)) return const KoanResult.numberKind();
    return KoanResult.wrong(_mistakeFor(nodes, registry));
  }

  Mistake? _mistakeFor(List<Node> nodes, Registry registry) {
    for (final m in mistakes) {
      var matches = true;
      for (var i = 0; i < nodes.length && matches; i++) {
        final a = m.answers[i];
        matches = a == null || equivalent(nodes[i], parseBlank(i, a), registry);
      }
      if (matches) return m;
    }
    return null;
  }

  /// Evaluates the inputs for [preview], or returns null if any is invalid.
  List<Object?>? valuesFor(List<String> inputs) {
    final registry = _registry;
    try {
      return [
        for (final (i, input) in inputs.indexed) evaluate(parseBlank(i, input), registry),
      ];
    } on Exception {
      return null;
    }
  }
}

/// Rewrites Dart's dot shorthand into the full name the context implies:
/// with `FlexFit.tight` expected, `.loose` means `FlexFit.loose`, and with
/// `EdgeInsets.all(8)` expected, `.only(left: 8)` means `EdgeInsets.only(...)`.
Node resolveShorthand(Node input, Node expected) {
  final type = switch (expected) {
    IdentNode(:final name) when name.contains('.') => name.substring(0, name.lastIndexOf('.')),
    CallNode(:final name) => name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name,
    _ => null,
  };
  if (type == null) return input;
  return switch (input) {
    IdentNode(:final name) when name.startsWith('.') => IdentNode('$type$name'),
    CallNode(:final name, :final positional, :final named) when name.startsWith('.') =>
      CallNode(name == '.new' ? type : '$type$name', positional, named),
    _ => input,
  };
}

enum KoanOutcome { solved, wrong, numberKind, parseError, unknown }

class KoanResult {
  const KoanResult.solved()
      : outcome = KoanOutcome.solved,
        blankIndex = null,
        error = null,
        name = null,
        mistake = null;
  const KoanResult.wrong([this.mistake])
      : outcome = KoanOutcome.wrong,
        blankIndex = null,
        error = null,
        name = null;
  const KoanResult.numberKind()
      : outcome = KoanOutcome.numberKind,
        blankIndex = null,
        error = null,
        name = null,
        mistake = null;
  const KoanResult.parseError(int this.blankIndex, ParseException this.error)
      : outcome = KoanOutcome.parseError,
        name = null,
        mistake = null;
  const KoanResult.unknown(String this.name)
      : outcome = KoanOutcome.unknown,
        blankIndex = null,
        error = null,
        mistake = null;

  final KoanOutcome outcome;
  final int? blankIndex;
  final ParseException? error;
  final String? name;

  /// The anticipated mistake this wrong answer matches, if any.
  final Mistake? mistake;
}

class Category {
  const Category({
    required this.id,
    required this.title,
    required this.intro,
    required this.koans,
  });

  /// URL slug, e.g. `null-safety`.
  final String id;
  final Tr title;

  /// A short line introducing the category.
  final Tr intro;
  final List<Koan> koans;
}

class Way {
  const Way({
    required this.id,
    required this.title,
    required this.tagline,
    required this.categories,
  });

  final String id;
  final Tr title;
  final Tr tagline;
  final List<Category> categories;

  int get koanCount => categories.fold(0, (n, c) => n + c.koans.length);

  Category? category(String id) =>
      categories.where((c) => c.id == id).firstOrNull;
}

String koanKey(Way way, Category category, int index) =>
    '${way.id}/${category.id}/$index';

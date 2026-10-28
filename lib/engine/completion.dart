/// Editor-style suggestions for a blank, as with Ctrl+Space in an IDE.
///
/// Suggestions are inferred from the blank's reference answer: an enum value
/// suggests its siblings, a constructor suggests the others of its type, a
/// keyword suggests the keywords that could stand in its place. Blanks whose
/// answer is a plain value (`3`, `'koan'`, `[1, 2]`) get no suggestions, since
/// listing them would give the answer away.
library;

import 'koan.dart';
import 'parser.dart';

enum CompletionKind { value, constructor, type, keyword, method, property }

class Completion {
  const Completion(this.label, this.kind, {String? insert, this.detail, this.sample})
      : insert = insert ?? label;

  /// What the list shows, e.g. `EdgeInsets.symmetric`.
  final String label;
  final CompletionKind kind;

  /// What gets typed. A `|` marks where the caret lands.
  final String insert;

  /// A signature or other hint shown beside the label.
  final String? detail;

  /// A complete answer to preview while this suggestion is highlighted, for
  /// templates whose [insert] still has holes, like `EdgeInsets.all(|)`.
  final String? sample;

  /// The text to insert, without the caret marker.
  String get text => insert.replaceAll('|', '');

  /// Where the caret goes within [text].
  int get caret => insert.contains('|') ? insert.indexOf('|') : text.length;

  /// What to preview while highlighted.
  String get previewText => sample ?? text;

  @override
  String toString() => label;
}

/// Constructor templates, keyed by their registry name.
const _templates = <String, (String insert, String detail, String sample)>{
  'EdgeInsets.all': ('EdgeInsets.all(|)', '(double value)', 'EdgeInsets.all(16)'),
  'EdgeInsets.symmetric': (
    'EdgeInsets.symmetric(horizontal: |)',
    '({horizontal, vertical})',
    'EdgeInsets.symmetric(horizontal: 16)',
  ),
  'EdgeInsets.only': (
    'EdgeInsets.only(left: |)',
    '({left, top, right, bottom})',
    'EdgeInsets.only(left: 16)',
  ),
  'EdgeInsets.fromLTRB': (
    'EdgeInsets.fromLTRB(|)',
    '(left, top, right, bottom)',
    'EdgeInsets.fromLTRB(8, 16, 8, 16)',
  ),
  'BorderRadius.circular': ('BorderRadius.circular(|)', '(double radius)', 'BorderRadius.circular(16)'),
  'Radius.circular': ('Radius.circular(|)', '(double radius)', 'Radius.circular(16)'),
  'Alignment': ('Alignment(|)', '(double x, double y)', 'Alignment(0.5, 0.5)'),
  'Size': ('Size(|)', '(double width, double height)', 'Size(40, 40)'),
  'Offset': ('Offset(|)', '(double dx, double dy)', 'Offset(8, 8)'),
  'Duration': ('Duration(seconds: |)', '({seconds, milliseconds})', 'Duration(seconds: 1)'),
  'Color': ('Color(|)', '(int value)', 'Color(0xFF6CB8FF)'),
  'BoxConstraints': (
    'BoxConstraints(maxWidth: |)',
    '({minWidth, maxWidth, minHeight, maxHeight})',
    'BoxConstraints(maxWidth: 200)',
  ),
  'BoxConstraints.tight': ('BoxConstraints.tight(Size(|))', '(Size size)', 'BoxConstraints.tight(Size(160, 80))'),
  'BoxConstraints.loose': ('BoxConstraints.loose(Size(|))', '(Size size)', 'BoxConstraints.loose(Size(160, 80))'),
  'BoxConstraints.tightFor': (
    'BoxConstraints.tightFor(width: |)',
    '({width, height})',
    'BoxConstraints.tightFor(width: 160, height: 80)',
  ),
  'BoxConstraints.expand': ('BoxConstraints.expand(|)', '({width, height})', 'BoxConstraints.expand()'),
};

class _Family {
  const _Family(this.words, {this.when});

  final List<(String, CompletionKind)> words;

  /// Whether this family fits the code around the blank.
  final bool Function(String before, String after)? when;

  bool contains(String word) => words.any((w) => w.$1 == word);
}

List<(String, CompletionKind)> _all(CompletionKind kind, List<String> words) =>
    [for (final w in words) (w, kind)];

const _k = CompletionKind.keyword;
const _t = CompletionKind.type;
const _m = CompletionKind.method;
const _p = CompletionKind.property;

bool _isMember(String before, String after) => before.endsWith('.');
bool _isStatement(String before, String after) => !before.endsWith('.');

/// The character that closes the receiver of a member blank: `]` in
/// `[1, 2].__`, `'` in `'calm'.__`.
String _receiverEnd(String before) {
  final b = before.substring(0, before.length - 1).trimRight();
  return b.isEmpty ? '' : b[b.length - 1];
}

bool _onString(String before, String after) =>
    _isMember(before, after) && !']})'.contains(_receiverEnd(before));
bool _onList(String before, String after) =>
    _isMember(before, after) && _receiverEnd(before) != '}';

/// Groups of names that can sensibly stand in for one another, tried in order.
final _families = <_Family>[
  _Family(_all(_k, ['abstract', 'base', 'final', 'interface', 'sealed', 'mixin']),
      when: (before, after) => after.trimLeft().startsWith('class')),
  _Family(_all(_k, ['var', 'final', 'const', 'late', 'dynamic', 'required', 'static']),
      when: _isStatement),
  _Family(_all(_k, ['factory', 'static', 'const', 'external']), when: _isStatement),
  _Family(_all(_k, ['extends', 'with', 'implements', 'on']), when: _isStatement),
  _Family(_all(_k, ['await', 'yield', 'return', 'throw', 'async']), when: _isStatement),
  _Family(_all(_t, ['int', 'double', 'num', 'String', 'bool', 'Null', 'Object', 'List', 'Map', 'Set', 'Function']),
      when: _isStatement),
  _Family(_all(_t, [
    'ArgumentError', 'FormatException', 'RangeError', 'StateError',
    'TypeError', 'UnimplementedError', 'UnsupportedError',
  ]), when: _isStatement),
  _Family(_all(_t, ['StatelessWidget', 'StatefulWidget', 'State', 'InheritedWidget', 'Widget']),
      when: _isStatement),
  _Family(_all(_t, ['Row', 'Column', 'Stack', 'Expanded', 'Flexible', 'Spacer']), when: _isStatement),
  _Family(_all(_t, ['Theme', 'MediaQuery', 'Navigator', 'DefaultTextStyle']), when: _isStatement),
  _Family(_all(_t, ['Center', 'Align', 'UnconstrainedBox', 'ConstrainedBox', 'SizedBox', 'Padding', 'Container']),
      when: _isStatement),
  _Family(_all(_t, ['ListView', 'SingleChildScrollView', 'GridView', 'Column']), when: _isStatement),
  _Family(_all(_t, [
    'NeverScrollableScrollPhysics', 'BouncingScrollPhysics', 'ClampingScrollPhysics',
    'AlwaysScrollableScrollPhysics', 'PageScrollPhysics',
  ]), when: _isStatement),
  _Family(_all(_p, ['onTap', 'onDoubleTap', 'onLongPress', 'onSecondaryTap', 'onTapDown', 'onTapUp']),
      when: _isStatement),
  _Family(_all(_t, ['GestureDetector', 'InkWell', 'InkResponse', 'Ink', 'DecoratedBox']), when: _isStatement),
  _Family(_all(_t, [
    'AnimatedContainer', 'AnimatedOpacity', 'AnimatedAlign', 'AnimatedPadding', 'AnimatedSwitcher', 'Container',
  ]), when: _isStatement),
  _Family(_all(_t, ['Key', 'ValueKey', 'ObjectKey', 'UniqueKey', 'GlobalKey']), when: _isStatement),
  _Family(_all(_t, ['MaterialPageRoute', 'CupertinoPageRoute', 'PageRouteBuilder', 'Route']), when: _isStatement),
  _Family(_all(_t, ['FutureBuilder', 'StreamBuilder', 'ValueListenableBuilder', 'ListenableBuilder', 'Builder']),
      when: _isStatement),
  _Family(_all(_t, ['BuildContext', 'Widget', 'Key', 'Element', 'ThemeData', 'TextStyle']), when: _isStatement),
  _Family([
    ..._all(_m, [
      'build', 'createState', 'initState', 'didChangeDependencies',
      'didUpdateWidget', 'setState', 'deactivate', 'dispose',
    ]),
    ..._all(_p, ['widget', 'context', 'mounted']),
  ], when: (before, after) => _isStatement(before, after) || before.endsWith('super.')),
  _Family(_all(_p, ['child', 'children']), when: _isStatement),
  // Members, by what the receiver looks like.
  _Family([
    ..._all(_p, ['length', 'isEmpty', 'isNotEmpty', 'codeUnits']),
    ..._all(_m, [
      'contains', 'endsWith', 'padLeft', 'padRight', 'replaceAll', 'split',
      'startsWith', 'substring', 'toLowerCase', 'toUpperCase', 'trim', 'trimLeft', 'trimRight',
    ]),
  ], when: _onString),
  _Family([
    ..._all(_p, ['first', 'last', 'length', 'isEmpty', 'reversed']),
    ..._all(_m, [
      'any', 'contains', 'every', 'expand', 'firstWhere', 'fold', 'forEach', 'join',
      'map', 'reduce', 'skip', 'take', 'toList', 'toSet', 'where',
    ]),
  ], when: _onList),
  _Family([
    ..._all(_p, ['first', 'length', 'isEmpty']),
    ..._all(_m, ['add', 'contains', 'difference', 'intersection', 'lookup', 'remove', 'union']),
  ], when: _isMember),
  _Family(_all(_p, ['colorScheme', 'textTheme', 'brightness', 'platform']), when: _isMember),
  _Family(_all(_p, ['hasData', 'hasError', 'data', 'error', 'connectionState', 'requireData']), when: _isMember),
];

/// The code just before and just after blank [index].
(String, String) blankContext(String code, int index) {
  final parts = code.split(blank);
  return (parts[index], parts[index + 1]);
}

/// Suggestions for blank [index] of [koan], in a sensible order.
List<Completion> completionsFor(Koan koan, int index) {
  final registry = Registry.core.merge(koan.registry);
  final Node answer;
  try {
    answer = parseAnswer(koan.answers[index]);
  } on ParseException {
    return const [];
  }
  switch (answer) {
    case BoolNode():
      return const [
        Completion('true', CompletionKind.value),
        Completion('false', CompletionKind.value),
      ];
    case IdentNode(:final name) when name.contains('.'):
      return completionsForPrefix(name.substring(0, name.lastIndexOf('.')), registry);
    case CallNode(:final name):
      final type = name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name;
      return completionsForPrefix(type, registry);
    case IdentNode(:final name):
      final (before, after) = blankContext(koan.code, index);
      for (final family in _families) {
        if (family.contains(name) && (family.when?.call(before, after) ?? true)) {
          return [for (final (w, kind) in family.words) Completion(w, kind)];
        }
      }
      return const [];
    default:
      return const [];
  }
}

/// Everything in [registry] that belongs to [type], e.g. `MainAxisAlignment`:
/// its values in declaration order, then its constructors as templates.
List<Completion> completionsForPrefix(String type, Registry registry) => [
      for (final name in registry.symbols.keys)
        if (name.startsWith('$type.')) Completion(name, CompletionKind.value),
      for (final name in registry.constructors.keys)
        if (name == type || name.startsWith('$type.'))
          if (_templates[name] case (final insert, final detail, final sample))
            Completion(name, CompletionKind.constructor, insert: insert, detail: detail, sample: sample)
          else
            Completion(name, CompletionKind.constructor, insert: '$name(|)'),
    ];

/// Keeps the suggestions that match what has been typed so far, by the start
/// of the whole name or of its last part: `cen` finds `Alignment.center`.
List<Completion> filterCompletions(List<Completion> all, String token) {
  if (token.isEmpty) return all;
  final t = token.toLowerCase();
  return [
    for (final c in all)
      if (c.label.toLowerCase().startsWith(t) ||
          (!t.contains('.') && c.label.toLowerCase().split('.').last.startsWith(t)))
        c,
  ];
}

/// What an empty blank should hint at, like an editor's type hint: the type
/// for named values and constructors (`FlexFit`, `EdgeInsets`), or the kind
/// of word for keywords and members. Null for plain values, where even the
/// type could give the answer away (`3` versus `3.0`).
({String? type, CompletionKind? kind})? blankHintFor(Koan koan, int index) {
  final Node answer;
  try {
    answer = parseAnswer(koan.answers[index]);
  } on ParseException {
    return null;
  }
  switch (answer) {
    case IdentNode(:final name) when name.contains('.'):
      return (type: name.substring(0, name.lastIndexOf('.')), kind: null);
    case CallNode(:final name):
      return (type: name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name, kind: null);
    case IdentNode(:final name):
      final match = completionsFor(koan, index).where((c) => c.label == name).firstOrNull;
      return match == null ? null : (type: null, kind: match.kind);
    default:
      return null;
  }
}

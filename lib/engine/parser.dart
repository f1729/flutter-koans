/// A small parser for the subset of Dart that learners type into koan blanks.
///
/// Dart cannot `eval` at runtime, so instead of executing arbitrary code we
/// parse answers into an AST of *values*: numbers, strings, booleans, `null`,
/// lists, sets, maps, records, identifiers (`MainAxisAlignment.center`,
/// `const`, `int`) and constructor-like calls (`EdgeInsets.all(8)`).
///
/// Numbers keep track of whether they were written as doubles, so `5` and
/// `5.0` are different answers even on the web, where both are JS numbers.
library;

sealed class Node {
  const Node();
}

class NullNode extends Node {
  const NullNode();
  @override
  String toString() => 'null';
}

class BoolNode extends Node {
  const BoolNode(this.value);
  final bool value;
  @override
  String toString() => '$value';
}

class NumNode extends Node {
  const NumNode(this.value, {required this.isDouble});
  final num value;
  final bool isDouble;
  @override
  String toString() => isDouble ? '${value.toDouble()}' : '${value.toInt()}';
}

class StringNode extends Node {
  const StringNode(this.value);
  final String value;
  @override
  String toString() => "'$value'";
}

class ListNode extends Node {
  const ListNode(this.elements);
  final List<Node> elements;
  @override
  String toString() => '[${elements.join(', ')}]';
}

class SetNode extends Node {
  const SetNode(this.elements);
  final List<Node> elements;
  @override
  String toString() => '{${elements.join(', ')}}';
}

class MapNode extends Node {
  const MapNode(this.entries);
  final List<(Node, Node)> entries;
  @override
  String toString() => '{${entries.map((e) => '${e.$1}: ${e.$2}').join(', ')}}';
}

class RecordNode extends Node {
  const RecordNode(this.positional, this.named);
  final List<Node> positional;
  final Map<String, Node> named;
  @override
  String toString() => '(${[
        ...positional.map((e) => '$e'),
        ...named.entries.map((e) => '${e.key}: ${e.value}'),
      ].join(', ')}${positional.length == 1 && named.isEmpty ? ',' : ''})';
}

/// A (possibly dotted) identifier such as `final`, `int` or `Colors.blue`.
class IdentNode extends Node {
  const IdentNode(this.name);
  final String name;
  @override
  String toString() => name;
}

/// A call such as `EdgeInsets.all(8)` or `Duration(seconds: 1)`.
class CallNode extends Node {
  const CallNode(this.name, this.positional, this.named);
  final String name;
  final List<Node> positional;
  final Map<String, Node> named;
  @override
  String toString() => '$name(${[
        ...positional.map((e) => '$e'),
        ...named.entries.map((e) => '${e.key}: ${e.value}'),
      ].join(', ')})';
}

enum ParseErrorKind { empty, unexpectedChar, unterminatedString, unexpectedEnd, unexpectedToken }

class ParseException implements Exception {
  const ParseException(this.kind, this.offset, [this.detail = '']);
  final ParseErrorKind kind;
  final int offset;
  final String detail;
  @override
  String toString() => 'ParseException($kind at $offset: $detail)';
}

enum _T { number, string, ident, punct, eof }

class _Token {
  const _Token(this.type, this.text, this.offset, [this.value]);
  final _T type;
  final String text;
  final int offset;
  final Object? value;
}

Node parseAnswer(String source) {
  if (source.trim().isEmpty) {
    throw const ParseException(ParseErrorKind.empty, 0);
  }
  final parser = _Parser(_tokenize(source));
  final node = parser.expression();
  parser.expectEnd();
  return node;
}

List<_Token> _tokenize(String s) {
  final tokens = <_Token>[];
  var i = 0;
  bool isDigit(String c) => RegExp('[0-9]').hasMatch(c);
  bool isIdentStart(String c) => RegExp(r'[A-Za-z_$]').hasMatch(c);
  bool isIdentPart(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);

  while (i < s.length) {
    final c = s[i];
    if (c.trim().isEmpty) {
      i++;
      continue;
    }
    final start = i;
    if (isDigit(c) || (c == '.' && i + 1 < s.length && isDigit(s[i + 1]))) {
      final m = RegExp(r'0[xX][0-9a-fA-F]+|(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?')
          .matchAsPrefix(s, i)!;
      var text = m[0]!;
      // `1.` followed by an identifier is a member access, not a double.
      if (text.endsWith('.') && !text.contains(RegExp('[eE]'))) {
        text = text.substring(0, text.length - 1);
      }
      i += text.length;
      tokens.add(_Token(_T.number, text, start));
      continue;
    }
    if (c == "'" || c == '"') {
      final triple = s.startsWith(c * 3, i);
      final quote = triple ? c * 3 : c;
      i += quote.length;
      final buf = StringBuffer();
      var closed = false;
      while (i < s.length) {
        if (s.startsWith(quote, i)) {
          i += quote.length;
          closed = true;
          break;
        }
        final ch = s[i];
        if (ch == '\\' && i + 1 < s.length) {
          final n = s[i + 1];
          buf.write(switch (n) {
            'n' => '\n',
            't' => '\t',
            'r' => '\r',
            r'$' => r'$',
            _ => n,
          });
          i += 2;
          continue;
        }
        if (!triple && ch == '\n') break;
        buf.write(ch);
        i++;
      }
      if (!closed) {
        throw ParseException(ParseErrorKind.unterminatedString, start);
      }
      tokens.add(_Token(_T.string, s.substring(start, i), start, buf.toString()));
      continue;
    }
    if (isIdentStart(c)) {
      while (i < s.length && isIdentPart(s[i])) {
        i++;
      }
      tokens.add(_Token(_T.ident, s.substring(start, i), start));
      continue;
    }
    if ('[](){}<>,:.-+'.contains(c)) {
      tokens.add(_Token(_T.punct, c, start));
      i++;
      continue;
    }
    throw ParseException(ParseErrorKind.unexpectedChar, i, c);
  }
  tokens.add(_Token(_T.eof, '', s.length));
  return tokens;
}

class _Parser {
  _Parser(this.tokens);
  final List<_Token> tokens;
  int pos = 0;

  _Token get peek => tokens[pos];
  _Token next() => tokens[pos++];

  bool isPunct(String p) => peek.type == _T.punct && peek.text == p;

  void expectPunct(String p) {
    if (!isPunct(p)) _fail();
    pos++;
  }

  Never _fail() {
    if (peek.type == _T.eof) {
      throw ParseException(ParseErrorKind.unexpectedEnd, peek.offset);
    }
    throw ParseException(ParseErrorKind.unexpectedToken, peek.offset, peek.text);
  }

  void expectEnd() {
    if (peek.type != _T.eof) _fail();
  }

  Node expression() {
    // Ignore a leading `const` in front of literals: `const [1, 2]`.
    if (peek.type == _T.ident &&
        peek.text == 'const' &&
        tokens[pos + 1].type != _T.eof) {
      pos++;
    }
    // Type arguments are ignored, except that `<int>{}` is an empty set.
    if (isPunct('<') && _skipTypeArgs() == 1 && isPunct('{')) {
      if (tokens[pos + 1].type == _T.punct && tokens[pos + 1].text == '}') {
        pos += 2;
        return const SetNode([]);
      }
    }

    final t = peek;
    if (t.type == _T.punct && (t.text == '-' || t.text == '+')) {
      pos++;
      final operand = expression();
      if (operand is! NumNode) _failAt(t);
      return t.text == '-'
          ? NumNode(-operand.value, isDouble: operand.isDouble)
          : operand;
    }
    switch (t.type) {
      case _T.number:
        pos++;
        final isHex = t.text.toLowerCase().startsWith('0x');
        final isDouble = !isHex && t.text.contains(RegExp('[.eE]'));
        final value = isHex
            ? int.parse(t.text.substring(2), radix: 16)
            : isDouble
                ? double.parse(t.text)
                : int.parse(t.text);
        return NumNode(value, isDouble: isDouble);
      case _T.string:
        // Adjacent string literals are concatenated, as in Dart.
        final buf = StringBuffer();
        while (peek.type == _T.string) {
          buf.write(next().value);
        }
        return StringNode(buf.toString());
      case _T.ident:
        return _identOrCall();
      case _T.punct:
        switch (t.text) {
          // Dot shorthand, `.center` or `.all(8)`; see `resolveShorthand`.
          case '.' when tokens[pos + 1].type == _T.ident:
            pos++;
            final node = _identOrCall();
            if (node is IdentNode) return IdentNode('.${node.name}');
            if (node is CallNode) {
              return CallNode('.${node.name}', node.positional, node.named);
            }
            _failAt(t); // `.true`, `.null`
          case '[':
            pos++;
            return ListNode(_listUntil(']', expression));
          case '{':
            return _setOrMap();
          case '(':
            return _parenOrRecord();
        }
      case _T.eof:
    }
    _fail();
  }

  Never _failAt(_Token t) =>
      throw ParseException(ParseErrorKind.unexpectedToken, t.offset, t.text);

  /// Skips `<...>` and returns how many type arguments it held.
  int _skipTypeArgs() {
    var depth = 0;
    var count = 1;
    do {
      if (peek.type == _T.eof) _fail();
      final t = next();
      if (t.type != _T.punct) continue;
      if (t.text == '<') depth++;
      if (t.text == '>') depth--;
      if (t.text == ',' && depth == 1) count++;
    } while (depth > 0);
    return count;
  }

  List<E> _listUntil<E>(String close, E Function() element) {
    final items = <E>[];
    while (!isPunct(close)) {
      items.add(element());
      if (isPunct(',')) {
        pos++;
      } else if (!isPunct(close)) {
        _fail();
      }
    }
    pos++;
    return items;
  }

  Node _identOrCall() {
    final buf = StringBuffer(next().text);
    while (isPunct('.') && tokens[pos + 1].type == _T.ident) {
      pos++;
      buf.write('.${next().text}');
    }
    final name = buf.toString();
    switch (name) {
      case 'true':
        return const BoolNode(true);
      case 'false':
        return const BoolNode(false);
      case 'null':
        return const NullNode();
    }
    if (isPunct('<') && name[0].toUpperCase() == name[0]) _skipTypeArgs();
    if (!isPunct('(')) return IdentNode(name);
    pos++;
    final (positional, named) = _arguments(')');
    return CallNode(name, positional, named);
  }

  (List<Node>, Map<String, Node>) _arguments(String close) {
    final positional = <Node>[];
    final named = <String, Node>{};
    _listUntil(close, () {
      if (peek.type == _T.ident &&
          tokens[pos + 1].type == _T.punct &&
          tokens[pos + 1].text == ':') {
        final name = next().text;
        pos++;
        named[name] = expression();
      } else {
        positional.add(expression());
      }
    });
    return (positional, named);
  }

  Node _setOrMap() {
    pos++; // {
    if (isPunct('}')) {
      pos++;
      return const MapNode([]); // `{}` is a map in Dart.
    }
    final first = expression();
    if (isPunct(':')) {
      pos++;
      final entries = <(Node, Node)>[(first, expression())];
      if (isPunct(',')) pos++;
      entries.addAll(_listUntil('}', () {
        final k = expression();
        expectPunct(':');
        return (k, expression());
      }));
      return MapNode(entries);
    }
    final elements = [first];
    if (isPunct(',')) pos++;
    elements.addAll(_listUntil('}', expression));
    return SetNode(elements);
  }

  Node _parenOrRecord() {
    pos++; // (
    if (isPunct(')')) {
      pos++;
      return const RecordNode([], {});
    }
    final start = pos;
    final isNamed = peek.type == _T.ident &&
        tokens[pos + 1].type == _T.punct &&
        tokens[pos + 1].text == ':';
    if (!isNamed) {
      final first = expression();
      if (isPunct(')')) {
        pos++;
        return first; // Just parentheses.
      }
      pos = start;
    }
    final (positional, named) = _arguments(')');
    return RecordNode(positional, named);
  }
}

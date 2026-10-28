import 'package:flutter/painting.dart';

import '../theme.dart';

enum TokenKind { plain, keyword, type, string, number, comment, call, blank }

class CodeToken {
  const CodeToken(this.kind, this.text);
  final TokenKind kind;
  final String text;
}

const _keywords = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
  'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
  'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
  'external', 'factory', 'false', 'final', 'finally', 'for', 'Function',
  'get', 'hide', 'if', 'implements', 'import', 'in', 'interface', 'is',
  'late', 'library', 'mixin', 'new', 'null', 'of', 'on', 'operator', 'part',
  'required', 'rethrow', 'return', 'sealed', 'set', 'show', 'static', 'super',
  'switch', 'sync', 'this', 'throw', 'true', 'try', 'typedef', 'var', 'void',
  'when', 'while', 'with', 'yield',
};

final _patterns = <(TokenKind, RegExp)>[
  (TokenKind.blank, RegExp(r'__(?![A-Za-z0-9_$])')),
  (TokenKind.comment, RegExp(r'//(?:(?!__)[^\n])*')),
  (TokenKind.string, RegExp(r"r?'''[\s\S]*?'''|r?\x22\x22\x22[\s\S]*?\x22\x22\x22|r?'(?:[^'\\\n]|\\.)*'|r?\x22(?:[^\x22\\\n]|\\.)*\x22")),
  (TokenKind.number, RegExp(r'\b(?:0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][+-]?\d+)?)\b')),
  (TokenKind.plain, RegExp(r'[A-Za-z_$][A-Za-z0-9_$]*')),
];

/// Splits Dart source into coloured tokens. Good enough for short snippets;
/// not a real lexer.
List<CodeToken> tokenizeDart(String source) {
  final tokens = <CodeToken>[];
  final plain = StringBuffer();
  void flush() {
    if (plain.isNotEmpty) {
      tokens.add(CodeToken(TokenKind.plain, plain.toString()));
      plain.clear();
    }
  }

  var i = 0;
  outer:
  while (i < source.length) {
    for (final (kind, pattern) in _patterns) {
      final m = pattern.matchAsPrefix(source, i);
      if (m == null) continue;
      final text = m[0]!;
      if (kind == TokenKind.plain) {
        // Words: keyword, type, call or plain identifier.
        final after = source.substring(i + text.length).trimLeft();
        final k = _keywords.contains(text)
            ? TokenKind.keyword
            : RegExp('^_?[A-Z]').hasMatch(text)
                ? TokenKind.type
                : after.startsWith('(')
                    ? TokenKind.call
                    : TokenKind.plain;
        if (k == TokenKind.plain) {
          plain.write(text);
        } else {
          flush();
          tokens.add(CodeToken(k, text));
        }
      } else {
        flush();
        tokens.add(CodeToken(kind, text));
      }
      i += text.length;
      continue outer;
    }
    plain.write(source[i]);
    i++;
  }
  flush();
  return tokens;
}

Color colorFor(TokenKind kind) => switch (kind) {
      TokenKind.keyword => const Color(0xFFC79BF2),
      TokenKind.type => const Color(0xFF7FD1AE),
      TokenKind.string => const Color(0xFFE6C07B),
      TokenKind.number => const Color(0xFFF2A97B),
      TokenKind.comment => Palette.faint,
      TokenKind.call => const Color(0xFF82B8FF),
      TokenKind.plain || TokenKind.blank => Palette.text,
    };

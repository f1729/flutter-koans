import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../analytics/analytics.dart';
import '../app_state.dart';
import '../engine/completion.dart';
import '../engine/koan.dart';
import '../engine/parser.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'code_view.dart';
import 'preview_pair.dart';
import 'sidebar.dart';
import 'widgets.dart';

class KoanScreen extends StatelessWidget {
  const KoanScreen({
    super.key,
    required this.way,
    required this.category,
    required this.index,
  });

  final Way way;
  final Category category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context);
    final accent = Palette.forWay(way.id);
    return Theme(
      data: themeFor(way.id),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final sidebar = Sidebar(way: way, category: category, index: index);
        return Scaffold(
          drawer: wide ? null : Drawer(backgroundColor: Palette.ink, child: SafeArea(child: sidebar)),
          body: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Palette.line)),
                ),
                child: Row(
                  children: [
                    if (!wide)
                      Builder(
                        builder: (context) => IconButton(
                          tooltip: l.categories,
                          icon: const Icon(Icons.menu, color: Palette.muted),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    Wordmark(color: accent),
                    const SizedBox(width: 12),
                    if (constraints.maxWidth >= 560)
                      Text(way.title.of(context), style: TextStyle(color: accent, fontSize: 14)),
                    const Spacer(),
                    if (constraints.maxWidth >= 720) ...[
                      Text(
                        l.koanCount(state.solvedIn(way), way.koanCount),
                        style: const TextStyle(color: Palette.muted, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.solvedIn(way) / way.koanCount,
                            minHeight: 4,
                            backgroundColor: Palette.line,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                    const LanguageToggle(),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide) ...[
                      SizedBox(width: 290, child: sidebar),
                      const VerticalDivider(width: 1),
                    ],
                    Expanded(
                      child: KoanView(
                        key: ValueKey(koanKey(way, category, index)),
                        way: way,
                        category: category,
                        index: index,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

String? _nextPath(Way way, Category category, int index) {
  if (index + 1 < category.koans.length) {
    return koanPath(way, category, index + 1);
  }
  final c = way.categories.indexOf(category);
  if (c + 1 < way.categories.length) {
    return koanPath(way, way.categories[c + 1], 0);
  }
  return null;
}

String? _previousPath(Way way, Category category, int index) {
  if (index > 0) return koanPath(way, category, index - 1);
  final c = way.categories.indexOf(category);
  if (c > 0) {
    final prev = way.categories[c - 1];
    return koanPath(way, prev, prev.koans.length - 1);
  }
  return null;
}

enum _Feedback { none, solved, wrong, numberKind, empty, parseError, unknown, revealed }

class KoanView extends StatefulWidget {
  const KoanView({
    super.key,
    required this.way,
    required this.category,
    required this.index,
    this.review = false,
    this.header,
    this.onNext,
  });

  final Way way;
  final Category category;
  final int index;

  /// Reviewing: blanks start empty even if solved before, and the result
  /// moves the koan along the review queue.
  final bool review;

  /// Replaces the category heading and koan dots.
  final Widget? header;

  /// Replaces going to the next koan in the Way.
  final VoidCallback? onNext;

  @override
  State<KoanView> createState() => _KoanViewState();
}

class _KoanViewState extends State<KoanView> with SingleTickerProviderStateMixin {
  Koan get koan => widget.category.koans[widget.index];
  String get _key => koanKey(widget.way, widget.category, widget.index);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late List<BlankStatus> _statuses;
  late final AnimationController _shake;
  late final List<List<Completion>> _completions;
  late final List<BlankHint?> _hints;
  late final List<GlobalKey<BlankFieldState>> _fieldKeys;
  final _peek = ValueNotifier<Peek?>(null);

  /// The blank the learner was last in, for the Suggestions button.
  var _lastFocused = 0;

  var _feedback = _Feedback.none;
  ParseException? _parseError;
  String? _unknownName;
  var _attempts = 0;
  var _showHint = false;
  var _solved = false;
  var _revealed = false;

  /// Whether this visit's result has been recorded (stats, review, events).
  var _recorded = false;

  /// The anticipated mistake behind the last wrong answer, if any.
  Mistake? _mistake;

  /// Suggestions opened by themselves after the second miss.
  var _autoSuggested = false;

  /// What was typed when the koan was solved, so Enter can move on.
  List<String>? _solvedInputs;

  @override
  void initState() {
    super.initState();
    final alreadySolved = !widget.review && AppState.read(context).isSolved(_key);
    _controllers = [
      for (final a in koan.answers) TextEditingController(text: alreadySolved ? a : ''),
    ];
    _focusNodes = [for (final _ in koan.answers) FocusNode()];
    _statuses = List.filled(koan.blankCount, alreadySolved ? BlankStatus.solved : BlankStatus.idle);
    _solved = alreadySolved;
    if (alreadySolved) _solvedInputs = [...koan.answers];
    for (final (i, c) in _controllers.indexed) {
      c.addListener(() => _onEdited(i));
    }
    for (final (i, f) in _focusNodes.indexed) {
      f.addListener(() {
        if (f.hasFocus) _lastFocused = i;
      });
    }
    _completions = [for (var i = 0; i < koan.blankCount; i++) completionsFor(koan, i)];
    _hints = [for (var i = 0; i < koan.blankCount; i++) blankHintFor(koan, i)];
    _fieldKeys = [for (var i = 0; i < koan.blankCount; i++) GlobalKey<BlankFieldState>()];
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shake.dispose();
    _peek.dispose();
    super.dispose();
  }

  List<String> get _inputs => [for (final c in _controllers) c.text];

  bool get _hasSuggestions => _completions.any((c) => c.isNotEmpty);

  /// Opens suggestions in the blank last used, or the first that has any.
  void _suggest() {
    final target = _completions[_lastFocused].isNotEmpty
        ? _lastFocused
        : _completions.indexWhere((c) => c.isNotEmpty);
    _fieldKeys[target].currentState?.showSuggestions();
  }

  void _onEdited(int i) {
    if (_statuses[i] == BlankStatus.error) {
      setState(() => _statuses[i] = BlankStatus.idle);
    }
  }

  void _submit() {
    final inputs = _inputs;
    if (_solved && _solvedInputs != null && _listEquals(inputs, _solvedInputs!)) {
      _goNext();
      return;
    }
    final empty = [for (final i in inputs) i.trim().isEmpty];
    if (empty.contains(true)) {
      setState(() {
        _feedback = _Feedback.empty;
        _statuses = [for (final e in empty) e ? BlankStatus.error : BlankStatus.idle];
      });
      _focusNodes[empty.indexOf(true)].requestFocus();
      _shake.forward(from: 0);
      return;
    }
    final result = koan.check(inputs);
    final missed = result.outcome == KoanOutcome.wrong ||
        result.outcome == KoanOutcome.numberKind ||
        result.outcome == KoanOutcome.unknown;
    if (missed) Analytics.record(_key, 'wrong', answer: inputs.join(' | '));
    setState(() {
      _solved = result.outcome == KoanOutcome.solved;
      _mistake = result.mistake;
      _autoSuggested = false;
      switch (result.outcome) {
        case KoanOutcome.solved:
          _feedback = _Feedback.solved;
          _statuses = List.filled(koan.blankCount, BlankStatus.solved);
          _solvedInputs = inputs;
        case KoanOutcome.wrong:
          _attempts++;
          _feedback = _Feedback.wrong;
          _statuses = List.filled(koan.blankCount, BlankStatus.error);
        case KoanOutcome.numberKind:
          _attempts++;
          _feedback = _Feedback.numberKind;
          _statuses = List.filled(koan.blankCount, BlankStatus.error);
        case KoanOutcome.parseError:
          _feedback = _Feedback.parseError;
          _parseError = result.error;
          _statuses = [
            for (var i = 0; i < koan.blankCount; i++)
              i == result.blankIndex ? BlankStatus.error : BlankStatus.idle,
          ];
        case KoanOutcome.unknown:
          _attempts++;
          _feedback = _Feedback.unknown;
          _unknownName = result.name;
          _statuses = List.filled(koan.blankCount, BlankStatus.error);
      }
    });
    if (_solved) {
      _record();
    } else {
      _shake.forward(from: 0);
      _focusNodes[result.blankIndex ?? 0].requestFocus();
      // A second miss with nothing anticipated to say: show what fits.
      if (missed && _attempts == 2 && _mistake == null && _hasSuggestions) {
        setState(() => _autoSuggested = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _suggest();
        });
      }
    }
  }

  void _record() {
    if (_recorded) return;
    _recorded = true;
    final state = AppState.read(context);
    Analytics.record(_key, 'solve', attempts: _attempts);
    if (widget.review) {
      state.recordReview(_key, firstTry: _attempts == 0 && !_revealed);
    } else {
      state.markSolved(_key);
      state.recordSolve(_key, misses: _attempts, revealed: _revealed);
    }
  }

  void _reveal() {
    if (!_revealed) Analytics.record(_key, 'reveal');
    _revealed = true;
    setState(() {
      for (final (i, c) in _controllers.indexed) {
        c.text = koan.answers[i];
      }
      _statuses = List.filled(koan.blankCount, BlankStatus.idle);
      _feedback = _Feedback.revealed;
    });
    _focusNodes.first.requestFocus();
  }

  void _goNext() {
    if (widget.onNext case final onNext?) return onNext();
    context.go(_nextPath(widget.way, widget.category, widget.index) ?? '/${widget.way.id}/done');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppState.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final previous = _previousPath(widget.way, widget.category, widget.index);
    final categoryDone = state.solvedIn(widget.way, widget.category) == widget.category.koans.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.header case final header?)
                header
              else ...[
                Text(
                  widget.category.title.of(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(widget.category.intro.of(context), style: const TextStyle(color: Palette.muted, fontSize: 15)),
                const SizedBox(height: 20),
                _KoanDots(way: widget.way, category: widget.category, index: widget.index),
              ],
              const SizedBox(height: 36),
              if (koan.capstone) ...[
                _CapstoneBadge(label: l.capstone),
                const SizedBox(height: 12),
              ],
              Text(koan.prompt.of(context), style: promptStyle(context)),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) => Transform.translate(
                  offset: Offset(math.sin(_shake.value * math.pi * 5) * 8 * (1 - _shake.value), 0),
                  child: child,
                ),
                child: KoanCode(
                  code: koan.code,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  completions: _completions,
                  hints: _hints,
                  registry: Registry.core.merge(koan.registry),
                  peek: _peek,
                  fieldKeys: _fieldKeys,
                  suggestAbove: koan.preview != null,
                  statuses: _statuses,
                  onSubmit: _submit,
                ),
              ),
              if (koan.preview != null) ...[
                const SizedBox(height: 20),
                PreviewPair(koan: koan, controllers: _controllers, peek: _peek),
              ],
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _FeedbackLine(
                  key: ValueKey((_feedback, _attempts)),
                  feedback: _feedbackText(l, categoryDone),
                  color: switch (_feedback) {
                    _Feedback.solved => Palette.jade,
                    _Feedback.none || _Feedback.revealed => Palette.muted,
                    _ => Palette.ember,
                  },
                  icon: switch (_feedback) {
                    _Feedback.solved => Icons.check_circle_outline,
                    _Feedback.none => Icons.keyboard_return,
                    _Feedback.revealed => Icons.visibility_outlined,
                    _ => Icons.blur_circular,
                  },
                ),
              ),
              if (_showHint && koan.hint != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: accent, width: 3)),
                  ),
                  child: Text(koan.hint!.of(context), style: const TextStyle(fontSize: 15, height: 1.5)),
                ),
              ],
              if (_solved && koan.explanation != null) ...[
                const SizedBox(height: 18),
                _Explanation(text: koan.explanation!.of(context), docs: koan.docs),
              ],
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!widget.review)
                    TextButton.icon(
                      onPressed: previous == null ? null : () => context.go(previous),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text(l.previous),
                    ),
                  if (_hasSuggestions && !_solved)
                    Tooltip(
                      message: suggestShortcut(),
                      child: TextButton.icon(
                        onPressed: _suggest,
                        icon: const Icon(Icons.list_alt, size: 18),
                        label: Text(l.suggestions),
                      ),
                    ),
                  if (koan.hint != null)
                    TextButton.icon(
                      onPressed: () {
                        if (!_showHint) Analytics.record(_key, 'hint');
                        setState(() => _showHint = !_showHint);
                      },
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: Text(l.hint),
                    ),
                  if (_attempts >= 3 && !_solved && _feedback != _Feedback.revealed)
                    TextButton.icon(
                      onPressed: _reveal,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: Text(l.showMe),
                    ),
                  if (_solved)
                    FilledButton.icon(
                      onPressed: _goNext,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(l.next),
                    )
                  else
                    FilledButton(onPressed: _submit, child: Text(l.meditate)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _feedbackText(AppLocalizations l, bool categoryDone) {
    switch (_feedback) {
      case _Feedback.none:
        return _solved
            ? l.solvedNext
            : _hasSuggestions
                ? l.pressEnterOrShortcut(suggestShortcut())
                : l.pressEnterToCheck;
      case _Feedback.solved:
        final last = widget.index == widget.category.koans.length - 1;
        return last && categoryDone
            ? '${l.categoryComplete(widget.category.title.of(context))} ${l.solvedNext}'
            : '${l.solved} ${l.solvedNext}';
      case _Feedback.wrong:
        if (_mistake case final mistake?) return mistake.why.of(context);
        if (_autoSuggested) return l.wrongSuggest;
        return _attempts >= 3 ? l.wrongAgain : l.wrong;
      case _Feedback.numberKind:
        return l.numberKind;
      case _Feedback.empty:
        return l.errorEmpty;
      case _Feedback.unknown:
        return l.errorUnknownName(_unknownName ?? '');
      case _Feedback.revealed:
        return l.answerRevealed;
      case _Feedback.parseError:
        final e = _parseError!;
        return switch (e.kind) {
          ParseErrorKind.empty => l.errorEmpty,
          ParseErrorKind.unexpectedChar => l.errorUnexpectedChar(e.detail),
          ParseErrorKind.unterminatedString => l.errorUnterminatedString,
          ParseErrorKind.unexpectedEnd => l.errorUnexpectedEnd,
          ParseErrorKind.unexpectedToken => l.errorUnexpectedToken(e.detail),
        };
    }
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _FeedbackLine extends StatelessWidget {
  const _FeedbackLine({super.key, required this.feedback, required this.color, required this.icon});

  final String feedback;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(feedback, style: TextStyle(color: color, fontSize: 15, height: 1.4))),
        ],
      );
}

class _KoanDots extends StatelessWidget {
  const _KoanDots({required this.way, required this.category, required this.index});

  final Way way;
  final Category category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            l.koanPosition(index + 1, category.koans.length).toUpperCase(),
            style: const TextStyle(color: Palette.faint, fontSize: 12, letterSpacing: 1.4),
          ),
        ),
        for (var i = 0; i < category.koans.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.go(koanPath(way, category, i)),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == index ? 22 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: state.isSolved(koanKey(way, category, i))
                      ? (i == index ? accent : accent.withValues(alpha: 0.55))
                      : (i == index ? accent.withValues(alpha: 0.25) : Palette.line),
                  border: i == index ? Border.all(color: accent) : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CapstoneBadge extends StatelessWidget {
  const _CapstoneBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.landscape_outlined, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: accent, fontSize: 11.5, letterSpacing: 1.2, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Why the answer is what it is, once the koan is solved.
class _Explanation extends StatelessWidget {
  const _Explanation({required this.text, this.docs});

  final String text;
  final String? docs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      decoration: BoxDecoration(
        color: Palette.jade.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.jade.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.why.toUpperCase(),
            style: const TextStyle(color: Palette.jade, fontSize: 11.5, letterSpacing: 1.4, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 15, height: 1.55)),
          if (docs case final docs?)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Palette.jade,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => launchUrl(Uri.parse(docs), webOnlyWindowName: '_blank'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l.readDocs),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

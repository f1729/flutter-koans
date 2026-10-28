import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'koan_screen.dart';
import 'widgets.dart';

/// Goes through the koans due for review in a Way, one by one.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.way});

  final Way way;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  /// Fixed when the session starts, so reviewing doesn't reshuffle it.
  late final List<(Category, int)> _due;
  var _current = 0;

  @override
  void initState() {
    super.initState();
    _due = [
      for (final key in AppState.read(context).dueReviews(widget.way)) ?_resolve(key),
    ];
  }

  /// `dart/maps/3` to its category and index, if the content still has it.
  (Category, int)? _resolve(String key) {
    final parts = key.split('/');
    if (parts.length != 3) return null;
    final category = widget.way.category(parts[1]);
    final index = int.tryParse(parts[2]);
    if (category == null || index == null || index >= category.koans.length) return null;
    return (category, index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Palette.forWay(widget.way.id);
    final done = _current >= _due.length;
    return Theme(
      data: themeFor(widget.way.id),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Palette.line))),
              child: Row(
                children: [
                  Wordmark(color: accent),
                  const SizedBox(width: 12),
                  Text(widget.way.title.of(context), style: TextStyle(color: accent, fontSize: 14)),
                  const Spacer(),
                  const LanguageToggle(),
                ],
              ),
            ),
            Expanded(
              child: done
                  ? _ReviewDone(way: widget.way)
                  : KoanView(
                      key: ValueKey('review-$_current'),
                      way: widget.way,
                      category: _due[_current].$1,
                      index: _due[_current].$2,
                      review: true,
                      onNext: () => setState(() => _current++),
                      header: _ReviewHeader(
                        progress: l.reviewProgress(_current + 1, _due.length),
                        category: _due[_current].$1.title.of(context),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.progress, required this.category});

  final String progress;
  final String category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.review, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(l.reviewIntro, style: const TextStyle(color: Palette.muted, fontSize: 15, height: 1.5)),
        const SizedBox(height: 20),
        Text(
          '${progress.toUpperCase()}  ·  ${category.toUpperCase()}',
          style: const TextStyle(color: Palette.faint, fontSize: 12, letterSpacing: 1.4),
        ),
      ],
    );
  }
}

class _ReviewDone extends StatelessWidget {
  const _ReviewDone({required this.way});

  final Way way;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppState.of(context);
    final waiting = state.reviews.pending('${way.id}/');
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Enso(size: 96, color: Palette.forWay(way.id)),
              const SizedBox(height: 28),
              Text(l.reviewDone, textAlign: TextAlign.center, style: promptStyle(context).copyWith(fontSize: 28)),
              const SizedBox(height: 14),
              Text(
                l.reviewDoneBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.muted, fontSize: 15, height: 1.6),
              ),
              if (waiting > 0) ...[
                const SizedBox(height: 10),
                Text(l.reviewWaiting(waiting), style: const TextStyle(color: Palette.faint, fontSize: 13)),
              ],
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(wayStartPath(state, way)),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(l.backToWay(way.title.of(context))),
                  ),
                  OutlinedButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A link to the review session, shown wherever reviews are due.
class ReviewLink extends StatelessWidget {
  const ReviewLink({super.key, required this.way, this.dense = false});

  final Way way;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final due = AppState.of(context).dueReviews(way).length;
    if (due == 0) return const SizedBox.shrink();
    final accent = Palette.forWay(way.id);
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: dense ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10) : null,
      ),
      onPressed: () => context.go('/${way.id}/review'),
      icon: const Icon(Icons.replay, size: 18),
      label: Text(AppLocalizations.of(context).reviewDue(due)),
    );
  }
}

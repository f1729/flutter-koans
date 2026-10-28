import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'review_screen.dart';
import 'widgets.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.way, required this.category, required this.index});

  final Way way;
  final Category category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context);
    final accent = Palette.forWay(way.id);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      children: [
        Align(alignment: Alignment.centerLeft, child: ReviewLink(way: way, dense: true)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Text(
            l.categories.toUpperCase(),
            style: const TextStyle(color: Palette.faint, fontSize: 12, letterSpacing: 1.4),
          ),
        ),
        for (final c in way.categories)
          _CategoryTile(
            title: c.title.of(context),
            solved: state.solvedIn(way, c),
            total: c.koans.length,
            selected: c == category,
            accent: accent,
            onTap: () {
              Scaffold.maybeOf(context)?.closeDrawer();
              context.go(c == category ? koanPath(way, c, index) : _entry(state, way, c));
            },
          ),
      ],
    );
  }

  /// The first unsolved koan of a category, or its first koan.
  static String _entry(AppState state, Way way, Category c) {
    for (var i = 0; i < c.koans.length; i++) {
      if (!state.isSolved(koanKey(way, c, i))) return koanPath(way, c, i);
    }
    return koanPath(way, c, 0);
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.solved,
    required this.total,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final int solved;
  final int total;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = solved == total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? Palette.raised : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Enso(size: 22, color: done ? Palette.jade : accent, progress: solved / total),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected ? Palette.text : Palette.muted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '$solved/$total',
                  style: const TextStyle(color: Palette.faint, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

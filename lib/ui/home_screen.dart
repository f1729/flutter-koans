import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../content/ways.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'review_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
                const Align(alignment: Alignment.centerRight, child: LanguageToggle()),
                const SizedBox(height: 48),
                const Enso(size: 96),
                const SizedBox(height: 28),
                Text(
                  l.appTitle,
                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(l.homeTagline, textAlign: TextAlign.center, style: promptStyle(context)),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    l.homeIntro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Palette.muted, fontSize: 16, height: 1.6),
                  ),
                ),
                const SizedBox(height: 56),
                Text(
                  l.chooseYourWay.toUpperCase(),
                  style: const TextStyle(color: Palette.faint, fontSize: 13, letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [for (final way in ways) _WayCard(way: way)],
                ),
                const SizedBox(height: 64),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WayCard extends StatefulWidget {
  const _WayCard({required this.way});

  final Way way;

  @override
  State<_WayCard> createState() => _WayCardState();
}

class _WayCardState extends State<_WayCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context);
    final way = widget.way;
    final accent = Palette.forWay(way.id);
    final solved = state.solvedIn(way);
    final total = way.koanCount;
    final label = solved == 0
        ? l.begin
        : solved == total
            ? l.walkAgain
            : l.continueWay;
    void open() => context.go(wayStartPath(state, way));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _hovered ? Palette.raised : Palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _hovered ? accent.withValues(alpha: 0.6) : Palette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Enso(size: 44, color: accent, progress: total == 0 ? 0 : solved / total),
                  const Spacer(),
                  Text(
                    l.categoryCount(way.categories.length),
                    style: const TextStyle(color: Palette.faint, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                way.title.of(context),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: Text(
                  way.tagline.of(context),
                  style: const TextStyle(color: Palette.muted, fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : solved / total,
                  minHeight: 4,
                  color: accent,
                  backgroundColor: Palette.line,
                ),
              ),
              const SizedBox(height: 10),
              Text(l.koanCount(solved, total), style: const TextStyle(color: Palette.faint, fontSize: 13)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Theme(
                    data: themeFor(way.id),
                    child: FilledButton.icon(
                      onPressed: total == 0 ? null : open,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(label),
                    ),
                  ),
                  ReviewLink(way: way),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(l.inspiredBy, style: const TextStyle(color: Palette.faint, fontSize: 13)),
        const Text('·', style: TextStyle(color: Palette.faint)),
        TextButton(
          onPressed: () => _confirmReset(context),
          child: Text(l.resetProgress, style: const TextStyle(fontSize: 13)),
        ),
        const Text('·', style: TextStyle(color: Palette.faint)),
        Text(l.privacyNote, style: const TextStyle(color: Palette.faint, fontSize: 13)),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = AppState.read(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surface,
        content: Text(l.resetProgressConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Palette.ember),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (ok ?? false) state.reset();
  }
}

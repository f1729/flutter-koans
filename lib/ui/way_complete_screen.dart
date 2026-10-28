import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../content/ways.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'widgets.dart';

class WayCompleteScreen extends StatelessWidget {
  const WayCompleteScreen({super.key, required this.way});

  final Way way;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppState.of(context);
    final accent = Palette.forWay(way.id);
    final others = ways.where((w) => w != way && w.koanCount > 0);
    return Theme(
      data: themeFor(way.id),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Enso(size: 120, color: accent),
                  const SizedBox(height: 36),
                  Text(l.wayComplete, textAlign: TextAlign.center, style: promptStyle(context).copyWith(fontSize: 30)),
                  const SizedBox(height: 16),
                  Text(
                    l.wayCompleteBody(way.title.of(context)),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Palette.muted, fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final other in others)
                        Theme(
                          data: themeFor(other.id),
                          child: FilledButton.icon(
                            onPressed: () => context.go(wayStartPath(state, other)),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: Text(l.walkOtherWay(other.title.of(context))),
                          ),
                        ),
                      OutlinedButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

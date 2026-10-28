import 'package:flutter/material.dart';

import '../app_state.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'code_view.dart' show Peek;
import 'layout_inspector.dart';
import 'widgets.dart';

const previewSize = Size(320, 240);

/// The learner's live result next to the goal.
class PreviewPair extends StatelessWidget {
  const PreviewPair({super.key, required this.koan, required this.controllers, this.peek});

  final Koan koan;
  final List<TextEditingController> controllers;

  /// A suggestion being browsed, shown in place of what is typed in its blank.
  final ValueNotifier<Peek?>? peek;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = AppState.of(context);
    final goal = koan.valuesFor(koan.answers)!;
    final layout = state.showLayout;
    return ListenableBuilder(
      listenable: Listenable.merge([...controllers, ?peek]),
      builder: (context, _) {
        final peeking = peek?.value;
        final values = koan.valuesFor([
          for (final (i, c) in controllers.indexed)
            peeking != null && peeking.blank == i ? peeking.text : c.text,
        ]);
        final goalPreview = _safely(() => koan.preview!(goal));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _PreviewFrame(
                  label: l.yours,
                  layout: layout,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (values == null)
                        _Empty(text: l.previewInvalid)
                      else
                        _safely(() => koan.preview!(values)),
                      // The goal, faintly on top: differences stand out.
                      if (state.compareGoal)
                        IgnorePointer(child: Opacity(opacity: 0.35, child: goalPreview)),
                    ],
                  ),
                ),
                _PreviewFrame(label: l.goal, layout: layout, child: goalPreview),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _Toggle(
                  icon: Icons.grid_on,
                  label: l.showLayout,
                  value: layout,
                  onChanged: (v) => state.showLayout = v,
                ),
                _Toggle(
                  icon: Icons.layers_outlined,
                  label: l.compareGoal,
                  value: state.compareGoal,
                  onChanged: (v) => state.compareGoal = v,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// A wrong-typed answer may make the builder throw; show calm instead.
  Widget _safely(Widget Function() build) {
    try {
      return build();
    } on Object {
      return const PreviewPlaceholder();
    }
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return FilterChip(
      avatar: Icon(icon, size: 16, color: value ? accent : Palette.muted),
      label: Text(label),
      selected: value,
      showCheckmark: false,
      onSelected: onChanged,
      labelStyle: TextStyle(fontSize: 13, color: value ? Palette.text : Palette.muted),
      backgroundColor: Palette.surface,
      selectedColor: accent.withValues(alpha: 0.14),
      side: BorderSide(color: value ? accent.withValues(alpha: 0.5) : Palette.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.label, required this.layout, required this.child});

  final String label;
  final bool layout;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Palette.faint, fontSize: 12, letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          Container(
            width: previewSize.width,
            height: previewSize.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Palette.line),
            ),
            // Previews render on paper, in a light theme, like a device would.
            child: Theme(
              data: ThemeData(useMaterial3: true, colorSchemeSeed: Palette.flutter, fontFamily: 'Inter'),
              child: Material(
                color: const Color(0xFFF6F3EC),
                child: RepaintBoundary(child: LayoutInspector(enabled: layout, child: child)),
              ),
            ),
          ),
        ],
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8A877F), fontSize: 14),
          ),
        ),
      );
}

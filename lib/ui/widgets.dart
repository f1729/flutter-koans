import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';

/// An ensō: the brush-drawn circle of Zen, left open.
class Enso extends StatelessWidget {
  const Enso({super.key, this.size = 72, this.color = Palette.dart, this.progress = 1});

  final double size;
  final Color color;

  /// How much of the circle is drawn, from 0 to 1.
  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _EnsoPainter(color, progress),
      );
}

class _EnsoPainter extends CustomPainter {
  _EnsoPainter(this.color, this.progress);

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 9;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.35,
    );
    if (progress <= 0) return;
    const start = -math.pi / 2 + 0.35;
    final sweep = (math.pi * 2 - 0.7) * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      arc,
      start,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: const GradientRotation(start),
          colors: [color.withValues(alpha: 0.35), color, color.withValues(alpha: 0.85)],
          stops: const [0, 0.6, 1],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_EnsoPainter old) =>
      old.color != color || old.progress != progress;
}

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    return Tooltip(
      message: AppLocalizations.of(context).language,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          side: const BorderSide(color: Palette.line),
          selectedBackgroundColor: Palette.raised,
          selectedForegroundColor: Palette.text,
          foregroundColor: Palette.muted,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        segments: const [
          ButtonSegment(value: 'en', label: Text('EN')),
          ButtonSegment(value: 'id', label: Text('ID')),
        ],
        selected: {state.locale.languageCode},
        onSelectionChanged: (s) => state.locale = Locale(s.single),
      ),
    );
  }
}

/// The wordmark, linking home.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.color = Palette.dart});

  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go('/'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Enso(size: 22, color: color),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).appTitle,
                style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
      );
}

class PreviewPlaceholder extends StatelessWidget {
  const PreviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Icon(Icons.blur_on, color: Palette.faint, size: 28),
      );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Enso(size: 64, progress: 0.3),
            const SizedBox(height: 24),
            Text(l.notFound, style: promptStyle(context)),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: () => context.go('/'), child: Text(l.backHome)),
          ],
        ),
      ),
    );
  }
}

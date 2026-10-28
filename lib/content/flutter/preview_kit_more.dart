/// More building blocks for Flutter koan previews: making constraints
/// visible, and showing layout failures calmly instead of really failing.
library;

import 'package:flutter/material.dart';

import 'preview_kit.dart';

/// A number as a short label: `120`, `0.5` or `∞`.
String shortNum(double v) {
  if (v.isInfinite) return '∞';
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/// The constraints in a few characters: `160 × 80` when tight, otherwise
/// the ranges, such as `w 0–160 · h 0–80`.
String describeConstraints(BoxConstraints c) {
  String range(double min, double max) =>
      min == max ? shortNum(min) : '${shortNum(min)}–${shortNum(max)}';
  if (c.isTight) return '${shortNum(c.maxWidth)} × ${shortNum(c.maxHeight)}';
  return 'w ${range(c.minWidth, c.maxWidth)} · h ${range(c.minHeight, c.maxHeight)}';
}

/// A labelled box that shows, beneath its label, the constraints it was
/// given. Like [Box], it hugs its label unless the constraints insist.
class ConstraintsBox extends StatelessWidget {
  const ConstraintsBox(this.label, {super.key, this.color = kSky});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  describeConstraints(constraints),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [child] as if laid out with unlimited height, cut off at the
/// bottom by the yellow and black stripes Flutter paints on overflow, but
/// without raising a real overflow error.
class FakeOverflow extends StatelessWidget {
  const FakeOverflow({
    super.key,
    required this.child,
    this.label = 'BOTTOM OVERFLOWED',
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: double.infinity,
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 18,
          child: CustomPaint(
            painter: const _Stripes(),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFFD32F2F),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stripes extends CustomPainter {
  const _Stripes();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFD600),
    );
    final black = Paint()..color = const Color(0xFF212121);
    for (var x = -size.height; x < size.width; x += 16) {
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height)
          ..lineTo(x + 8, size.height)
          ..lineTo(x + 8 + size.height, 0)
          ..lineTo(x + size.height, 0)
          ..close(),
        black,
      );
    }
  }

  @override
  bool shouldRepaint(_Stripes oldDelegate) => false;
}

/// A calm card standing in for an error Flutter would really throw.
class ErrorCard extends StatelessWidget {
  const ErrorCard(this.message, {super.key, this.title = 'Flutter error'});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kRose),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: Color(0xFFB3261E),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFB3261E),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: kInk, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/// A small, quiet caption, such as "Tap to change".
class Caption extends StatelessWidget {
  const Caption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11, color: kInk.withValues(alpha: 0.55)),
  );
}

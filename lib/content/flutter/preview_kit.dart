/// Small building blocks shared by the Flutter koan previews.
///
/// Previews cast the learner's values eagerly (`values[0] as Alignment`) so a
/// wrong type throws while the preview is being built, where the UI catches
/// it, and clamp numbers so no answer can break layout.
library;

import 'package:flutter/material.dart';

const kRose = Color(0xFFE0707A);
const kSky = Color(0xFF5B8DEF);
const kSage = Color(0xFF4FAE93);
const kSand = Color(0xFFE2B04F);
const kInk = Color(0xFF2E3440);
const kMist = Color(0xFFF4F2ED);
const kFrame = Color(0xFFE6E2D8);

const _byLabel = {'A': kRose, 'B': kSky, 'C': kSage, 'D': kSand};

/// The fixed size every preview is drawn at, scaled down when space is short.
const previewSize = Size(280, 200);

/// A calm, rounded surface that every preview is drawn on.
class PreviewCanvas extends StatelessWidget {
  const PreviewCanvas({super.key, required this.child, this.padding = 12});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox.fromSize(
        size: previewSize,
        child: Material(
          color: kMist,
          borderRadius: BorderRadius.circular(16),
          // Keeps the font of the surrounding theme, which Material's own
          // textStyle would otherwise drop.
          textStyle: TextStyle(
            color: kInk,
            fontSize: 14,
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
          ),
          child: Padding(padding: EdgeInsets.all(padding), child: child),
        ),
      ),
    );
  }
}

/// A faint outlined area that shows the bounds of a parent widget.
class Frame extends StatelessWidget {
  const Frame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kFrame,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kInk.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

/// A rounded, labelled box. Without a size it hugs its label, unless its
/// parent insists otherwise (as Expanded or stretch do).
class Box extends StatelessWidget {
  const Box(this.label, {super.key, this.color, this.width, this.height});

  final String label;
  final Color? color;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? _byLabel[label] ?? kSky;
    final onFill = fill.computeLuminance() > 0.45 ? kInk : Colors.white;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: onFill,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// A counter that adds [step] on every tap.
class TapCounter extends StatefulWidget {
  const TapCounter({super.key, required this.step});

  final int step;

  @override
  State<TapCounter> createState() => _TapCounterState();
}

class _TapCounterState extends State<TapCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_count',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w300,
              color: kInk,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonal(
                onPressed: () => setState(() => _count += widget.step),
                child: const Text('Tap'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _count = 0),
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A round portrait with an initial, standing in for a photo.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.initial = 'R',
    this.size = 48,
    this.color = kSky,
    this.shape = BoxShape.circle,
  });

  final String initial;
  final double size;
  final Color color;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: shape),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A like button that starts [liked] or not, and on each tap toggles the
/// like and adds [onLike] or [onUnlike] to the count.
///
/// Starts over whenever its configuration changes, so a preview follows the
/// learner's answers as they type.
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.liked,
    required this.likes,
    required this.onLike,
    required this.onUnlike,
  });

  final bool liked;
  final int likes;
  final int onLike;
  final int onUnlike;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _liked = widget.liked;
  late int _likes = widget.likes;

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.liked != oldWidget.liked ||
        widget.likes != oldWidget.likes ||
        widget.onLike != oldWidget.onLike ||
        widget.onUnlike != oldWidget.onUnlike) {
      _liked = widget.liked;
      _likes = widget.likes;
    }
  }

  void _toggle() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? widget.onLike : widget.onUnlike;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 44,
            onPressed: _toggle,
            icon: Icon(
              _liked ? Icons.favorite : Icons.favorite_border,
              color: _liked ? kRose : kInk.withValues(alpha: 0.55),
            ),
          ),
          Text(
            '$_likes',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: kInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// EdgeInsets with every side clamped to [max], or a cast error if [v] is not
/// an EdgeInsetsGeometry.
EdgeInsets insetsOf(Object? v, {double max = 40}) {
  final e = (v as EdgeInsetsGeometry).resolve(TextDirection.ltr);
  double c(double d) => d.isNaN ? 0 : d.clamp(0, max);
  return EdgeInsets.fromLTRB(c(e.left), c(e.top), c(e.right), c(e.bottom));
}

/// A finite number within [min] and [max], or a cast error if [v] is not one.
double px(Object? v, {double min = 0, double max = 260}) {
  final d = (v as num).toDouble();
  return d.isNaN ? min : d.clamp(min, max);
}

/// A flex factor within a range that keeps previews readable.
int flexOf(Object? v, {int min = 1, int max = 12}) =>
    (v as int).clamp(min, max);

/// Whether [v] is a number equal to [n], whether typed as int or double.
bool isNum(Object? v, num n) => v is num && v == n;

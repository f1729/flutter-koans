import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Draws every box in [child]'s layout: an outline, its size, and shaded
/// padding. Flutter's own debug paint only exists in debug builds, and a
/// learner needs to see "24 pixels of padding" more than anyone.
class LayoutInspector extends SingleChildRenderObjectWidget {
  const LayoutInspector({super.key, required this.enabled, required super.child});

  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderLayoutInspector(enabled);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderLayoutInspector).enabled = enabled;
  }
}

const _outline = Color(0xCC2F7DD1);
const _paddingFill = Color(0x40F2A23C);
const _labelBackground = Color(0xE62F7DD1);

class _RenderLayoutInspector extends RenderProxyBox {
  _RenderLayoutInspector(this._enabled);

  bool _enabled;
  set enabled(bool value) {
    if (value == _enabled) return;
    _enabled = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!_enabled || child == null) return;
    final canvas = context.canvas;
    final labelled = <Rect>[];
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _outline;

    void visit(RenderObject node, Rect parent) {
      var rect = parent;
      if (node is RenderBox && node.hasSize) {
        rect = MatrixUtils.transformRect(node.getTransformTo(this), Offset.zero & node.size).shift(offset);
        if (node is RenderPadding && (node.child?.hasSize ?? false)) {
          final inner = MatrixUtils.transformRect(
            node.child!.getTransformTo(this),
            Offset.zero & node.child!.size,
          ).shift(offset);
          canvas.drawDRRect(
            RRect.fromRectAndRadius(rect, Radius.zero),
            RRect.fromRectAndRadius(inner, Radius.zero),
            Paint()..color = _paddingFill,
          );
        }
        // Wrappers the same size as their parent would only repeat its label.
        if (!_same(rect, parent)) {
          canvas.drawRect(rect.deflate(0.5), outline);
          if (rect.width >= 64 && rect.height >= 40 && !labelled.any((r) => _same(r, rect))) {
            labelled.add(rect);
            _label(canvas, rect, '${_n(node.size.width)}×${_n(node.size.height)}');
          }
        }
      }
      node.visitChildren((c) => visit(c, rect));
    }

    child!.visitChildren((c) => visit(c, offset & size));
  }

  static bool _same(Rect a, Rect b) =>
      (a.left - b.left).abs() < 0.5 &&
      (a.top - b.top).abs() < 0.5 &&
      (a.width - b.width).abs() < 0.5 &&
      (a.height - b.height).abs() < 0.5;

  static String _n(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static void _label(Canvas canvas, Rect rect, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.5, color: Color(0xFFFFFFFF), height: 1.2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = Rect.fromLTWH(rect.left, rect.top, painter.width + 6, painter.height + 2);
    canvas.drawRect(box, Paint()..color = _labelBackground);
    painter.paint(canvas, box.topLeft + const Offset(3, 1));
  }
}

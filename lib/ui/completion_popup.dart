import 'package:flutter/material.dart';

import '../engine/completion.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';

/// The suggestion list under a blank, styled after an editor's.
class CompletionPopup extends StatefulWidget {
  const CompletionPopup({
    super.key,
    required this.items,
    required this.highlighted,
    required this.showEmptyMessage,
    this.maxVisible = visibleItems,
    required this.onHover,
    required this.onSelect,
  });

  final List<Completion> items;
  final int highlighted;

  /// Whether to explain an empty list instead of showing nothing.
  final bool showEmptyMessage;

  /// How many rows show before the list scrolls.
  final int maxVisible;
  final ValueChanged<int> onHover;
  final ValueChanged<int> onSelect;

  static const itemHeight = 32.0;
  static const visibleItems = 8;

  @override
  State<CompletionPopup> createState() => _CompletionPopupState();
}

const _itemHeight = CompletionPopup.itemHeight;


class _CompletionPopupState extends State<CompletionPopup> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(CompletionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlighted != widget.highlighted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls just enough to keep the highlighted item in view.
  void _reveal() {
    if (!_scroll.hasClients) return;
    final top = widget.highlighted * _itemHeight + 4;
    final view = _scroll.position.viewportDimension;
    if (top < _scroll.offset) {
      _scroll.jumpTo(top);
    } else if (top + _itemHeight > _scroll.offset + view) {
      _scroll.jumpTo(top + _itemHeight - view);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (widget.items.isEmpty && !widget.showEmptyMessage) return const SizedBox.shrink();
    return Material(
      color: Palette.raised,
      elevation: 12,
      shadowColor: Colors.black,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 480),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: widget.items.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: Text(l.noSuggestions, style: const TextStyle(color: Palette.muted, fontSize: 13)),
              )
            : IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: _itemHeight * widget.maxVisible + 8),
                      // Not a ListView: the popup sizes itself to its widest
                      // label, and viewports can't report intrinsic widths.
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (i, item) in widget.items.indexed)
                              SizedBox(
                                height: _itemHeight,
                                child: _Item(
                                  completion: item,
                                  highlighted: i == widget.highlighted,
                                  onHover: () => widget.onHover(i),
                                  onTap: () => widget.onSelect(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Palette.line))),
                      child: Text(
                        l.suggestionsFooter,
                        style: const TextStyle(color: Palette.faint, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.completion,
    required this.highlighted,
    required this.onHover,
    required this.onTap,
  });

  final Completion completion;
  final bool highlighted;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final (letter, color) = _badge(completion.kind);
    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: highlighted ? accent.withValues(alpha: 0.16) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  letter,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  completion.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: codeStyle(size: 13.5, color: highlighted ? Palette.text : Palette.muted)
                      .copyWith(height: 1.2),
                ),
              ),
              if (completion.detail case final detail?) ...[
                const SizedBox(width: 24),
                Text(detail, style: codeStyle(size: 12, color: Palette.faint).copyWith(height: 1.2)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// IDE-style kind badges, coloured like the syntax highlighting.
  static (String, Color) _badge(CompletionKind kind) => switch (kind) {
        CompletionKind.value => ('V', const Color(0xFFF2A97B)),
        CompletionKind.constructor => ('N', const Color(0xFF7FD1AE)),
        CompletionKind.type => ('C', const Color(0xFF7FD1AE)),
        CompletionKind.keyword => ('K', const Color(0xFFC79BF2)),
        CompletionKind.method => ('M', const Color(0xFF82B8FF)),
        CompletionKind.property => ('P', const Color(0xFFE6C07B)),
      };
}

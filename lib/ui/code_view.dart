import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/completion.dart';
import '../engine/koan.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme.dart';
import 'completion_popup.dart';
import 'dart_highlighter.dart';

enum BlankStatus { idle, error, solved }

/// A suggestion being browsed: which blank, and the text to preview in it.
typedef Peek = ({int blank, String text});

/// What an empty blank hints at; see [blankHintFor].
typedef BlankHint = ({String? type, CompletionKind? kind});

/// The keyboard shortcut for suggestions. On macOS, Ctrl+Space usually
/// switches input source before the browser sees it, so ⌥Esc works too.
String suggestShortcut() =>
    defaultTargetPlatform == TargetPlatform.macOS ? '⌥Esc' : 'Ctrl+Space';

/// Highlighted koan code where every blank is an inline text field.
class KoanCode extends StatelessWidget {
  const KoanCode({
    super.key,
    required this.code,
    required this.controllers,
    required this.focusNodes,
    required this.statuses,
    required this.onSubmit,
    this.completions,
    this.hints,
    this.registry = Registry.core,
    this.peek,
    this.fieldKeys,
    this.suggestAbove = false,
    this.readOnly = false,
  });

  final String code;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<BlankStatus> statuses;
  final VoidCallback onSubmit;

  /// Suggestions for each blank; see [completionsFor].
  final List<List<Completion>>? completions;

  /// What each empty blank hints at, like an editor's type hint.
  final List<BlankHint?>? hints;

  /// Resolves `Type.` prefixes typed by the learner into suggestions.
  final Registry registry;

  /// Set while a suggestion is highlighted, so a preview can show it.
  final ValueNotifier<Peek?>? peek;
  final List<GlobalKey<BlankFieldState>>? fieldKeys;

  /// Open suggestions above the blanks when there is room, to keep a live
  /// preview below them in sight while browsing.
  final bool suggestAbove;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final style = codeStyle();
    var blank = 0;
    final spans = <InlineSpan>[
      for (final token in tokenizeDart(code))
        if (token.kind == TokenKind.blank)
          _blankSpan(blank++, style)
        else
          TextSpan(
            text: token.text,
            style: style.copyWith(
              color: colorFor(token.kind),
              fontStyle: token.kind == TokenKind.comment ? FontStyle.italic : null,
            ),
          ),
    ];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.line),
      ),
      // Tab walks the blanks in code order before leaving the snippet; the
      // default reading order would wander into the sidebar.
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Text.rich(TextSpan(children: spans), softWrap: false),
        ),
      ),
    );
  }

  InlineSpan _blankSpan(int i, TextStyle style) => WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: FocusTraversalOrder(
          order: NumericFocusOrder(i.toDouble()),
          child: BlankField(
            key: fieldKeys?[i],
            index: i,
            controller: controllers[i],
            focusNode: focusNodes[i],
            status: statuses[i],
            style: style,
            readOnly: readOnly,
            onSubmit: onSubmit,
            completions: completions?[i] ?? const [],
            hint: hints?[i],
            registry: registry,
            peek: peek,
            suggestAbove: suggestAbove,
          ),
        ),
      );
}

class BlankField extends StatefulWidget {
  const BlankField({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.status,
    required this.style,
    required this.readOnly,
    required this.onSubmit,
    required this.completions,
    required this.registry,
    this.hint,
    this.peek,
    this.suggestAbove = false,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final BlankStatus status;
  final TextStyle style;
  final bool readOnly;
  final VoidCallback onSubmit;
  final List<Completion> completions;
  final Registry registry;
  final BlankHint? hint;
  final ValueNotifier<Peek?>? peek;
  final bool suggestAbove;

  @override
  State<BlankField> createState() => BlankFieldState();
}

class BlankFieldState extends State<BlankField> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();

  List<Completion> _items = const [];
  var _highlight = 0;

  /// Opened by Ctrl+Space or the Suggestions button rather than by typing,
  /// so an empty result is worth explaining.
  var _explicit = false;
  var _above = false;
  var _maxVisible = CompletionPopup.visibleItems;
  late String _lastText;

  /// Set while we change the text ourselves, so it doesn't reopen the list.
  var _accepting = false;
  DateTime? _acceptedAt;

  bool get _open => _portal.isShowing;

  @override
  void initState() {
    super.initState();
    _lastText = widget.controller.text;
    _attach(widget.controller, widget.focusNode);
  }

  @override
  void didUpdateWidget(BlankField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller || oldWidget.focusNode != widget.focusNode) {
      _detach(oldWidget.controller, oldWidget.focusNode);
      _attach(widget.controller, widget.focusNode);
    }
  }

  @override
  void dispose() {
    _detach(widget.controller, widget.focusNode);
    super.dispose();
  }

  void _attach(TextEditingController c, FocusNode f) {
    c.addListener(_onText);
    f.addListener(_onFocus);
    f.onKeyEvent = _onKey;
  }

  void _detach(TextEditingController c, FocusNode f) {
    c.removeListener(_onText);
    f.removeListener(_onFocus);
    if (f.onKeyEvent == _onKey) f.onKeyEvent = null;
  }

  /// Opens the suggestions, as Ctrl+Space does.
  void showSuggestions() {
    widget.focusNode.requestFocus();
    _show(explicit: true);
  }

  /// What is typed, when it could be the start of a suggestion, such as
  /// `MainAxisAlignment.ce`; null for anything else, like `EdgeInsets.all(2`.
  String? get _query {
    final text = widget.controller.text.trim();
    return RegExp(r'^\.?([A-Za-z_$][A-Za-z0-9_$.]*)?$').hasMatch(text) ? text : null;
  }

  /// Dot shorthand (`.tight`) is being typed, so filter and insert members.
  bool get _shorthand => _query?.startsWith('.') ?? false;

  List<Completion> _source(String query) {
    // Typing `Type.` asks about that type, whatever the blank expects.
    if (query.contains('.')) {
      final byType = completionsForPrefix(query.substring(0, query.lastIndexOf('.')), widget.registry);
      if (byType.isNotEmpty) return byType;
    }
    return widget.completions;
  }

  /// The suggestions to show, and which one to highlight. Asking explicitly
  /// always lists everything that fits the blank, with the current choice
  /// highlighted, so a filled blank can be changed rather than added to.
  (List<Completion>, int) _matches({required bool explicit}) {
    final typed = _query;
    // `.ti` looks for members named `ti…` among the blank's own suggestions.
    final query = typed != null && typed.startsWith('.') ? typed.substring(1) : typed;
    final source = _shorthand
        ? [for (final c in widget.completions) if (c.label.contains('.')) c]
        : _source(query ?? '');
    final filtered = query == null ? const <Completion>[] : filterCompletions(source, query);
    if (!explicit) return (filtered, 0);
    final current = source.indexWhere((c) => c.text == typed || _member(c).text == typed);
    if (filtered.isEmpty || current >= 0) return (source, current < 0 ? 0 : current);
    return (filtered, 0);
  }

  void _show({required bool explicit}) {
    if (widget.readOnly) return;
    final (items, highlight) = _matches(explicit: explicit);
    if (items.isEmpty && !explicit) {
      _hide();
      return;
    }
    setState(() {
      _items = items;
      _highlight = highlight;
      _explicit = explicit;
      final fit = widget.suggestAbove ? _rowsAbove() : 0;
      // Above, the list may shrink and scroll; a sliver of one is no use.
      _above = fit >= 3;
      _maxVisible = _above ? fit.clamp(3, CompletionPopup.visibleItems) : CompletionPopup.visibleItems;
    });
    _portal.show();
    _peekHighlighted();
  }

  /// How many rows of suggestions fit between this blank and the top bar.
  int _rowsAbove() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return 0;
    final top = box.localToGlobal(Offset.zero).dy;
    const topBar = 60.0, footer = 32.0, gap = 12.0, padding = 8.0;
    return ((top - topBar - gap - footer - padding) / CompletionPopup.itemHeight).floor();
  }

  void _hide() {
    if (_open) setState(_portal.hide);
    if (widget.peek?.value?.blank == widget.index) widget.peek!.value = null;
  }

  void _peekHighlighted() {
    if (_items.isEmpty) return;
    widget.peek?.value = (blank: widget.index, text: _items[_highlight].previewText);
  }

  void _onFocus() {
    if (!widget.focusNode.hasFocus) _hide();
  }

  void _onText() {
    final text = widget.controller.text;
    if (text == _lastText || _accepting) {
      _lastText = text;
      return;
    }
    _lastText = text;
    // Keep filtering as the learner types, and close once nothing fits.
    final (items, _) = _matches(explicit: false);
    if (_open) {
      // Nothing left to choose once the only match is exactly what is typed.
      if (items.isEmpty || (items.length == 1 && _isTyped(items.single) && !_explicit)) {
        _hide();
      } else {
        setState(() {
          _items = items;
          _highlight = 0;
        });
        _peekHighlighted();
      }
      return;
    }
    // Like an editor: suggest while a name is being typed, unless the only
    // match is exactly what is already there.
    final query = _query;
    if (query == null || query.isEmpty) return;
    if (items.isNotEmpty && !(items.length == 1 && _isTyped(items.single))) {
      _show(explicit: false);
    }
  }

  void _move(int delta) {
    if (_items.isEmpty) return;
    setState(() => _highlight = (_highlight + delta) % _items.length);
    _peekHighlighted();
  }

  /// [c] as dot shorthand: `FlexFit.tight` becomes `.tight`.
  static Completion _member(Completion c) {
    if (!c.label.contains('.')) return c;
    final type = c.label.substring(0, c.label.lastIndexOf('.'));
    return Completion(c.label, c.kind, insert: c.insert.substring(type.length), detail: c.detail, sample: c.sample);
  }

  /// A blank holds one value, so a suggestion replaces whatever is there,
  /// keeping to dot shorthand if that is what the learner was typing.
  void _accept(Completion c) {
    final chosen = _shorthand ? _member(c) : c;
    _accepting = true;
    widget.controller.value = TextEditingValue(
      text: chosen.text,
      selection: TextSelection.collapsed(offset: chosen.caret),
    );
    _accepting = false;
    _acceptedAt = DateTime.now();
    _hide();
  }

  /// Whether [c] is exactly what the blank already holds.
  bool _isTyped(Completion c) {
    final typed = widget.controller.text.trim();
    return c.text == typed || _member(c).text == typed;
  }

  void _submit() {
    if (_open && _items.isNotEmpty) {
      // Choosing what is already typed would change nothing: check it instead.
      if (_isTyped(_items[_highlight])) {
        _hide();
        widget.onSubmit();
        return;
      }
      _accept(_items[_highlight]);
      return;
    }
    // The Enter that accepted a suggestion may also arrive as a submit.
    final accepted = _acceptedAt;
    if (accepted != null && DateTime.now().difference(accepted) < const Duration(milliseconds: 300)) {
      return;
    }
    _hide();
    widget.onSubmit();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final keyboard = HardwareKeyboard.instance;
    if (event is KeyDownEvent &&
        ((key == LogicalKeyboardKey.space && keyboard.isControlPressed) ||
            (key == LogicalKeyboardKey.escape && keyboard.isAltPressed))) {
      _show(explicit: true);
      return KeyEventResult.handled;
    }
    if (!_open) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _hide();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        _items.isNotEmpty &&
        (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.tab)) {
      if (_isTyped(_items[_highlight])) {
        // Already there: let Enter check the answer and Tab move on.
        _hide();
        return KeyEventResult.ignored;
      }
      _accept(_items[_highlight]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The type a blank expects (`FlexFit`), or the kind of word (`keyword`).
  String? _hintText(AppLocalizations l) {
    final hint = widget.hint;
    if (hint == null || widget.readOnly) return null;
    if (hint.type case final type?) return type;
    return switch (hint.kind) {
      CompletionKind.keyword => l.kindKeyword,
      CompletionKind.type => l.kindType,
      CompletionKind.method => l.kindMethod,
      CompletionKind.property => l.kindProperty,
      CompletionKind.value => l.kindValue,
      CompletionKind.constructor => l.kindConstructor,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final color = switch (widget.status) {
      BlankStatus.idle => accent,
      BlankStatus.error => Palette.ember,
      BlankStatus.solved => Palette.jade,
    };
    // Explicit letterSpacing: TextField would otherwise inherit bodyLarge's.
    final fieldStyle = widget.style.copyWith(height: 1.2, color: Palette.text, letterSpacing: 0);
    final hintText = widget.hint == null ? null : _hintText(AppLocalizations.of(context));
    final hintStyle = fieldStyle.copyWith(color: Palette.faint, fontStyle: FontStyle.italic);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: _above ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(0, _above ? -6 : 6),
          // Clicking the list must not count as clicking outside the field.
          child: TextFieldTapRegion(
            child: CompletionPopup(
              items: _items,
              highlighted: _highlight,
              showEmptyMessage: _explicit,
              maxVisible: _maxVisible,
              onHover: (i) {
                if (i == _highlight) return;
                setState(() => _highlight = i);
                _peekHighlighted();
              },
              onSelect: (i) => _accept(_items[i]),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.controller, widget.focusNode]),
          builder: (context, _) {
            final text = widget.controller.text;
            // Grow with the answer (or the hint), in the monospace font.
            final painter = TextPainter(
              text: TextSpan(
                text: text.isEmpty && hintText != null
                    ? hintText
                    : text.length < 3
                        ? '___'
                        : text,
                style: fieldStyle,
              ),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout();
            final focused = widget.focusNode.hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: painter.width + 36,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: focused ? 0.16 : 0.09),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: color.withValues(alpha: focused ? 0.9 : 0.45),
                  width: focused ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                readOnly: widget.readOnly,
                style: fieldStyle,
                cursorColor: color,
                textAlign: TextAlign.center,
                autocorrect: false,
                enableSuggestions: false,
                smartQuotesType: SmartQuotesType.disabled,
                smartDashesType: SmartDashesType.disabled,
                textInputAction: TextInputAction.done,
                // Replaces the default unfocus-on-Enter, keeping the caret here.
                onEditingComplete: _submit,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  hintText: hintText,
                  hintStyle: hintStyle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

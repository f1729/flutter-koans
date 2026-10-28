import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_koans/content/flutter/registry.dart';
import 'package:flutter_koans/engine/completion.dart';
import 'package:flutter_koans/engine/koan.dart';
import 'package:flutter_koans/l10n/gen/app_localizations.dart';
import 'package:flutter_koans/ui/code_view.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  _Harness(String answer) {
    koan = Koan(
      prompt: const Tr('', ''),
      code: 'Row(mainAxisAlignment: __)',
      answers: [answer],
      registry: flutterRegistry,
    );
  }

  late final Koan koan;
  final controller = TextEditingController();
  final focus = FocusNode();
  final peek = ValueNotifier<Peek?>(null);
  final key = GlobalKey<BlankFieldState>();
  var submits = 0;

  Widget build({List<BlankHint?>? hints}) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: KoanCode(
            code: koan.code,
            controllers: [controller],
            focusNodes: [focus],
            statuses: const [BlankStatus.idle],
            onSubmit: () => submits++,
            completions: [completionsFor(koan, 0)],
            hints: hints,
            registry: flutterRegistry,
            peek: peek,
            fieldKeys: [key],
          ),
        ),
      );
}

Future<void> ctrlSpace(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.space);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

void main() {
  testWidgets('Ctrl+Space lists, arrows peek, Enter accepts without submitting', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    h.focus.requestFocus();
    await tester.pump();

    await ctrlSpace(tester);
    expect(find.text('MainAxisAlignment.start'), findsOneWidget);
    expect(find.text('MainAxisAlignment.spaceEvenly'), findsOneWidget);
    expect(h.peek.value?.text, 'MainAxisAlignment.start');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(h.peek.value?.text, 'MainAxisAlignment.center');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(h.controller.text, 'MainAxisAlignment.center');
    expect(find.text('MainAxisAlignment.start'), findsNothing);
    expect(h.peek.value, isNull);
    expect(h.submits, 0);

    // The next Enter checks the answer as usual.
    // The guard against a duplicate Enter uses the real clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 350)));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(h.submits, 1);
  });

  testWidgets('typing filters, and Escape closes', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    await tester.enterText(find.byType(TextField), 'spa');
    await tester.pump();
    expect(find.text('MainAxisAlignment.spaceBetween'), findsOneWidget);
    expect(find.text('MainAxisAlignment.start'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('MainAxisAlignment.spaceBetween'), findsNothing);
  });

  testWidgets('typing Type. suggests that type, and templates place the caret', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    await tester.enterText(find.byType(TextField), 'EdgeInsets.');
    await tester.pump();
    expect(find.text('EdgeInsets.symmetric'), findsOneWidget);

    await tester.tap(find.text('EdgeInsets.all'));
    await tester.pump();
    expect(h.controller.text, 'EdgeInsets.all()');
    expect(h.controller.selection.baseOffset, 'EdgeInsets.all('.length);
  });

  testWidgets('a suggestion replaces the whole blank, never adds to it', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    h.focus.requestFocus();
    await tester.pump();

    // Something already there, with the caret after a trailing space.
    h.controller.value = const TextEditingValue(
      text: 'MainAxisAlignment.end ',
      selection: TextSelection.collapsed(offset: 22),
    );
    await tester.pump();
    await ctrlSpace(tester);
    await tester.tap(find.text('MainAxisAlignment.center'));
    await tester.pump();
    expect(h.controller.text, 'MainAxisAlignment.center');
  });

  testWidgets('asking again on a filled blank lists every option, current one highlighted', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    h.focus.requestFocus();
    await tester.pump();
    h.controller.text = 'MainAxisAlignment.center';
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    await ctrlSpace(tester);
    expect(find.text('MainAxisAlignment.start'), findsOneWidget);
    expect(find.text('MainAxisAlignment.spaceEvenly'), findsOneWidget);
    expect(h.peek.value?.text, 'MainAxisAlignment.center');
  });

  testWidgets('dot shorthand: typing . lists members and keeps the shorthand', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    await tester.enterText(find.byType(TextField), '.');
    await tester.pump();
    expect(find.text('MainAxisAlignment.center'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '.cen');
    await tester.pump();
    await tester.tap(find.text('MainAxisAlignment.center'));
    await tester.pump();
    expect(h.controller.text, '.center');
  });

  testWidgets('Option+Escape also opens suggestions', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build());
    h.focus.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pump();
    expect(find.text('MainAxisAlignment.start'), findsOneWidget);
  });

  testWidgets('an empty blank hints at the type it expects', (tester) async {
    final h = _Harness('MainAxisAlignment.center');
    await tester.pumpWidget(h.build(hints: [(type: 'MainAxisAlignment', kind: null)]));
    expect(find.text('MainAxisAlignment'), findsOneWidget);
  });

  testWidgets('typing a whole answer then Enter checks it, not the list', (tester) async {
    final h = _Harness('true');
    await tester.pumpWidget(h.build());
    h.focus.requestFocus();
    await tester.pump();
    for (final text in ['t', 'tr', 'tru', 'true']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }
    expect(find.text('false'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(h.submits, 1);
  });

  testWidgets('a value blank explains why there is nothing to suggest', (tester) async {
    final h = _Harness('3');
    await tester.pumpWidget(h.build());
    h.key.currentState!.showSuggestions();
    await tester.pump();
    expect(find.textContaining('wants a value'), findsOneWidget);
  });
}

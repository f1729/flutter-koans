import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_koans/app_state.dart';
import 'package:flutter_koans/content/flutter/registry.dart';
import 'package:flutter_koans/engine/koan.dart';
import 'package:flutter_koans/l10n/gen/app_localizations.dart';
import 'package:flutter_koans/ui/koan_screen.dart';
import 'package:flutter_koans/ui/layout_inspector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _koan = Koan(
  prompt: const Tr('Gather the stones in the middle', 'Kumpulkan batu di tengah'),
  code: 'Row(mainAxisAlignment: __)',
  answers: ['MainAxisAlignment.center'],
  registry: flutterRegistry,
  preview: (v) => Row(
    mainAxisAlignment: v[0] as MainAxisAlignment,
    children: const [SizedBox(width: 40, height: 40, child: ColoredBox(color: Colors.red))],
  ),
  explanation: const Tr('center puts the free space on both sides.', 'center menaruh ruang kosong di kedua sisi.'),
  mistakes: const [
    Mistake(['MainAxisAlignment.spaceAround'], Tr('That spreads space around each stone.', 'Itu menyebar ruang di sekitar setiap batu.')),
  ],
);

final _way = Way(
  id: 'flutter',
  title: const Tr('The Way of Flutter', 'Jalan Flutter'),
  tagline: const Tr('', ''),
  categories: [Category(id: 'row-column', title: const Tr('Rows', 'Row'), intro: const Tr('', ''), koans: [_koan])],
);

Future<AppState> _pump(WidgetTester tester, {VoidCallback? onNext}) async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  await tester.binding.setSurfaceSize(const Size(1200, 1000));
  await tester.pumpWidget(AppScope(
    state: state,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: KoanView(way: _way, category: _way.categories.single, index: 0, onNext: onNext)),
    ),
  ));
  await tester.pump();
  return state;
}

Future<void> _answer(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('a known mistake explains itself', (tester) async {
    await _pump(tester);
    await _answer(tester, 'MainAxisAlignment.spaceAround');
    expect(find.text('That spreads space around each stone.'), findsOneWidget);
  });

  testWidgets('a second unexplained miss opens the suggestions', (tester) async {
    await _pump(tester);
    await _answer(tester, 'MainAxisAlignment.end');
    expect(find.text('MainAxisAlignment.spaceEvenly'), findsNothing);
    await _answer(tester, 'MainAxisAlignment.start');
    await tester.pump();
    expect(find.text('MainAxisAlignment.spaceEvenly'), findsOneWidget);
  });

  testWidgets('solving shows why, and a struggle goes to review', (tester) async {
    final state = await _pump(tester);
    await _answer(tester, 'MainAxisAlignment.end');
    await _answer(tester, 'MainAxisAlignment.start');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _answer(tester, '.center');
    expect(find.text('center puts the free space on both sides.'), findsOneWidget);
    expect(state.isSolved('flutter/row-column/0'), isTrue);
    expect(state.reviews.cards.keys, ['flutter/row-column/0']);
  });

  testWidgets('show layout outlines the preview without errors', (tester) async {
    final state = await _pump(tester);
    state.showLayout = true;
    state.compareGoal = true;
    await _answer(tester, 'MainAxisAlignment.end');
    expect(find.byType(LayoutInspector), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('solving opens a dialog that explains, then moves on', (tester) async {
    var nexts = 0;
    await _pump(tester, onNext: () => nexts++);
    await _answer(tester, 'MainAxisAlignment.center');
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('center puts the free space on both sides.'), findsOneWidget);

    // Escape stays on the koan; the Why button brings the dialog back.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(nexts, 0);
    await tester.tap(find.text('Why'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next').last);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(nexts, 1);
  });
}

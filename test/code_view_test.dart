import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_koans/ui/code_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tab moves between blanks in code order, not into the page', (tester) async {
    final controllers = List.generate(2, (_) => TextEditingController());
    final focusNodes = List.generate(2, (_) => FocusNode());
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Like the sidebar: focusable items beside and between the blanks.
            SizedBox(
              width: 200,
              child: Column(children: [
                for (var i = 0; i < 6; i++)
                  TextButton(onPressed: () {}, child: Text('item $i')),
              ]),
            ),
            Expanded(
              child: KoanCode(
                code: "expect(a, __);\nexpect(b, __);",
                controllers: controllers,
                focusNodes: focusNodes,
                statuses: const [BlankStatus.idle, BlankStatus.idle],
                onSubmit: () {},
              ),
            ),
          ],
        ),
      ),
    ));
    focusNodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focusNodes[1].hasFocus, isTrue);
  });
}

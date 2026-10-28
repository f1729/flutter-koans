# Writing koans

Koans live in `lib/content/dart/` and `lib/content/flutter/`, one file per
category, registered in order in `dart_way.dart` and `flutter_way.dart`. The
model is `lib/engine/koan.dart`; read its doc comments first.
`lib/content/dart/equality.dart` is a small, complete example.

`flutter test` enforces most of the rules below (`test/content_test.dart`,
`test/completion_test.dart`).

## Never move a koan

Progress is stored by position (`dart/maps/3`). **Append** new koans to the end
of a category. Never insert, reorder or delete existing ones. Categories are
keyed by id, so a new category may go anywhere in a Way's list.

## Anatomy of a koan

```dart
Koan(
  prompt: const Tr('Two lists with the same elements are still two lists',
                   'Dua list dengan elemen yang sama tetaplah dua list'),
  code: 'expect([1, 2] == [1, 2], __);',
  answers: ['false'],
  verify: () => [_list() == _list()],      // what Dart really computes (may be async)
  hint: const Tr('...', '...'),            // optional nudge, about 1 koan in 3
  explanation: const Tr('...', '...'),     // required: why, shown after solving
  docs: 'https://dart.dev/language/operators#equality-and-relational-operators',
  mistakes: const [
    Mistake(['true'], Tr('...', '...')),   // a likely wrong answer, and why it is wrong
  ],
),
```

- **`code`**: short (8 lines for Dart, 12 for Flutter) with no natural-language
  comments, since code is not translated. Use raw strings `r'''...'''` when the
  code contains `$`. Each `__` is a blank.
- **`answers`**: one per blank, written as Dart source in the subset that
  `lib/engine/parser.dart` understands. That means values (numbers, strings,
  bools, null, lists, sets, maps, positional records), names (`final`,
  `MainAxisAlignment.center`) and registry calls (`EdgeInsets.all(8)`). It
  excludes operators, lambdas and interpolation. `3` and `3.0` are different
  answers. Write names in full; dot shorthand (`.center`) is accepted
  automatically.
- **`verify`**: required whenever the answer is a value Dart computes. It must
  compute exactly what the shown code computes, on the Dart VM. Leave it out for
  keyword or name answers.
- **`accept`**: only when several answers are genuinely right. It must not throw.

## Explanations (required)

One to three sentences, shown after the koan is solved, so they may state the
answer. Explain the **why**: the rule, the reason Dart or Flutter works that
way, a related API or a practical consequence. Don't just restate the prompt.

> `Expanded` is just `Flexible` with `fit: FlexFit.tight`: it must fill its
> share. Use `Flexible` when a child is allowed to be smaller than its share.

## Docs links (strongly encouraged)

Link the most relevant official page, and check that it exists
(`curl -sI <url>` returns 200). Use stable pages:

- Dart language: `https://dart.dev/language/...`
- Dart core API: `https://api.dart.dev/dart-core/List-class.html`
- Flutter API: `https://api.flutter.dev/flutter/widgets/Flexible-class.html`
  (the library is `widgets`, `material`, `painting`, `rendering`, `animation`…)
- Flutter guides: `https://docs.flutter.dev/ui/layout/...`

Never invent a URL or an anchor you haven't checked.

## Mistakes (0–3 per koan)

The wrong answers a learner is most likely to try, each with feedback that names
the misunderstanding **without giving the answer away**:

> `Mistake(['true'], Tr('Lists compare by identity, not by contents. Are these two the same object?', ...))`

- One entry per blank; `null` means "anything" for that blank.
- Each must really be wrong (the tests check this), and must not be shadowed by
  an earlier, broader mistake.
- Prefer real misconceptions (int vs double, identity vs equality, main vs
  cross axis, `Flexible` vs `Expanded`) over typos.

## Capstones (one per category)

The last koan of each category is a capstone (`capstone: true`). It combines
the category's ideas in one slightly larger snippet with at least two blanks:
a small real program, or for Flutter a small real UI with a preview, such as a
profile card or a toolbar. It still needs an explanation, mistakes where useful,
and `verify` for computed values.

## Flutter previews

`preview: (values) => Widget` renders the learner's answers next to the
reference answers ("Goal"), live as they type or browse suggestions. Previews
must lay out cleanly in 320×240 for any plausible value. Clamp numbers, and cast
values freely, because the UI catches cast errors. Shared helpers are in
`lib/content/flutter/preview_kit.dart`. Names a learner can type (enum values,
constructors) must exist in `lib/content/flutter/registry.dart`.

## Writing style

- Prompts are short, calm and a little poetic, like the ClojureScript koans,
  but they still teach clearly.
- Indonesian should be natural, standard Indonesian as a developer would write
  it, not a word-for-word translation. Keep established terms in English
  (widget, list, map, null, const, final, state, padding, future, stream).
  Prefer the inclusive "kita" or impersonal phrasing, and avoid "Anda".

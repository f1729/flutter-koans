# Flutter Koans

Learn Dart and Flutter by filling in the blanks, in English or Bahasa Indonesia.
Inspired by [ClojureScript Koans](http://clojurescriptkoans.com).

**Try it: https://flutterkoans.pages.dev**

Each koan is a small truth with a piece missing. Type what belongs in the blank,
press Enter, and when reality agrees with you, move on. Choose a Way:

- **The Way of Dart** (19 categories, 192 koans): equality, variables, null
  safety, numbers, strings, lists, sets, maps, collection `if`/`for`, functions,
  iterables, classes, enums, extensions and mixins, generics, records and
  patterns, exceptions, async, streams.
- **The Way of Flutter** (13 categories, 121 koans): widgets, rows and columns,
  flex, the box model, constraints, stack and align, state, text and theme,
  lists and scrolling, gestures, implicit animations, navigation, async UI.
  Most koans render your answer live next to the goal.

Every koan explains itself once solved, and each category ends with a
capstone that combines its ideas.

## Running

```sh
flutter run -d chrome
flutter test          # parser tests + every koan's answers, translations and previews
```

## How answers are checked

Dart has no `eval`, so koans never execute what the learner types. Instead:

1. `lib/engine/parser.dart` parses the answer as a Dart *value*: numbers,
   strings, booleans, `null`, lists, sets, maps, records, identifiers such as
   `MainAxisAlignment.center` or `final`, and calls such as `EdgeInsets.all(8)`.
2. `lib/engine/evaluator.dart` compares it with the koan's reference answer.
   Sets and maps ignore order, and `3` and `3.0` are different answers. If only
   the int/double kind is wrong, the learner is told so.
3. Identifiers and calls resolve through a `Registry` of allowed names
   (`lib/content/flutter/registry.dart`), which is also what turns an answer into
   real objects for the live previews.

Each koan carries a `verify` closure that computes the real value with the Dart
compiler. `test/content_test.dart` proves every reference answer matches it, so
the content can't silently drift from what Dart actually does.

## Learning aids

- **Why:** once a koan is solved, a short explanation and a link to the
  official docs appear.
- **Targeted feedback:** common wrong answers get their own message about the
  misunderstanding behind them, without giving the answer away. Typing `3`
  where Dart gives `3.0` gets a nudge about int vs double.
- **Type hints:** an empty blank shows what it expects, faintly (`FlexFit`,
  `EdgeInsets`, `keyword`). Plain-value blanks stay empty, so the hint can't
  give the answer away.
- **Dot shorthand:** `.tight` works wherever `FlexFit.tight` does, as in Dart 3.10+.
- **Show layout / Compare with goal:** Flutter previews can outline every box
  with its size and shade padding, or lay the goal faintly over your result.
- **Review:** koans solved after two or more misses, or revealed, come back
  after 10 minutes, then 1, 3, 7 and 21 days, until they're answered right the
  first time (`lib/review.dart`).
- **Capstones:** each category ends with a larger koan that combines its ideas.

## Where learners get stuck

The app sends anonymous events (misses with what was typed, reveals, solves)
to `functions/api/events.js`, a Pages Function that stores them in D1
(`migrations/`). There are no user ids, cookies or IPs. To see the koans with
the most misses, and the most common wrong answers (candidates for new
`Mistake` entries), run:

```sh
fnm exec --using=22 scripts/stuck.sh 30   # last 30 days
```

## Suggestions (Ctrl+Space)

Like an editor, a blank can list what might belong in it: press Ctrl+Space
(or ⌥Esc on a Mac, where Ctrl+Space usually switches input source), type a
name, `MainAxisAlignment.` or just `.`, or use the Suggestions button. After a
second miss with no targeted feedback, the list opens by itself. Arrow
keys browse, and in Flutter koans the live preview shows the highlighted
option before you choose it. Enter or Tab accepts it; Esc closes the list.

Suggestions come from each blank's reference answer (`lib/engine/completion.dart`),
so koans need no extra data. An enum value suggests its siblings, a constructor
suggests the others of its type as templates, and keywords or method names
suggest their family. Plain values such as `3` or `'koan'` get no suggestions,
because listing them would give the answer away. `test/completion_test.dart`
checks that every named answer in the content can be found this way.

## Writing koans

See [CONTENT_GUIDE.md](CONTENT_GUIDE.md) for the full rules. Categories live in `lib/content/dart/` and `lib/content/flutter/`, and are
registered in `dart_way.dart` and `flutter_way.dart`.

```dart
Koan(
  prompt: const Tr('Division with / keeps the fraction',
                   'Pembagian dengan / tetap menyimpan pecahannya'),
  code: 'expect(7 / 2, __);',     // each __ becomes an input
  answers: ['3.5'],                // one reference answer per blank, as Dart source
  verify: () => [7 / 2],           // what Dart really computes
  hint: const Tr('...', '...'),    // optional
),
```

- Use `accept: (values) => ...` when several answers are right.
- Use `registry:` and `preview: (values) => Widget` for Flutter koans. The
  preview renders with the learner's values next to the reference answers.
- UI strings are in `lib/l10n/app_en.arb` and `app_id.arb` (`flutter gen-l10n`).

## Deploying

Live at https://flutterkoans.pages.dev (Cloudflare Pages, see `wrangler.jsonc`).
Deep links like `/dart/maps/3` fall back to `index.html` because the build has no
`404.html`, and the Flutter router takes it from there.

```sh
fnm exec --using=22 scripts/deploy.sh   # wrangler needs Node 22+
```

## License

MIT, see [LICENSE](LICENSE). The bundled fonts (Inter, Noto Serif, JetBrains
Mono) are under the SIL Open Font License; see `assets/fonts/licenses/`.

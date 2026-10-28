import '../../engine/koan.dart';

final collectionControl = Category(
  id: 'collection-control',
  title: const Tr('Collection Control Flow', 'Alur Kontrol dalam Koleksi'),
  intro: const Tr(
    'A collection can be built with logic, from the inside.',
    'Sebuah koleksi bisa dibangun dengan logika, dari dalam dirinya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A collection may decide what it contains',
        'Sebuah koleksi bisa memutuskan apa isinya',
      ),
      code: r'''
final morning = true;
expect(['wake', if (morning) 'meditate'], __);''',
      answers: ["['wake', 'meditate']"],
      verify: () {
        final morning = _yes();
        return [
          ['wake', if (morning) 'meditate'],
        ];
      },
      explanation: const Tr(
        'A collection if adds its element only when the condition is true, and '
            'adds nothing otherwise. It saves building a list and then '
            "removing from it, and it is everywhere in Flutter's children "
            'lists.',
        'if di dalam koleksi menambahkan elemennya hanya jika kondisinya true, '
            'dan tidak menambahkan apa-apa jika tidak. Ini menghemat langkah '
            'membangun list lalu menghapus isinya, dan dipakai di mana-mana '
            'pada list children di Flutter.',
      ),
      docs: 'https://dart.dev/language/collections#if-element',
      mistakes: const [
        Mistake(["['wake']"], Tr(
          'The condition holds this morning. What does if add then?',
          'Kondisinya terpenuhi pagi ini. Apa yang ditambahkan if kalau '
              'begitu?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'And it may choose between two paths',
        'Dan ia bisa memilih di antara dua jalan',
      ),
      code: r'''
final evening = false;
expect([if (evening) 'sleep' else 'work'], __);''',
      answers: ["['work']"],
      verify: () {
        final evening = !_yes();
        return [
          [if (evening) 'sleep' else 'work'],
        ];
      },
      explanation: const Tr(
        'With else, exactly one of the two elements is added, much like a '
            'ternary. Because it is an element rather than an expression, '
            'either branch could also be a spread or another loop.',
        'Dengan else, tepat satu dari dua elemen itu ditambahkan, mirip '
            'operator ternary. Karena ia sebuah elemen, bukan ekspresi, setiap '
            'cabangnya juga bisa berupa spread atau loop lain.',
      ),
      docs: 'https://dart.dev/language/collections#if-element',
      mistakes: const [
        Mistake(['[]'], Tr(
          'With an else, one of the two paths is always taken.',
          'Dengan else, salah satu dari dua jalan itu selalu diambil.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A loop can live inside a list',
        'Sebuah loop bisa tinggal di dalam list',
      ),
      code: 'expect([for (var i = 1; i <= 3; i++) i * i], __);',
      answers: ['[1, 4, 9]'],
      verify: () => [
        [for (var i = 1; i <= 3; i++) i * i],
      ],
      explanation: const Tr(
        'A collection for runs like an ordinary loop, but each turn contributes '
            'the element after it instead of calling add. Both the C-style for '
            'and for-in work.',
        'for di dalam koleksi berjalan seperti loop biasa, tetapi setiap '
            'putaran menyumbangkan elemen sesudahnya alih-alih memanggil add. '
            'for gaya C maupun for-in sama-sama bisa dipakai.',
      ),
      docs: 'https://dart.dev/language/collections#for-element',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'Each turn contributes i * i, not i.',
          'Setiap putaran menyumbangkan i * i, bukan i.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Three dots pour one list into another',
        'Tiga titik menuangkan satu list ke dalam list lain',
      ),
      code: r'''
final middle = [1, 2];
expect([0, ...middle, 3], __);''',
      answers: ['[0, 1, 2, 3]'],
      verify: () {
        final middle = [1, 2];
        return [
          [0, ...middle, 3],
        ];
      },
      explanation: const Tr(
        '... inserts every element of an iterable at that point in the '
            'literal. Without it, the list itself would become a single nested '
            'element.',
        '... menyisipkan setiap elemen dari sebuah iterable di titik itu dalam '
            'literal. Tanpanya, list itu sendiri akan menjadi satu elemen yang '
            'bersarang.',
      ),
      docs: 'https://dart.dev/language/collections#spread-element',
      mistakes: const [
        Mistake(['[0, [1, 2], 3]'], Tr(
          'That would be the list without the three dots. What do they do?',
          'Itu list tanpa tiga titik. Apa yang dilakukan tiga titik itu?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A careful spread pours nothing from nothing',
        'Spread yang berhati-hati tidak menuangkan apa pun dari ketiadaan',
      ),
      code: r'''
List<int>? extra;
expect([1, ...?extra], __);''',
      answers: ['[1]'],
      verify: () {
        final extra = _noList();
        return [
          [1, ...?extra],
        ];
      },
      explanation: const Tr(
        '...? spreads the elements when the iterable is not null and adds '
            'nothing when it is. A plain ... on a nullable value would not even '
            'compile.',
        '...? menyebarkan elemen jika iterable-nya bukan null dan tidak '
            'menambahkan apa-apa jika null. ... biasa pada nilai nullable '
            'bahkan tidak akan lolos kompilasi.',
      ),
      docs: 'https://dart.dev/language/collections#null-spread-element',
      mistakes: const [
        Mistake(['[1, null]'], Tr(
          'A null-aware spread pours out elements, and null has none to give.',
          'Spread null-aware menuangkan elemen, dan null tidak punya elemen '
              'untuk diberikan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Loops and conditions can walk together',
        'Loop dan kondisi bisa berjalan bersama',
      ),
      code: r'''
expect([
  for (final n in [1, 2, 3, 4, 5, 6])
    if (n.isEven) n,
], __);''',
      answers: ['[2, 4, 6]'],
      verify: () => [
        [
          for (final n in [1, 2, 3, 4, 5, 6])
            if (n.isEven) n,
        ],
      ],
      explanation: const Tr(
        'Collection elements nest: an if inside a for filters as it builds, '
            'like where(...).toList() written right inside the literal.',
        'Elemen koleksi bisa bersarang: if di dalam for menyaring sambil '
            'membangun, seperti where(...).toList() yang ditulis langsung di '
            'dalam literal.',
      ),
      docs: 'https://dart.dev/language/collections#nesting-elements',
      mistakes: const [
        Mistake(['[1, 3, 5]'], Tr(
          'isEven lets through only one kind of number. Which?',
          'isEven hanya meloloskan satu jenis angka. Yang mana?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A map can be built the same way',
        'Map pun bisa dibangun dengan cara yang sama',
      ),
      code: r'''
final words = ['zen', 'koan'];
expect({for (final w in words) w: w.length}, __);''',
      answers: ["{'zen': 3, 'koan': 4}"],
      verify: () {
        final words = ['zen', 'koan'];
        return [
          {for (final w in words) w: w.length},
        ];
      },
      explanation: const Tr(
        'In a map literal, a for element yields key: value entries, one per '
            'turn. It reads more directly than Map.fromIterable or building an '
            'empty map and filling it in a loop.',
        'Di dalam literal map, elemen for menghasilkan entry key: value, satu '
            'di setiap putaran. Cara ini lebih mudah dibaca daripada '
            'Map.fromIterable atau membuat map kosong lalu mengisinya dengan '
            'loop.',
      ),
      docs: 'https://dart.dev/language/collections#for-element',
      mistakes: const [
        Mistake(["{'zen': 'zen', 'koan': 'koan'}"], Tr(
          'Look at what stands after the colon: the value of each entry.',
          'Perhatikan apa yang ada setelah titik dua: nilai dari setiap entry.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A set built by a loop still keeps each value once',
        'Set yang dibangun dengan loop tetap menyimpan setiap nilai sekali',
      ),
      code: 'expect({for (final n in [1, 2, 3, 4]) n % 2}, __);',
      answers: ['{1, 0}'],
      hint: const Tr(
        'Work out n % 2 for each n, then remember what a set does.',
        'Hitung n % 2 untuk setiap n, lalu ingat apa yang dilakukan set.',
      ),
      verify: () => [
        {for (final n in [1, 2, 3, 4]) n % 2},
      ],
      explanation: const Tr(
        'The loop produces 1, 0, 1, 0, and the set keeps each value once. Set '
            'equality ignores order, so {1, 0} and {0, 1} are the same answer.',
        'Loop itu menghasilkan 1, 0, 1, 0, dan set menyimpan setiap nilai '
            'sekali. Kesetaraan set mengabaikan urutan, jadi {1, 0} dan {0, 1} '
            'adalah jawaban yang sama.',
      ),
      docs: 'https://dart.dev/language/collections#for-element',
      mistakes: const [
        Mistake(['{1, 0, 1, 0}'], Tr(
          'A set keeps each value once, even when a loop builds it.',
          'Set menyimpan setiap nilai sekali, bahkan ketika dibangun oleh loop.',
        )),
        Mistake(['{1, 2, 3, 4}'], Tr(
          'Each turn contributes n % 2, not n.',
          'Setiap putaran menyumbangkan n % 2, bukan n.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A spread inside a loop flattens what was nested',
        'Spread di dalam loop meratakan apa yang tadinya bersarang',
      ),
      code: r'''
final rows = [[1, 2], [3]];
expect([for (final row in rows) ...row], __);''',
      answers: ['[1, 2, 3]'],
      verify: () {
        final rows = [
          [1, 2],
          [3],
        ];
        return [
          [for (final row in rows) ...row],
        ];
      },
      explanation: const Tr(
        'A spread inside a for pours out each row in turn, flattening one '
            'level of nesting. rows.expand((row) => row) says the same thing '
            'with an Iterable method.',
        'Spread di dalam for menuangkan setiap baris secara bergiliran, '
            'meratakan satu tingkat sarang. rows.expand((row) => row) '
            'menyatakan hal yang sama dengan method Iterable.',
      ),
      docs: 'https://dart.dev/language/collections#nesting-elements',
      mistakes: const [
        Mistake(['[[1, 2], [3]]'], Tr(
          'The three dots pour out the elements of each row, not the row '
              'itself.',
          'Tiga titik menuangkan elemen dari setiap baris, bukan barisnya '
              'sendiri.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A loop within a loop visits every pairing',
        'Loop di dalam loop mengunjungi setiap pasangan',
      ),
      code: r'''
expect([
  for (final n in [1, 2])
    for (final c in ['a', 'b']) '$n$c',
], __);''',
      answers: ["['1a', '1b', '2a', '2b']"],
      hint: const Tr(
        'The outer loop moves the slowest.',
        'Loop terluar bergerak paling lambat.',
      ),
      verify: () => [
        [
          for (final n in [1, 2])
            for (final c in ['a', 'b']) '$n$c',
        ],
      ],
      explanation: const Tr(
        'Nested for elements behave like nested loops: the inner loop runs to '
            'the end for every value of the outer one, producing every pairing '
            'in order.',
        'Elemen for yang bersarang berperilaku seperti loop bersarang: loop '
            'dalam berjalan sampai habis untuk setiap nilai loop luar, '
            'menghasilkan setiap pasangan secara berurutan.',
      ),
      docs: 'https://dart.dev/language/collections#nesting-elements',
      mistakes: const [
        Mistake(["['1a', '2a', '1b', '2b']"], Tr(
          'The inner loop runs completely before the outer one moves on.',
          'Loop dalam berjalan sampai selesai sebelum loop luar melangkah.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A menu that arranges itself for whoever opens it',
        'Sebuah menu yang menata dirinya untuk siapa pun yang membukanya',
      ),
      code: r'''
List<String> menu({required bool loggedIn, List<String>? extras}) => [
  'Home',
  if (loggedIn) 'Profile' else 'Sign in',
  ...?extras,
  for (final n in [1, 2, 3]) if (n.isOdd) 'Tip $n',
];
expect(menu(loggedIn: false), __);
expect(menu(loggedIn: true, extras: ['Admin']).length, __);''',
      answers: ["['Home', 'Sign in', 'Tip 1', 'Tip 3']", '5'],
      capstone: true,
      verify: () => [
        _menu(loggedIn: false),
        _menu(loggedIn: true, extras: ['Admin']).length,
      ],
      explanation: const Tr(
        'if-else picks one entry, ...? adds nothing for a null list, and a for '
            'with an if inside adds only the odd tips. This is exactly how '
            'Flutter code builds a children list without any add calls.',
        'if-else memilih satu entry, ...? tidak menambahkan apa pun untuk list '
            'yang null, dan for dengan if di dalamnya hanya menambahkan tip '
            'yang ganjil. Persis seperti inilah kode Flutter membangun list '
            'children tanpa satu pun pemanggilan add.',
      ),
      docs: 'https://dart.dev/language/collections#collection-elements',
      mistakes: const [
        Mistake(["['Home', 'Sign in', null, 'Tip 1', 'Tip 3']", null], Tr(
          '...? adds no elements when extras is null.',
          '...? tidak menambahkan elemen apa pun jika extras bernilai null.',
        )),
        Mistake(["['Home', 'Sign in', 'Tip 1', 'Tip 2', 'Tip 3']", null], Tr(
          'The if inside the loop lets only some numbers through.',
          'if di dalam loop hanya meloloskan sebagian angka.',
        )),
        Mistake([null, '6'], Tr(
          'if-else adds exactly one of its two entries.',
          'if-else menambahkan tepat satu dari dua entry-nya.',
        )),
      ],
    ),
  ],
);

List<String> _menu({required bool loggedIn, List<String>? extras}) => [
      'Home',
      if (loggedIn) 'Profile' else 'Sign in',
      ...?extras,
      for (final n in [1, 2, 3])
        if (n.isOdd) 'Tip $n',
    ];

// Built at runtime so the analyzer does not know what they hold.
bool _yes() => true;
List<int>? _noList() => null;

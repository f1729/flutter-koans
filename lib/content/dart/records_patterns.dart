import '../../engine/koan.dart';

final recordsPatterns = Category(
  id: 'records-patterns',
  title: const Tr('Records and Patterns', 'Record dan Pattern'),
  intro: const Tr(
    'Values travel together in records, and patterns take them apart.',
    'Nilai-nilai bepergian bersama dalam record, dan pattern membongkarnya '
        'kembali.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A record carries values together, by position or by name',
        'Record membawa nilai-nilai bersama, berdasarkan posisi atau nama',
      ),
      code: r'''
final point = (3, y: 4);
expect(point.$1, __);
expect(point.y, __);''',
      answers: ['3', '4'],
      verify: () {
        final point = (_n(3), y: 4);
        return [point.$1, point.y];
      },
      explanation: const Tr(
        r'Positional fields are read with $1, $2 and so on, and named fields by '
            r'their name. A record is immutable and structurally typed: this '
            r'one has the type (int, {int y}), with no class to declare.',
        r'Field posisional dibaca dengan $1, $2, dan seterusnya, sedangkan '
            r'field bernama dengan namanya. Record tidak bisa diubah dan bertipe '
            r'struktural: yang ini bertipe (int, {int y}), tanpa perlu '
            'mendeklarasikan kelas.',
      ),
      docs: 'https://dart.dev/language/records#record-fields',
      mistakes: const [
        Mistake(['4', null], Tr(
          r'$1 is the first positional field, and the named y does not count '
              'as positional.',
          r'$1 adalah field posisional pertama, dan y yang bernama tidak '
              'dihitung sebagai posisional.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Two names can trade places in a single breath',
        'Dua nama bisa bertukar tempat dalam satu tarikan napas',
      ),
      code: r'''
var a = 1;
var b = 2;
(a, b) = (b, a);
expect((a, b), __);''',
      answers: ['(2, 1)'],
      verify: () {
        var a = 1;
        var b = 2;
        (a, b) = (b, a);
        return [(a, b)];
      },
      explanation: const Tr(
        'The right side builds the record (2, 1) from the old values first, '
            'then the pattern on the left assigns both at once. That is a swap '
            'with no temporary variable.',
        'Sisi kanan membangun record (2, 1) dari nilai lama terlebih dahulu, '
            'lalu pattern di sebelah kiri mengisi keduanya sekaligus. Itulah '
            'pertukaran tanpa variabel sementara.',
      ),
      docs: 'https://dart.dev/language/patterns#variable-assignment',
      mistakes: const [
        Mistake(['(2, 2)'], Tr(
          'The assignments do not happen one after the other. The whole right '
              'side is built first.',
          'Pengisiannya tidak terjadi satu per satu. Seluruh sisi kanan '
              'dibangun lebih dulu.',
        )),
        Mistake(['(1, 2)'], Tr(
          'The record on the right is built from b, then a.',
          'Record di sebelah kanan dibangun dari b, lalu a.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A function may return more than one thing',
        'Fungsi boleh mengembalikan lebih dari satu hal',
      ),
      code: r'''
(int, int) divide(int a, int b) => (a ~/ b, a % b);
final (quotient, remainder) = divide(17, 5);
expect(quotient, __);
expect(remainder, __);''',
      answers: ['3', '2'],
      verify: () {
        (int, int) divide(int a, int b) => (a ~/ b, a % b);
        final (quotient, remainder) = divide(17, 5);
        return [quotient, remainder];
      },
      explanation: const Tr(
        'A function can return a record and the caller can destructure it '
            'straight into named locals. It replaces out-parameters or a '
            'one-off class for a small group of results.',
        'Fungsi bisa mengembalikan record, dan pemanggil bisa langsung '
            'membongkarnya ke variabel lokal yang bernama. Cara ini '
            'menggantikan out-parameter atau kelas sekali pakai untuk '
            'sekelompok kecil hasil.',
      ),
      docs: 'https://dart.dev/language/records#multiple-returns',
      mistakes: const [
        Mistake(['2', '3'], Tr(
          'Positional fields keep their order when destructured.',
          'Field posisional tetap menjaga urutannya saat dibongkar.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A switch expression matches a value against patterns',
        'Switch expression mencocokkan sebuah nilai dengan pattern-pattern',
      ),
      code: r'''
String describe(int n) => switch (n) {
  0 => 'none',
  1 || 2 => 'few',
  _ => 'many',
};
expect(describe(2), __);''',
      answers: ["'few'"],
      verify: () {
        String describe(int n) => switch (n) {
              0 => 'none',
              1 || 2 => 'few',
              _ => 'many',
            };
        return [describe(2)];
      },
      explanation: const Tr(
        'Cases are tried from top to bottom and the first match wins. 1 || 2 '
            'is a logical-or pattern matching either value, and _ catches '
            'everything else so the switch is exhaustive.',
        'Case dicoba dari atas ke bawah dan kecocokan pertama yang menang. '
            '1 || 2 adalah pattern logical-or yang cocok dengan salah satu '
            'nilai, dan _ menangkap sisanya sehingga switch-nya exhaustive.',
      ),
      docs: 'https://dart.dev/language/branches#switch-expressions',
      mistakes: const [
        Mistake(["'many'"], Tr(
          '1 || 2 matches either of the two values.',
          '1 || 2 cocok dengan salah satu dari kedua nilai itu.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A guard adds a condition to a pattern',
        'Guard menambahkan syarat pada sebuah pattern',
      ),
      code: r'''
String sign(int n) => switch (n) {
  0 => 'zero',
  final x when x < 0 => 'negative',
  _ => 'positive',
};
expect(sign(-5), __);
expect(sign(0), __);''',
      answers: ["'negative'", "'zero'"],
      verify: () {
        String sign(int n) => switch (n) {
              0 => 'zero',
              final x when x < 0 => 'negative',
              _ => 'positive',
            };
        return [sign(-5), sign(0)];
      },
      explanation: const Tr(
        'A when clause adds a condition to a case: the pattern binds x, but the '
            'case matches only if x < 0, and otherwise matching moves on to the '
            'next case.',
        'Klausa when menambahkan syarat pada sebuah case: pattern-nya mengikat '
            'x, tetapi case itu hanya cocok jika x < 0, dan jika tidak, '
            'pencocokan berlanjut ke case berikutnya.',
      ),
      docs: 'https://dart.dev/language/branches#guard-clause',
      mistakes: const [
        Mistake(["'positive'", null], Tr(
          '-5 is bound to x, and then the guard is checked.',
          '-5 diikat ke x, lalu guard-nya diperiksa.',
        )),
        Mistake([null, "'positive'"], Tr(
          'Cases are tried from the top. Which one does 0 meet first?',
          'Case dicoba dari atas. Case mana yang pertama ditemui 0?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A list pattern can take the head and leave the rest',
        'Pattern list bisa mengambil kepalanya dan menyisakan sisanya',
      ),
      code: r'''
final [first, ...rest] = [1, 2, 3];
expect(first, __);
expect(rest, __);''',
      answers: ['1', '[2, 3]'],
      verify: () {
        final [first, ...rest] = [1, 2, 3];
        return [first, rest];
      },
      explanation: const Tr(
        'A rest element ...rest collects whatever the other subpatterns did '
            'not claim, as a new list. In a declaration the pattern must '
            'match, so destructuring an empty list here would throw.',
        'Elemen rest ...rest mengumpulkan apa pun yang tidak diambil oleh '
            'subpattern lain, sebagai list baru. Di dalam deklarasi, '
            'pattern-nya wajib cocok, jadi membongkar list kosong di sini akan '
            'melempar error.',
      ),
      docs: 'https://dart.dev/language/pattern-types#rest-element',
      mistakes: const [
        Mistake([null, '[1, 2, 3]'], Tr(
          'rest gets only what is left after first.',
          'rest hanya mendapat apa yang tersisa setelah first.',
        )),
        Mistake([null, '3'], Tr(
          'A rest element collects the remaining elements into a list.',
          'Elemen rest mengumpulkan elemen yang tersisa ke dalam list.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'if-case asks: does this value have this exact shape?',
        'if-case bertanya: apakah nilai ini punya bentuk persis seperti ini?',
      ),
      code: r'''
Object value = [1, 2, 3];
var sum = 0;
if (value case [int a, int b]) {
  sum = a + b;
}
expect(sum, __);''',
      answers: ['0'],
      hint: const Tr(
        'Without ..., a list pattern must match the length exactly.',
        'Tanpa ..., pattern list harus cocok persis dengan panjangnya.',
      ),
      verify: () {
        final Object value = _list([1, 2, 3]);
        var sum = 0;
        if (value case [int a, int b]) {
          sum = a + b;
        }
        return [sum];
      },
      explanation: const Tr(
        'if-case tests a refutable pattern: when it does not match, the body is '
            'simply skipped. A list pattern without a rest element must match '
            'the length exactly, so [int a, int b] rejects three elements.',
        'if-case menguji pattern yang refutable: jika tidak cocok, body-nya '
            'cukup dilewati. Pattern list tanpa elemen rest harus cocok persis '
            'dengan panjangnya, jadi [int a, int b] menolak tiga elemen.',
      ),
      docs: 'https://dart.dev/language/branches#if-case',
      mistakes: const [
        Mistake(['3'], Tr(
          'Does a two-element pattern match a list of three?',
          'Apakah pattern dua elemen cocok dengan list berisi tiga?',
        )),
        Mistake(['6'], Tr(
          'The pattern names only two elements. Does it match three?',
          'Pattern itu hanya menyebut dua elemen. Apakah ia cocok dengan tiga?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A map pattern checks the keys, and the types of their values',
        'Pattern map memeriksa key, beserta tipe nilainya',
      ),
      code: r'''
String greet(Object json) => switch (json) {
  {'name': String name} => 'Hello, $name',
  _ => 'Who?',
};
expect(greet({'name': 'Ratu'}), __);
expect(greet({'name': 7}), __);''',
      answers: ["'Hello, Ratu'", "'Who?'"],
      verify: () {
        String greet(Object json) => switch (json) {
              {'name': String name} => 'Hello, $name',
              _ => 'Who?',
            };
        return [
          greet({'name': 'Ratu'}),
          greet({'name': 7}),
        ];
      },
      explanation: const Tr(
        'A map pattern checks that each listed key exists and that its value '
            'matches the subpattern, here a String. Extra keys are ignored, '
            'which makes map patterns a neat way to validate decoded JSON.',
        'Pattern map memeriksa bahwa setiap key yang disebut ada dan nilainya '
            'cocok dengan subpattern-nya, di sini String. Key tambahan '
            'diabaikan, sehingga pattern map menjadi cara rapi untuk '
            'memvalidasi JSON yang sudah di-decode.',
      ),
      docs: 'https://dart.dev/language/patterns#validating-incoming-json',
      mistakes: const [
        Mistake([null, "'Hello, 7'"], Tr(
          'The pattern asks for more than the key: what type must the value '
              'be?',
          'Pattern itu meminta lebih dari sekadar key: harus bertipe apa '
              'nilainya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An object pattern looks inside by naming its fields',
        'Pattern objek melihat ke dalam dengan menyebut nama field-nya',
      ),
      code: r'''
sealed class Shape {}
class Square extends Shape { Square(this.side); final double side; }
class Circle extends Shape { Circle(this.r); final double r; }

double area(Shape s) => switch (s) {
  Square(:final side) => side * side,
  Circle(:final r) => 3 * r * r,
};
expect(area(Square(2)), __);
expect(area(Circle(1)), __);''',
      answers: ['4.0', '3.0'],
      hint: const Tr(
        'Look at the type of the fields.',
        'Perhatikan tipe dari field-field tersebut.',
      ),
      verify: () => [_area(_Square(2)), _area(_Circle(1))],
      explanation: const Tr(
        'Square(:final side) checks the type and binds the side getter in one '
            'step; :final side is short for side: final side. Since the fields '
            'are doubles, the int arguments 2 and 1 become 2.0 and 1.0, and so '
            'do the areas.',
        'Square(:final side) memeriksa tipenya sekaligus mengikat getter side '
            'dalam satu langkah; :final side adalah singkatan dari side: final '
            'side. Karena field-nya double, argumen int 2 dan 1 menjadi 2.0 dan '
            '1.0, begitu pula luasnya.',
      ),
      docs: 'https://dart.dev/language/pattern-types#object',
      mistakes: const [
        Mistake(['2.0', null], Tr(
          'The area of a square multiplies side by itself.',
          'Luas persegi mengalikan side dengan dirinya sendiri.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When every kind is known, the switch needs no default',
        'Ketika semua jenisnya sudah diketahui, switch tidak memerlukan '
            'default',
      ),
      code: r'''
__ class Light {}
class Red extends Light {}
class Green extends Light {}

String act(Light light) => switch (light) {
  Red() => 'stop',
  Green() => 'go',
};''',
      answers: ['sealed'],
      hint: const Tr(
        'The parent class must forbid anyone outside this library from '
            'extending it.',
        'Kelas induknya harus melarang siapa pun di luar library ini untuk '
            'meng-extend-nya.',
      ),
      explanation: const Tr(
        'A sealed class can only be extended inside its own library, so the '
            'compiler knows every subtype and can prove the switch exhaustive. '
            'Adding a Yellow later turns every incomplete switch into a compile '
            'error, which is exactly the point.',
        'Kelas sealed hanya bisa di-extend di dalam library-nya sendiri, jadi '
            'compiler mengetahui setiap subtipenya dan bisa membuktikan bahwa '
            'switch-nya exhaustive. Menambahkan Yellow nanti akan mengubah '
            'setiap switch yang belum lengkap menjadi error kompilasi, dan '
            'justru itulah tujuannya.',
      ),
      docs: 'https://dart.dev/language/class-modifiers#sealed',
      mistakes: const [
        Mistake(['abstract'], Tr(
          'An abstract class can be extended from anywhere, so the compiler '
              'cannot know every subtype.',
          'Kelas abstract bisa di-extend dari mana saja, jadi compiler tidak '
              'bisa mengetahui setiap subtipenya.',
        )),
        Mistake(['final'], Tr(
          'final also limits subclassing, but it does not make a switch over '
              'its subtypes exhaustive, and here Red and Green would have to be '
              'final or base too.',
          'final juga membatasi pewarisan, tetapi tidak membuat switch atas '
              'subtipenya menjadi exhaustive, dan di sini Red dan Green juga '
              'harus final atau base.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Messages of many shapes, each recognized at a glance',
        'Pesan dengan banyak bentuk, masing-masing dikenali sekilas',
      ),
      code: r'''
String describe(Object json) => switch (json) {
  {'type': 'point', 'x': int x, 'y': int y} => 'point at ($x, $y)',
  {'type': 'tags', 'list': [String first, ...]} => 'tags from $first',
  [_, _, ...] => 'list',
  _ => 'unknown',
};
final (a, b) = (describe({'type': 'point', 'x': 1, 'y': 2}), describe(['x']));
expect(a, __);
expect(b, __);
expect(describe({'type': 'tags', 'list': ['zen', 'koan']}), __);''',
      answers: ["'point at (1, 2)'", "'unknown'", "'tags from zen'"],
      capstone: true,
      verify: () {
        final (a, b) = (
          _describe({'type': 'point', 'x': 1, 'y': 2}),
          _describe(['x']),
        );
        return [
          a,
          b,
          _describe({
            'type': 'tags',
            'list': ['zen', 'koan'],
          }),
        ];
      },
      explanation: const Tr(
        'Map patterns check keys, constants and value types together, a list '
            'pattern with ... sets a minimum length, and _ catches the rest. '
            'The record on the last line is built and destructured in one '
            'statement.',
        'Pattern map memeriksa key, konstanta, dan tipe nilai sekaligus, '
            'pattern list dengan ... menetapkan panjang minimum, dan _ '
            'menangkap sisanya. Record di baris terakhir dibangun dan dibongkar '
            'dalam satu pernyataan.',
      ),
      docs: 'https://dart.dev/language/patterns',
      mistakes: const [
        Mistake([null, "'list'", null], Tr(
          'How many elements does [_, _, ...] require at least?',
          'Berapa elemen yang minimal dibutuhkan [_, _, ...]?',
        )),
        Mistake([null, null, "'tags from zen, koan'"], Tr(
          'first binds a single element; the rest is matched by ... and '
              'discarded.',
          'first mengikat satu elemen saja; sisanya dicocokkan oleh ... lalu '
              'dibuang.',
        )),
      ],
    ),
  ],
);

String _describe(Object json) => switch (json) {
      {'type': 'point', 'x': int x, 'y': int y} => 'point at ($x, $y)',
      {'type': 'tags', 'list': [String first, ...]} => 'tags from $first',
      [_, _, ...] => 'list',
      _ => 'unknown',
    };

sealed class _Shape {}

class _Square extends _Shape {
  _Square(this.side);
  final double side;
}

class _Circle extends _Shape {
  _Circle(this.r);
  final double r;
}

double _area(_Shape s) => switch (s) {
      _Square(:final side) => side * side,
      _Circle(:final r) => 3 * r * r,
    };

// Built at runtime so the analyzer does not fold them into constants.
int _n(int value) => value;
List<int> _list(List<int> values) => [...values];

import '../../engine/koan.dart';

final generics = Category(
  id: 'generics',
  title: const Tr('Generics', 'Generik'),
  intro: const Tr(
    'A generic is a promise kept open: the same shape, for any type.',
    'Generik adalah janji yang dibiarkan terbuka: bentuk yang sama, untuk '
        'tipe apa pun.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A box remembers what it was made to hold',
        'Sebuah kotak ingat untuk apa ia dibuat',
      ),
      code: r'''
class Box<T> {
  Box(this.value);
  final T value;
}
final Object box = Box(3);
expect(box is Box<int>, __);
expect(box is Box<String>, __);''',
      answers: ['true', 'false'],
      verify: () {
        final Object box = _Box(3);
        return [box is _Box<int>, box is _Box<String>];
      },
      explanation: const Tr(
        'Dart infers `Box<int>` from the argument, and keeps that type '
            'argument at runtime: generics are reified, unlike in Java. So '
            '`is` can tell a `Box<int>` from a `Box<String>`.',
        'Dart menyimpulkan `Box<int>` dari argumennya, dan menyimpan argumen '
            'tipe itu saat runtime: generik di Dart bersifat reified, tidak '
            'seperti di Java. Jadi `is` bisa membedakan `Box<int>` dari '
            '`Box<String>`.',
      ),
      docs: 'https://dart.dev/language/generics#generic-collections-and-the-types-they-contain',
      mistakes: const [
        Mistake([null, 'true'], Tr(
          'The type argument is not erased; the box still knows it holds ints.',
          'Argumen tipenya tidak dihapus; kotak itu masih tahu bahwa ia berisi '
              'int.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A function can be generic too',
        'Fungsi pun bisa generik',
      ),
      code: r'''
T firstOf<T>(List<T> items) => items.first;
expect(firstOf(['a', 'b']), __);
expect(firstOf<num>([1, 2.5]), __);''',
      answers: ["'a'", '1'],
      verify: () {
        T firstOf<T>(List<T> items) => items.first;
        return [
          firstOf(['a', 'b']),
          firstOf<num>([1, 2.5]),
        ];
      },
      explanation: const Tr(
        '`T` is usually inferred from the arguments, but can be written '
            'explicitly, as in `firstOf<num>`. Asking for `num` does not '
            'convert anything: an int stays an int, it is simply seen as a '
            'num.',
        '`T` biasanya disimpulkan dari argumennya, tetapi bisa juga ditulis '
            'langsung, seperti `firstOf<num>`. Meminta `num` tidak mengubah '
            'apa pun: int tetap int, ia hanya dipandang sebagai num.',
      ),
      docs: 'https://dart.dev/language/generics#using-generic-methods',
      mistakes: const [
        Mistake([null, '2.5'], Tr(
          'first means the first element, whatever the type.',
          'first berarti elemen pertama, apa pun tipenya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A list is what it was declared to hold, not only what it holds now',
        'Sebuah list adalah apa yang dideklarasikan untuk ia tampung, bukan '
            'hanya apa yang ia tampung sekarang',
      ),
      code: r'''
final a = [1, 2];
final b = <num>[1, 2];
expect(a is List<int>, __);
expect(b is List<int>, __);''',
      answers: ['true', 'false'],
      verify: () {
        final Object a = [_n(1), 2];
        final Object b = <num>[1, 2];
        return [a is List<int>, b is List<int>];
      },
      explanation: const Tr(
        'Without a type argument, Dart infers `List<int>` from the elements. '
            'With `<num>`, the list is a `List<num>` that happens to contain '
            'ints, and tomorrow it may hold a double too, so it is not a '
            '`List<int>`.',
        'Tanpa argumen tipe, Dart menyimpulkan `List<int>` dari elemennya. '
            'Dengan `<num>`, list itu adalah `List<num>` yang kebetulan berisi '
            'int, dan besok ia boleh berisi double juga, sehingga ia bukan '
            '`List<int>`.',
      ),
      docs: 'https://dart.dev/language/type-system#type-argument-inference',
      mistakes: const [
        Mistake([null, 'true'], Tr(
          'Look at what b was told it may hold, not at what it holds now.',
          'Perhatikan apa yang boleh ditampung b, bukan apa yang ditampungnya '
              'sekarang.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A list of ints may pass for a list of nums, until we push it too far',
        'List berisi int boleh menyamar sebagai list berisi num, sampai kita '
            'mendorongnya terlalu jauh',
      ),
      code: r'''
List<int> ints = [1, 2];
List<num> nums = ints;
expect(nums is List<int>, __);
expect(() => nums.add(2.5), throwsA(isA<__>()));''',
      answers: ['true', 'TypeError'],
      registry: const Registry(symbols: {'TypeError': TypeError}),
      verify: () {
        final List<int> ints = [_n(1), 2];
        final List<num> nums = ints;
        Type? thrown;
        try {
          nums.add(2.5);
        } on TypeError {
          thrown = TypeError;
        }
        return [nums is List<int>, thrown];
      },
      hint: const Tr(
        'nums and ints are two names for one list. What is it really?',
        'nums dan ints adalah dua nama untuk satu list. Sebenarnya list apa '
            'itu?',
      ),
      explanation: const Tr(
        'Dart generics are covariant: a `List<int>` is accepted as a '
            '`List<num>`. The object is still a `List<int>`, though, so '
            'adding a double is caught at runtime with a TypeError. This is '
            'why the type a list was created with matters.',
        'Generik di Dart bersifat kovarian: `List<int>` diterima sebagai '
            '`List<num>`. Namun objeknya tetap `List<int>`, jadi menambahkan '
            'double akan tertangkap saat runtime dengan TypeError. Karena '
            'itulah tipe saat list dibuat itu penting.',
      ),
      docs: 'https://dart.dev/language/type-system#generic-type-assignment',
      mistakes: const [
        Mistake(['false', null], Tr(
          'Assigning to a new name does not change the object behind it.',
          'Menetapkan ke nama baru tidak mengubah objek di baliknya.',
        )),
        Mistake([null, 'ArgumentError'], Tr(
          'The argument is a perfectly good num. The problem is the type of '
              'the list.',
          'Argumennya num yang sah. Masalahnya ada pada tipe list-nya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A bound tells T what it must at least be',
        'Batasan memberi tahu T paling tidak ia harus menjadi apa',
      ),
      code: r'''
T biggest<T extends __>(List<T> xs) =>
    xs.reduce((a, b) => a > b ? a : b);
expect(biggest([3, 9, 4]), 9);
expect(biggest([1.5, 0.5]), 1.5);''',
      answers: ['num'],
      explanation: const Tr(
        'Without a bound, `T` could be anything, and not everything has `>`. '
            '`T extends num` allows ints and doubles alike, and lets the body '
            'use what every num can do.',
        'Tanpa batasan, `T` bisa apa saja, dan tidak semuanya punya `>`. '
            '`T extends num` mengizinkan int maupun double, dan membuat body '
            'fungsi bisa memakai apa yang dimiliki setiap num.',
      ),
      docs: 'https://dart.dev/language/generics#restricting-the-parameterized-type',
      mistakes: const [
        Mistake(['int'], Tr(
          'Then the list of doubles could not come in.',
          'Kalau begitu list berisi double tidak bisa masuk.',
        )),
        Mistake(['double'], Tr(
          'Then the list of ints could not come in.',
          'Kalau begitu list berisi int tidak bisa masuk.',
        )),
        Mistake(['Object'], Tr(
          'An Object does not know how to compare itself with >.',
          'Object tidak tahu cara membandingkan dirinya dengan >.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Ask a mixed crowd for one kind only',
        'Mintalah dari kerumunan yang campur aduk hanya satu jenis saja',
      ),
      code: r'''
final mixed = <Object>[1, 'two', 2.5, 4];
expect(mixed.whereType<int>().toList(), __);
expect(mixed.whereType<num>().length, __);''',
      answers: ['[1, 4]', '3'],
      verify: () {
        final mixed = <Object>[1, 'two', 2.5, 4];
        return [mixed.whereType<int>().toList(), mixed.whereType<num>().length];
      },
      explanation: const Tr(
        '`whereType<T>()` keeps the elements that are a `T` and gives back an '
            '`Iterable<T>`, so the result is already typed. A double is a num '
            'but not an int.',
        '`whereType<T>()` menyimpan elemen yang merupakan `T` dan '
            'mengembalikan `Iterable<T>`, jadi hasilnya sudah bertipe. Double '
            'adalah num, tetapi bukan int.',
      ),
      docs: 'https://api.dart.dev/dart-core/Iterable/whereType.html',
      mistakes: const [
        Mistake(['[1, 2.5, 4]', null], Tr(
          'whereType<int> is strict: every int is a num, but not every num is '
              'an int.',
          'whereType<int> itu ketat: setiap int adalah num, tetapi tidak '
              'setiap num adalah int.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A type parameter can be asked questions at runtime',
        'Parameter tipe bisa ditanyai saat runtime',
      ),
      code: r'''
bool fits<T>(Object? value) => value is T;
expect(fits<num>(3), __);
expect(fits<int>(3.5), __);
expect(fits<String?>(null), __);''',
      answers: ['true', 'false', 'true'],
      verify: () {
        bool fits<T>(Object? value) => value is T;
        return [fits<num>(3), fits<int>(3.5), fits<String?>(null)];
      },
      explanation: const Tr(
        'Because type arguments are kept at runtime, `value is T` works '
            'inside a generic function. `String?` means "a String or null", '
            'so null fits it.',
        'Karena argumen tipe tetap ada saat runtime, `value is T` bekerja di '
            'dalam fungsi generik. `String?` berarti "String atau null", jadi '
            'null cocok dengannya.',
      ),
      docs: 'https://dart.dev/language/generics#generic-collections-and-the-types-they-contain',
      mistakes: const [
        Mistake([null, null, 'false'], Tr(
          'Look closely at the question mark in the type.',
          'Perhatikan baik-baik tanda tanya pada tipenya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a stack that holds any one kind of thing',
        'Kumpulkan semuanya: tumpukan yang menampung satu jenis benda apa pun',
      ),
      code: r'''
class Stack<T> {
  final _items = <T>[];
  void push(T item) => _items.add(item);
  T pop() => _items.removeLast();
}
final s = Stack<num>()..push(1)..push(2.5);
expect(s.pop(), __);
expect(s is Stack<int>, __);
expect(s.pop(), __);''',
      answers: ['2.5', 'false', '1'],
      verify: () {
        final s = _Stack<num>()
          ..push(_n(1))
          ..push(2.5);
        final Object asObject = s;
        return [s.pop(), asObject is _Stack<int>, s.pop()];
      },
      capstone: true,
      explanation: const Tr(
        'One generic class serves every type: `Stack<num>` accepts ints and '
            'doubles, and `pop` returns a `num` without casts. The stack '
            'remembers its type argument, so it is not a `Stack<int>`, and '
            'the int inside stays an int.',
        'Satu kelas generik melayani setiap tipe: `Stack<num>` menerima int '
            'dan double, dan `pop` mengembalikan `num` tanpa cast. Tumpukan '
            'itu mengingat argumen tipenya, jadi ia bukan `Stack<int>`, dan '
            'int di dalamnya tetap int.',
      ),
      docs: 'https://dart.dev/language/generics',
      mistakes: const [
        Mistake(['1', null, null], Tr(
          'A stack gives back the last thing that went in.',
          'Tumpukan mengembalikan benda yang terakhir masuk.',
        )),
        Mistake([null, 'true', null], Tr(
          'The stack was made to hold any num, whatever it holds right now.',
          'Tumpukan itu dibuat untuk menampung num apa pun, apa pun isinya '
              'saat ini.',
        )),
      ],
    ),
  ],
);

class _Box<T> {
  _Box(this.value);
  final T value;
}

class _Stack<T> {
  final _items = <T>[];
  void push(T item) => _items.add(item);
  T pop() => _items.removeLast();
}

// Built at runtime so the analyzer does not fold it into a constant.
int _n(int value) => value;

import '../../engine/koan.dart';

final equality = Category(
  id: 'equality',
  title: const Tr('Equality', 'Kesetaraan'),
  intro: const Tr(
    'We shall contemplate truth by testing reality, via equality.',
    'Kita akan merenungkan kebenaran dengan menguji kenyataan, melalui kesetaraan.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'We shall contemplate truth by testing reality, via equality',
        'Kita merenungkan kebenaran dengan menguji kenyataan, melalui kesetaraan',
      ),
      code: 'expect(true, __);',
      answers: ['true'],
      verify: () => [true],
      explanation: const Tr(
        'expect(actual, expected) passes only when both sides are equal. Dart '
            'has exactly two bool values, true and false, and nothing else '
            'stands in for them.',
        'expect(actual, expected) hanya lolos jika kedua sisinya setara. Dart '
            'punya tepat dua nilai bool, true dan false, dan tidak ada nilai '
            'lain yang bisa menggantikannya.',
      ),
      docs: 'https://dart.dev/language/built-in-types#booleans',
      mistakes: const [
        Mistake(['false'], Tr(
          'expect compares the value on the left with the one we give it. '
              'What is on the left?',
          'expect membandingkan nilai di sebelah kiri dengan nilai yang kita '
              'berikan. Apa yang ada di sebelah kiri?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'To understand reality, we must compare our expectations against reality',
        'Untuk memahami kenyataan, kita harus membandingkan harapan dengan kenyataan',
      ),
      code: 'expect(1 + 1, __);',
      answers: ['2'],
      verify: () => [1 + 1],
      explanation: const Tr(
        'Adding two ints gives an int, so the result is 2, not 2.0. Dart keeps '
            'whole numbers whole until an operation such as / asks for a '
            'fraction.',
        'Menjumlahkan dua int menghasilkan int, jadi hasilnya 2, bukan 2.0. '
            'Dart menjaga bilangan bulat tetap bulat sampai ada operasi seperti '
            '/ yang meminta pecahan.',
      ),
      docs: 'https://dart.dev/language/operators#arithmetic-operators',
      mistakes: const [
        Mistake(["'11'"], Tr(
          'These are numbers, not strings: + adds them rather than gluing '
              'them together.',
          'Ini angka, bukan string: + menjumlahkannya, bukan '
              'menyambungkannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Objects of different types are rarely equal',
        'Objek dengan tipe berbeda jarang sekali setara',
      ),
      code: "expect(1 == '1', __);",
      answers: ['false'],
      // ignore: unrelated_type_equality_checks
      verify: () => [1 == '1'],
      explanation: const Tr(
        'Dart never converts one side of == to match the other, unlike '
            "JavaScript's loose ==. An int and a String are never equal, and the "
            'analyzer even warns that this comparison is always false.',
        'Dart tidak pernah mengubah salah satu sisi == agar cocok dengan sisi '
            'lainnya, berbeda dengan == longgar di JavaScript. Sebuah int dan '
            'sebuah String tidak pernah setara, dan analyzer bahkan '
            'memperingatkan bahwa perbandingan ini selalu false.',
      ),
      docs: 'https://dart.dev/language/operators#equality-and-relational-operators',
      mistakes: const [
        Mistake(['true'], Tr(
          'They look alike when printed, but Dart does not convert text into a '
              'number to compare them. Is a number ever a piece of text?',
          'Keduanya tampak sama saat dicetak, tetapi Dart tidak mengubah teks '
              'menjadi angka untuk membandingkannya. Mungkinkah sebuah angka '
              'adalah sepotong teks?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Yet numbers compare by value, whatever their form',
        'Namun angka dibandingkan berdasarkan nilainya, apa pun bentuknya',
      ),
      code: 'expect(1 == 1.0, __);',
      answers: ['true'],
      verify: () => [1 == 1.0],
      explanation: const Tr(
        'int and double are both num, and num compares by numeric value, so 1 '
            'and 1.0 are equal even though their runtimeTypes differ. That is '
            'why expect accepts 1.0 where a test expects 1.',
        'int dan double sama-sama num, dan num dibandingkan berdasarkan nilai '
            'angkanya, jadi 1 dan 1.0 setara walaupun runtimeType-nya berbeda. '
            'Itulah sebabnya expect menerima 1.0 ketika sebuah test '
            'mengharapkan 1.',
      ),
      docs: 'https://api.dart.dev/dart-core/num/operator_equals.html',
      mistakes: const [
        Mistake(['false'], Tr(
          'The types differ, but both stand for the same quantity. What does '
              'num compare: the type, or the value?',
          'Tipenya berbeda, tetapi keduanya mewakili besaran yang sama. Apa '
              'yang dibandingkan oleh num: tipenya, atau nilainya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Strings with the same characters are equal',
        'String dengan karakter yang sama adalah setara',
      ),
      code: "expect('ko' + 'an', __);",
      answers: ["'koan'"],
      // ignore: prefer_adjacent_string_concatenation
      verify: () => ['ko' + 'an'],
      explanation: const Tr(
        'Strings compare by their characters, not by identity, so a string '
            'built at runtime equals a literal with the same text. The + '
            'operator joins strings without adding any space between them.',
        'String dibandingkan berdasarkan karakternya, bukan identitasnya, jadi '
            'string yang dibangun saat program berjalan setara dengan literal '
            'yang teksnya sama. Operator + menyambung string tanpa menambahkan '
            'spasi di antaranya.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/operator_plus.html',
      mistakes: const [
        Mistake(["'ko an'"], Tr(
          '+ joins strings exactly as they are. Where would a space come from?',
          '+ menyambung string persis apa adanya. Dari mana spasi itu berasal?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Two lists with the same elements are still two different lists',
        'Dua list dengan elemen yang sama tetaplah dua list yang berbeda',
      ),
      code: 'expect([1, 2] == [1, 2], __);',
      answers: ['false'],
      verify: () => [_list(1) == _list(1)],
      explanation: const Tr(
        'List does not override ==, so it inherits identity comparison from '
            'Object: two separate lists are never ==, whatever they hold. To '
            'compare contents, use listEquals from Flutter or ListEquality from '
            'package:collection.',
        'List tidak meng-override ==, jadi ia mewarisi perbandingan identitas '
            'dari Object: dua list terpisah tidak pernah ==, apa pun isinya. '
            'Untuk membandingkan isinya, gunakan listEquals dari Flutter atau '
            'ListEquality dari package:collection.',
      ),
      docs: 'https://api.dart.dev/dart-core/Object/operator_equals.html',
      mistakes: const [
        Mistake(['true'], Tr(
          'Lists compare by identity, not by contents. Are these two the same '
              'object?',
          'List dibandingkan berdasarkan identitas, bukan isinya. Apakah '
              'keduanya objek yang sama?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Unless they are the very same constant',
        'Kecuali keduanya adalah konstanta yang sama persis',
      ),
      code: 'expect(identical(const [1, 2], const [1, 2]), __);',
      answers: ['true'],
      verify: () => [identical(const [1, 2], const [1, 2])],
      explanation: const Tr(
        'Constants are canonicalized: the compiler creates each distinct '
            'constant value only once, so both expressions refer to the very '
            'same object. This is also why const widgets are cheap for Flutter '
            'to rebuild.',
        'Konstanta dikanonisasi: compiler hanya membuat setiap nilai konstanta '
            'yang berbeda satu kali, sehingga kedua ekspresi merujuk ke objek '
            'yang sama persis. Inilah juga alasan widget const murah untuk '
            'di-rebuild oleh Flutter.',
      ),
      docs: 'https://dart.dev/language/variables#final-and-const',
      mistakes: const [
        Mistake(['false'], Tr(
          'Without const these would be two objects. What does the compiler do '
              'when it meets the same constant twice?',
          'Tanpa const, keduanya akan menjadi dua objek. Apa yang dilakukan '
              'compiler saat bertemu konstanta yang sama dua kali?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Something is not equal to nothing',
        'Sesuatu tidak sama dengan ketiadaan',
      ),
      code: 'expect(0 == null, __);',
      answers: ['false'],
      // ignore: unnecessary_null_comparison
      verify: () => [_zero() == null],
      explanation: const Tr(
        'null is equal only to null. Dart has no "falsy" values: 0, an empty '
            'string and false are all real values, and an if condition must be '
            'an actual bool.',
        'null hanya setara dengan null. Dart tidak punya nilai "falsy": 0, '
            'string kosong, dan false semuanya nilai yang nyata, dan kondisi if '
            'harus berupa bool sungguhan.',
      ),
      docs: 'https://dart.dev/language/built-in-types#booleans',
      mistakes: const [
        Mistake(['true'], Tr(
          'In some languages 0 counts as "nothing". In Dart, is zero an absence '
              'of value?',
          'Di beberapa bahasa, 0 dianggap "ketiadaan". Di Dart, apakah nol '
              'berarti tidak ada nilai?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Every value knows its own type',
        'Setiap nilai mengetahui tipenya sendiri',
      ),
      code: "expect('hello'.runtimeType, __);",
      answers: ['String'],
      verify: () => ['hello'.runtimeType],
      explanation: const Tr(
        'runtimeType returns a Type object describing the value at runtime. In '
            "real code prefer an is check, such as 'hello' is String: it also "
            'accepts subtypes and lets Dart promote the variable.',
        'runtimeType mengembalikan objek Type yang menggambarkan nilai itu saat '
            "program berjalan. Dalam kode sungguhan, lebih baik pakai is, misalnya "
            "'hello' is String: ia juga menerima subtipe dan membuat Dart bisa "
            'mempromosikan variabelnya.',
      ),
      docs: 'https://api.dart.dev/dart-core/Object/runtimeType.html',
      mistakes: const [
        Mistake(["'String'"], Tr(
          'A quoted value is just more text. runtimeType gives back a Type, '
              'which we write as a name.',
          'Nilai bertanda kutip hanyalah teks biasa. runtimeType mengembalikan '
              'sebuah Type, yang kita tulis sebagai nama.',
        )),
        Mistake(['Object'], Tr(
          'Every string is an Object, but runtimeType reports the most specific '
              'type of the value.',
          'Setiap string memang Object, tetapi runtimeType melaporkan tipe '
              'yang paling spesifik dari nilainya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A class may decide for itself what equal means',
        'Sebuah kelas boleh menentukan sendiri apa arti setara',
      ),
      code: r'''
class Point {
  Point(this.x, this.y);
  final int x, y;
  @override
  bool operator ==(Object o) => o is Point && o.x == x && o.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}
expect(Point(1, 2) == Point(1, 2), __);
expect(identical(Point(1, 2), Point(1, 2)), __);
expect({Point(1, 2), Point(1, 2)}.length, __);''',
      answers: ['true', 'false', '1'],
      capstone: true,
      verify: () => [
        _Point(1, 2) == _Point(1, 2),
        identical(_Point(1, 2), _Point(1, 2)),
        {_Point(1, 2), _Point(1, 2)}.length,
      ],
      explanation: const Tr(
        'Overriding == gives Point value equality, but identical still asks '
            'whether two references are the same object, and each call creates '
            'a new one. A set relies on both == and hashCode, which is why they '
            'must always be overridden together.',
        'Meng-override == memberi Point kesetaraan berdasarkan nilai, tetapi '
            'identical tetap bertanya apakah dua referensi adalah objek yang '
            'sama, dan setiap pemanggilan membuat objek baru. Set bergantung '
            'pada == dan hashCode sekaligus, itulah sebabnya keduanya harus '
            'selalu di-override bersama.',
      ),
      docs: 'https://dart.dev/effective-dart/design#equality',
      mistakes: const [
        Mistake(['false', null, null], Tr(
          'Plain lists compare by identity, but this class defines its own ==. '
              'What does it compare?',
          'List biasa dibandingkan berdasarkan identitas, tetapi kelas ini '
              'mendefinisikan == sendiri. Apa yang dibandingkannya?',
        )),
        Mistake([null, 'true', null], Tr(
          'identical ignores our ==. Without const, is each Point(1, 2) a new '
              'object?',
          'identical mengabaikan == buatan kita. Tanpa const, apakah setiap '
              'Point(1, 2) adalah objek baru?',
        )),
        Mistake([null, null, '2'], Tr(
          'A set spots duplicates with == and hashCode, and this class '
              'overrides both.',
          'Set mengenali duplikat dengan == dan hashCode, dan kelas ini '
              'meng-override keduanya.',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold them into constants.
List<int> _list(int start) => [start, start + 1];
int? _zero() => 0;

class _Point {
  _Point(this.x, this.y);
  final int x, y;
  @override
  bool operator ==(Object o) => o is _Point && o.x == x && o.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}

import '../../engine/koan.dart';

final numbers = Category(
  id: 'numbers',
  title: const Tr('Numbers', 'Angka'),
  intro: const Tr(
    'Whole or fractional, every number knows which it is.',
    'Bulat atau pecahan, setiap angka tahu jati dirinya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Division with / keeps the fraction',
        'Pembagian dengan / tetap menyimpan pecahannya',
      ),
      code: 'expect(7 / 2, __);',
      answers: ['3.5'],
      verify: () => [_n(7) / 2],
      explanation: const Tr(
        '/ always produces a double, even when both operands are ints. Dart '
            'never silently drops the fraction; when we want a whole number, '
            'we ask for it with a different operator.',
        '/ selalu menghasilkan double, bahkan ketika kedua operannya int. Dart '
            'tidak pernah diam-diam membuang pecahannya; jika kita menginginkan '
            'bilangan bulat, kita memintanya dengan operator lain.',
      ),
      docs: 'https://dart.dev/language/operators#arithmetic-operators',
      mistakes: const [
        Mistake(['3'], Tr(
          'That would be integer division, which is a different operator. '
              'Does / drop the fraction?',
          'Itu pembagian bilangan bulat, yang memakai operator lain. Apakah / '
              'membuang pecahannya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Even when the division comes out even',
        'Bahkan ketika hasil baginya bulat',
      ),
      code: 'expect(6 / 2, __);',
      answers: ['3.0'],
      hint: const Tr(
        'The slash has only one return type.',
        'Garis miring hanya punya satu tipe kembalian.',
      ),
      verify: () => [_n(6) / 2],
      explanation: const Tr(
        'The return type of / is double, whatever the values happen to be, so '
            '6 / 2 is 3.0. Its static type never depends on whether the '
            'division comes out even.',
        'Tipe kembalian / adalah double, berapa pun nilainya, jadi 6 / 2 '
            'adalah 3.0. Tipe statisnya tidak pernah bergantung pada apakah '
            'hasil baginya bulat.',
      ),
      docs: 'https://api.dart.dev/dart-core/num/operator_divide.html',
    ),
    Koan(
      prompt: const Tr(
        'The tilde-slash keeps only the whole part',
        'Tilde-garis miring hanya menyisakan bagian bulatnya',
      ),
      code: 'expect(7 ~/ 2, __);',
      answers: ['3'],
      verify: () => [_n(7) ~/ 2],
      explanation: const Tr(
        '~/ divides and truncates, returning an int: the fraction is cut off '
            'toward zero, not rounded. It is the operator to use for things '
            'like the number of whole pages or minutes.',
        '~/ membagi lalu memotong, dan mengembalikan int: pecahannya dipotong '
            'ke arah nol, bukan dibulatkan. Inilah operator untuk menghitung '
            'hal seperti jumlah halaman atau menit yang utuh.',
      ),
      docs: 'https://api.dart.dev/dart-core/num/operator_truncate_divide.html',
      mistakes: const [
        Mistake(['4'], Tr(
          '~/ does not round to the nearest whole number.',
          '~/ tidak membulatkan ke bilangan bulat terdekat.',
        )),
        Mistake(['3.5'], Tr(
          'That is what / gives. What does the tilde change?',
          'Itulah hasil dari /. Apa yang diubah oleh tilde?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A num can hold either kind',
        'num dapat menampung keduanya',
      ),
      code: r'''
num n = 3;
n += 0.5;
expect(n, __);''',
      answers: ['3.5'],
      verify: () {
        num n = _n(3);
        n += 0.5;
        return [n];
      },
      explanation: const Tr(
        'num is the supertype of int and double, so the variable may hold '
            'either. It starts as the int 3, and adding 0.5 produces the double '
            '3.5; with int n, the second line would not compile.',
        'num adalah supertipe dari int dan double, jadi variabel ini boleh '
            'memegang keduanya. Ia bermula sebagai int 3, dan menambahkan 0.5 '
            'menghasilkan double 3.5; dengan int n, baris kedua tidak akan '
            'lolos kompilasi.',
      ),
      docs: 'https://api.dart.dev/dart-core/num-class.html',
      mistakes: const [
        Mistake(['3'], Tr(
          'num does not force a whole number. What does 3 + 0.5 produce?',
          'num tidak memaksa bilangan bulat. Berapa hasil 3 + 0.5?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Two kinds of remainder, alike until they meet a negative',
        'Dua jenis sisa bagi, serupa sampai bertemu bilangan negatif',
      ),
      code: r'''
expect(-7 % 3, __);
expect((-7).remainder(3), __);''',
      answers: ['2', '-1'],
      hint: const Tr(
        'One never goes below zero; the other follows the sign of the left '
            'side.',
        'Yang satu tidak pernah di bawah nol; yang lain mengikuti tanda di '
            'sisi kiri.',
      ),
      verify: () => [-_n(7) % 3, (-_n(7)).remainder(3)],
      explanation: const Tr(
        "Dart's % is a Euclidean modulo: with a positive divisor the result is "
            'never negative, which makes it ideal for wrapping around a clock '
            'or a list index. remainder behaves like % in C or JavaScript and '
            'keeps the sign of the dividend.',
        'Operator % di Dart adalah modulo Euklides: dengan pembagi positif, '
            'hasilnya tidak pernah negatif, sehingga cocok untuk berputar '
            'mengelilingi jam atau indeks list. remainder berperilaku seperti % '
            'di C atau JavaScript dan mengikuti tanda bilangan yang dibagi.',
      ),
      docs: 'https://api.dart.dev/dart-core/num/operator_modulo.html',
      mistakes: const [
        Mistake(['-1', null], Tr(
          'That is how % behaves in JavaScript or C. Can Dart\'s % go below '
              'zero?',
          'Begitulah % bekerja di JavaScript atau C. Bisakah % di Dart bernilai '
              'di bawah nol?',
        )),
        Mistake([null, '2'], Tr(
          'remainder follows the sign of the number being divided.',
          'remainder mengikuti tanda dari bilangan yang dibagi.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A double can step down into an int',
        'Sebuah double bisa turun menjadi int',
      ),
      code: r'''
expect(2.7.floor(), __);
expect(2.5.round(), __);''',
      answers: ['2', '3'],
      verify: () => [_d(2.7).floor(), _d(2.5).round()],
      explanation: const Tr(
        'floor always rounds down, and round goes to the nearest int, with '
            'halves going away from zero, so 2.5 becomes 3 and -2.5 becomes -3. '
            'Both return an int; floorToDouble and roundToDouble keep a double.',
        'floor selalu membulatkan ke bawah, dan round ke int terdekat, dengan '
            'nilai setengah menjauhi nol, jadi 2.5 menjadi 3 dan -2.5 menjadi '
            '-3. Keduanya mengembalikan int; floorToDouble dan roundToDouble '
            'tetap menghasilkan double.',
      ),
      docs: 'https://api.dart.dev/dart-core/double/round.html',
      mistakes: const [
        Mistake(['3', null], Tr(
          'floor never goes up, however close the next whole number is.',
          'floor tidak pernah naik, sedekat apa pun bilangan bulat berikutnya.',
        )),
        Mistake([null, '2'], Tr(
          'Some languages round halves to the even neighbour. Dart\'s round '
              'does not.',
          'Beberapa bahasa membulatkan nilai setengah ke tetangga yang genap. '
              'round di Dart tidak begitu.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Below zero, falling and cutting are not the same',
        'Di bawah nol, jatuh dan memotong tidaklah sama',
      ),
      code: r'''
expect((-2.7).floor(), __);
expect((-2.7).truncate(), __);''',
      answers: ['-3', '-2'],
      hint: const Tr(
        'floor moves toward negative infinity; truncate moves toward zero.',
        'floor bergerak ke arah minus tak hingga; truncate bergerak ke arah '
            'nol.',
      ),
      verify: () => [(-_d(2.7)).floor(), (-_d(2.7)).truncate()],
      explanation: const Tr(
        'floor moves toward negative infinity and truncate toward zero; for '
            'positive numbers they agree. The parentheses matter too: '
            '-2.7.floor() means -(2.7.floor()), which is -2.',
        'floor bergerak ke arah minus tak hingga dan truncate ke arah nol; '
            'untuk bilangan positif keduanya sama. Tanda kurungnya juga '
            'penting: -2.7.floor() berarti -(2.7.floor()), yaitu -2.',
      ),
      docs: 'https://api.dart.dev/dart-core/double/truncate.html',
      mistakes: const [
        Mistake(['-2', null], Tr(
          'For a negative number, going down means moving further from zero.',
          'Untuk bilangan negatif, turun berarti makin menjauh dari nol.',
        )),
        Mistake([null, '-3'], Tr(
          'truncate simply drops the digits after the point.',
          'truncate hanya membuang angka di belakang koma.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Distance from zero, and bounds that cannot be crossed',
        'Jarak dari nol, dan batas yang tak bisa dilampaui',
      ),
      code: r'''
expect((-5).abs(), __);
expect(15.clamp(0, 10), __);''',
      answers: ['5', '10'],
      verify: () => [(-_n(5)).abs(), _n(15).clamp(0, 10)],
      explanation: const Tr(
        'abs gives the distance from zero, so it is never negative. '
            'clamp(lower, upper) returns the value itself when it is inside the '
            'range and the nearest bound otherwise, handy for sliders, volumes '
            'and progress bars.',
        'abs memberikan jarak dari nol, jadi tidak pernah negatif. '
            'clamp(lower, upper) mengembalikan nilai itu sendiri jika berada di '
            'dalam rentang, dan batas terdekat jika tidak, berguna untuk '
            'slider, volume, dan progress bar.',
      ),
      docs: 'https://api.dart.dev/dart-core/num/clamp.html',
      mistakes: const [
        Mistake(['-5', null], Tr(
          'abs measures a distance, and a distance is never negative.',
          'abs mengukur jarak, dan jarak tidak pernah negatif.',
        )),
        Mistake([null, '15'], Tr(
          'clamp does more than check the bounds: it keeps the value inside '
              'them.',
          'clamp tidak sekadar memeriksa batas: ia menjaga nilainya tetap di '
              'dalamnya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Text can become a number, of the kind we ask for',
        'Teks bisa menjadi angka, sesuai jenis yang kita minta',
      ),
      code: r'''
expect(int.parse('42'), __);
expect(double.parse('42'), __);''',
      answers: ['42', '42.0'],
      verify: () => [int.parse('42'), double.parse('42')],
      explanation: const Tr(
        'Each parse produces its own type: double.parse happily reads "42" as '
            '42.0, while int.parse("42.0") would throw a FormatException. '
            'num.parse picks whichever kind the text describes.',
        'Setiap parse menghasilkan tipenya sendiri: double.parse dengan senang '
            'hati membaca "42" sebagai 42.0, sedangkan int.parse("42.0") akan '
            'melempar FormatException. num.parse memilih jenis yang sesuai '
            'dengan teksnya.',
      ),
      docs: 'https://api.dart.dev/dart-core/double/parse.html',
      mistakes: const [
        Mistake(["'42'", null], Tr(
          'parse turns text into a number, so the quotes are gone.',
          'parse mengubah teks menjadi angka, jadi tanda kutipnya hilang.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Not every text is a number, and tryParse admits it',
        'Tidak semua teks adalah angka, dan tryParse mengakuinya',
      ),
      code: "expect(int.tryParse('forty-two'), __);",
      answers: ['null'],
      verify: () => [int.tryParse('forty-two')],
      explanation: const Tr(
        'tryParse returns null instead of throwing a FormatException, so it '
            'pairs naturally with ??: int.tryParse(input) ?? 0. It reads '
            'digits, not words.',
        'tryParse mengembalikan null alih-alih melempar FormatException, jadi '
            'ia cocok dipasangkan dengan ??: int.tryParse(input) ?? 0. Ia '
            'membaca digit, bukan kata-kata.',
      ),
      docs: 'https://api.dart.dev/dart-core/int/tryParse.html',
      mistakes: const [
        Mistake(['42'], Tr(
          'tryParse reads digits, not English words.',
          'tryParse membaca digit, bukan kata-kata dalam bahasa Inggris.',
        )),
        Mistake(['0'], Tr(
          'tryParse does not invent a default. Something else would have to '
              'supply one.',
          'tryParse tidak mengarang nilai default. Harus ada hal lain yang '
              'menyediakannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Rough scores, made fair and then averaged',
        'Skor yang kasar, dirapikan lalu dirata-ratakan',
      ),
      code: r'''
final raw = ['7', 'ten', '9', '-3'];
final scores = [
  for (final s in raw) (int.tryParse(s) ?? 0).clamp(0, 10),
];
final average = scores.reduce((a, b) => a + b) / scores.length;
expect(scores, __);
expect(average, __);
expect(average.round(), __);''',
      answers: ['[7, 0, 9, 0]', '4.0', '4'],
      capstone: true,
      verify: () {
        final raw = [_text('7'), 'ten', '9', '-3'];
        final scores = [
          for (final s in raw) (int.tryParse(s) ?? 0).clamp(0, 10),
        ];
        final average = scores.reduce((a, b) => a + b) / scores.length;
        return [scores, average, average.round()];
      },
      explanation: const Tr(
        'tryParse turns bad text into null and ?? turns null into 0, then clamp '
            'pulls -3 up to the lower bound. Dividing with / yields the double '
            '4.0 even though the sum divides evenly, and round brings it back '
            'to an int.',
        'tryParse mengubah teks yang buruk menjadi null dan ?? mengubah null '
            'menjadi 0, lalu clamp menarik -3 naik ke batas bawah. Pembagian '
            'dengan / menghasilkan double 4.0 walaupun jumlahnya habis dibagi, '
            'dan round mengembalikannya menjadi int.',
      ),
      docs: 'https://dart.dev/language/built-in-types#numbers',
      mistakes: const [
        Mistake(['[7, 0, 9, -3]', null, null], Tr(
          'Look again at what clamp does to a score below its lower bound.',
          'Perhatikan lagi apa yang dilakukan clamp pada skor di bawah batas '
              'bawahnya.',
        )),
        Mistake(['[7, 9, 0]', null, null], Tr(
          'Nothing is dropped: ?? gives every failed parse a value.',
          'Tidak ada yang dibuang: ?? memberi nilai pada setiap parse yang '
              'gagal.',
        )),
        Mistake([null, '3.25', null], Tr(
          'Did every score pass through clamp before the average?',
          'Apakah setiap skor sudah melewati clamp sebelum dirata-ratakan?',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold them into constants.
int _n(int value) => value;
double _d(double value) => value;
String _text(String value) => value;

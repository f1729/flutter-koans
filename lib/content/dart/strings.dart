import '../../engine/koan.dart';

final strings = Category(
  id: 'strings',
  title: const Tr('Strings', 'String'),
  intro: const Tr(
    'Text flows through every program; let us learn its shape.',
    'Teks mengalir di setiap program; mari kita pelajari bentuknya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A string can carry the value of a name',
        'String dapat membawa nilai dari sebuah nama',
      ),
      code: r'''
final name = 'Ratu';
expect('Hello, $name!', __);''',
      answers: ["'Hello, Ratu!'"],
      verify: () {
        final name = _text('Ratu');
        return ['Hello, $name!'];
      },
      explanation: const Tr(
        r'$name inserts the value of name into the string, calling toString() '
            'on it if needed. This interpolation is the idiomatic way to build '
            'text in Dart, preferred over joining pieces with +.',
        r'$name menyisipkan nilai name ke dalam string, sambil memanggil '
            'toString() jika perlu. Interpolasi ini adalah cara yang lazim untuk '
            'menyusun teks di Dart, lebih disukai daripada menyambung potongan '
            'dengan +.',
      ),
      docs: 'https://dart.dev/language/built-in-types#string-interpolation',
      mistakes: const [
        Mistake([r"'Hello, $name!'"], Tr(
          r'Inside ordinary quotes, $ is not plain text: it asks for a value.',
          r'Di dalam tanda kutip biasa, $ bukan teks biasa: ia meminta sebuah '
              'nilai.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Braces let any expression speak inside a string',
        'Kurung kurawal membiarkan ekspresi apa pun bersuara di dalam string',
      ),
      code: r"expect('1 + 1 = ${1 + 1}', __);",
      answers: ["'1 + 1 = 2'"],
      verify: () => ['1 + 1 = ${_n(1) + 1}'],
      explanation: const Tr(
        r'${...} evaluates any expression and inserts the result. Braces are '
            r'needed whenever the expression is more than a single name, such as '
            r'${user.name} or ${items.length}.',
        r'${...} mengevaluasi ekspresi apa pun lalu menyisipkan hasilnya. '
            r'Kurung kurawal dibutuhkan setiap kali ekspresinya lebih dari '
            r'sekadar satu nama, misalnya ${user.name} atau ${items.length}.',
      ),
      docs: 'https://dart.dev/language/built-in-types#string-interpolation',
      mistakes: const [
        Mistake(["'1 + 1 = 11'"], Tr(
          'Inside the braces, 1 + 1 is an expression on two ints. Is anything '
              'being joined as text there?',
          'Di dalam kurung kurawal, 1 + 1 adalah ekspresi pada dua int. Apakah '
              'ada yang disambung sebagai teks di sana?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A string knows its length, and every character has its place',
        'String tahu panjangnya, dan setiap karakter punya tempatnya',
      ),
      code: r'''
expect('koan'.length, __);
expect('koan'[0], __);''',
      answers: ['4', "'k'"],
      verify: () => [_text('koan').length, _text('koan')[0]],
      explanation: const Tr(
        'Indexing a string gives another String of length one; Dart has no '
            'separate char type. length and [] count UTF-16 code units, so for '
            'emoji and other user-perceived characters use the characters '
            'package.',
        'Mengindeks string menghasilkan String lain dengan panjang satu; Dart '
            'tidak punya tipe char tersendiri. length dan [] menghitung code '
            'unit UTF-16, jadi untuk emoji dan karakter lain seperti yang '
            'dilihat pengguna, gunakan package characters.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/operator_get.html',
      mistakes: const [
        Mistake(['3', null], Tr(
          'length counts the characters; it is not the last index.',
          'length menghitung jumlah karakter; ia bukan indeks terakhir.',
        )),
        Mistake([null, "'o'"], Tr(
          'Where does counting start in Dart?',
          'Dari mana hitungan dimulai di Dart?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A raw string knows no escapes',
        'String raw tidak mengenal escape',
      ),
      code: r'''
expect(r'\n'.length, __);
expect('\n'.length, __);''',
      answers: ['2', '1'],
      hint: const Tr(
        'Count the characters we can see, then the ones Dart sees.',
        'Hitung karakter yang terlihat oleh kita, lalu yang terlihat oleh '
            'Dart.',
      ),
      verify: () => [_text(r'\n').length, _text('\n').length],
      explanation: const Tr(
        r'An r prefix makes a raw string, where backslashes and $ are ordinary '
            r'characters: r"\n" is a backslash and an n. Raw strings keep regular '
            'expressions and Windows paths readable.',
        r'Awalan r membuat string raw, tempat garis miring terbalik dan $ '
            r'menjadi karakter biasa: r"\n" adalah garis miring terbalik dan '
            'huruf n. String raw membuat regular expression dan path Windows '
            'tetap mudah dibaca.',
      ),
      docs: 'https://dart.dev/language/built-in-types#strings',
      mistakes: const [
        Mistake(['1', null], Tr(
          'In a raw string, a backslash is just a backslash.',
          'Di dalam string raw, garis miring terbalik hanyalah garis miring '
              'terbalik.',
        )),
        Mistake([null, '2'], Tr(
          'Without r, the escape becomes a single newline character.',
          'Tanpa r, escape itu menjadi satu karakter baris baru.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Three quotes let a string flow across many lines',
        'Tiga tanda kutip membuat string bisa mengalir melintasi banyak baris',
      ),
      code: r'''
final haiku = """
old pond
frog""";
expect(haiku.split('\n'), __);''',
      answers: ["['old pond', 'frog']"],
      hint: const Tr(
        'Look closely at the line break right after the opening quotes.',
        'Perhatikan baik-baik baris baru tepat setelah tanda kutip pembuka.',
      ),
      verify: () => [_text(_haiku).split('\n')],
      explanation: const Tr(
        'Triple quotes allow line breaks inside a string, and Dart ignores a '
            'line break that comes right after the opening quotes. So the text '
            'starts with "old pond", and splitting on newlines gives two lines.',
        'Tiga tanda kutip mengizinkan baris baru di dalam string, dan Dart '
            'mengabaikan baris baru yang muncul tepat setelah tanda kutip '
            'pembuka. Jadi teksnya dimulai dengan "old pond", dan memecahnya di '
            'setiap baris baru menghasilkan dua baris.',
      ),
      docs: 'https://dart.dev/language/built-in-types#strings',
      mistakes: const [
        Mistake(["['', 'old pond', 'frog']"], Tr(
          'Dart treats a line break right after opening triple quotes '
              'specially.',
          'Dart memperlakukan baris baru tepat setelah tiga tanda kutip pembuka '
              'secara khusus.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A slice begins where we say and stops just before its end',
        'Sebuah potongan dimulai di tempat yang kita tentukan dan berhenti '
            'tepat sebelum ujungnya',
      ),
      code: r'''
expect('watermelon'.substring(0, 5), __);
expect('watermelon'.substring(5), __);''',
      answers: ["'water'", "'melon'"],
      verify: () => [
        _text('watermelon').substring(0, 5),
        _text('watermelon').substring(5),
      ],
      explanation: const Tr(
        'substring(start, end) includes start and excludes end, so its length '
            'is always end - start. Leaving out end takes everything to the end '
            'of the string.',
        'substring(start, end) menyertakan start dan tidak menyertakan end, '
            'jadi panjangnya selalu end - start. Jika end dihilangkan, semuanya '
            'sampai akhir string ikut diambil.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/substring.html',
      mistakes: const [
        Mistake(["'waterm'", null], Tr(
          'The character at the end index is not included.',
          'Karakter pada indeks end tidak ikut diambil.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'We may ask what a string holds, and how it begins',
        'Kita boleh bertanya apa isi sebuah string, dan bagaimana ia dimulai',
      ),
      code: r'''
expect('breathe in'.contains('the'), __);
expect('breathe in'.startsWith('in'), __);''',
      answers: ['true', 'false'],
      verify: () => [
        _text('breathe in').contains('the'),
        _text('breathe in').startsWith('in'),
      ],
      explanation: const Tr(
        'contains finds a match anywhere, even inside another word, as in '
            'brea-the. startsWith only looks at the very beginning; endsWith '
            'would say true here. All three are case-sensitive.',
        'contains menemukan kecocokan di mana saja, bahkan di dalam kata lain, '
            'seperti pada brea-the. startsWith hanya melihat bagian paling '
            'awal; endsWith akan menjawab true di sini. Ketiganya membedakan '
            'huruf besar dan kecil.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/contains.html',
      mistakes: const [
        Mistake(['false', null], Tr(
          'Look for the letters anywhere, even inside another word.',
          'Carilah huruf-huruf itu di mana saja, bahkan di dalam kata lain.',
        )),
        Mistake([null, 'true'], Tr(
          'startsWith looks only at the very beginning of the string.',
          'startsWith hanya melihat bagian paling awal dari string.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'What is split apart can be joined again',
        'Yang dipecah bisa disatukan kembali',
      ),
      code: r'''
expect('sun,moon,stars'.split(','), __);
expect(['still', 'water'].join(' '), __);''',
      answers: ["['sun', 'moon', 'stars']", "'still water'"],
      verify: () => [
        _text('sun,moon,stars').split(','),
        [_text('still'), 'water'].join(' '),
      ],
      explanation: const Tr(
        "split cuts a string at each separator and returns a List<String>; "
            'join, an Iterable method, does the reverse, placing the separator '
            'only between elements.',
        'split memotong string di setiap pemisah dan mengembalikan '
            'List<String>; join, sebuah method Iterable, melakukan kebalikannya, '
            'dengan menaruh pemisah hanya di antara elemen.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/split.html',
      mistakes: const [
        Mistake(["['sun,moon,stars']", null], Tr(
          'split cuts at every comma it finds.',
          'split memotong di setiap koma yang ditemukannya.',
        )),
        Mistake([null, "'stillwater'"], Tr(
          'Look at the argument given to join.',
          'Perhatikan argumen yang diberikan kepada join.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Let go of the emptiness at the edges',
        'Lepaskan kekosongan di tepian',
      ),
      code: r'''expect('  calm  '.__().toUpperCase(), 'CALM');''',
      answers: ['trim'],
      explanation: const Tr(
        'trim removes whitespace, including tabs and newlines, from both ends '
            'but never from the middle; trimLeft and trimRight clean one side. '
            'Strings are immutable, so it returns a new string.',
        'trim membuang whitespace, termasuk tab dan baris baru, dari kedua '
            'ujung tetapi tidak pernah dari tengah; trimLeft dan trimRight '
            'membersihkan satu sisi saja. String tidak bisa diubah, jadi ia '
            'mengembalikan string baru.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/trim.html',
      mistakes: const [
        Mistake(['trimLeft'], Tr(
          'That cleans only one edge, and there is emptiness on both.',
          'Itu hanya membersihkan satu tepi, padahal kekosongan ada di '
              'keduanya.',
        )),
        Mistake(['trimRight'], Tr(
          'That cleans only one edge, and there is emptiness on both.',
          'Itu hanya membersihkan satu tepi, padahal kekosongan ada di '
              'keduanya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A string can be padded, or repeated',
        'String bisa diberi padding, atau diulang-ulang',
      ),
      code: r'''
expect('7'.padLeft(3, '0'), __);
expect('ha' * 3, __);''',
      answers: ["'007'", "'hahaha'"],
      verify: () => [_text('7').padLeft(3, '0'), _text('ha') * 3],
      explanation: const Tr(
        'padLeft(width, padding) adds padding until the string is width '
            'characters long, which is perfect for clocks and invoice numbers. '
            '* repeats a string, with nothing placed between the copies.',
        'padLeft(width, padding) menambahkan padding sampai panjang string '
            'mencapai width karakter, cocok untuk jam dan nomor faktur. * '
            'mengulang string, tanpa menyisipkan apa pun di antara salinannya.',
      ),
      docs: 'https://api.dart.dev/dart-core/String/padLeft.html',
      mistakes: const [
        Mistake(["'0007'", null], Tr(
          'The first argument is the final width, not how many to add.',
          'Argumen pertama adalah lebar akhirnya, bukan berapa banyak yang '
              'ditambahkan.',
        )),
        Mistake([null, "'ha ha ha'"], Tr(
          '* places nothing between the copies.',
          '* tidak menaruh apa pun di antara salinannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A receipt line, tidy from edge to edge',
        'Sebaris struk, rapi dari tepi ke tepi',
      ),
      code: r'''
String row(String item, int cents) {
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '${item.trim().toUpperCase()} ${cents ~/ 100}.$fraction';
}
expect(row(' tea ', 250), __);
expect(row('rice', 1205), __);
expect(row('ice', 99).length, __);''',
      answers: ["'TEA 2.50'", "'RICE 12.05'", '8'],
      capstone: true,
      verify: () => [_row(' tea ', 250), _row('rice', 1205), _row('ice', 99).length],
      explanation: const Tr(
        'trim and toUpperCase clean the name, ~/ and % split cents into whole '
            r'units and the rest, and padLeft keeps the cents two digits wide. '
            r'Interpolation with ${} then assembles the line without a single +.',
        'trim dan toUpperCase merapikan nama, ~/ dan % memecah sen menjadi '
            'satuan utuh dan sisanya, dan padLeft menjaga sen tetap dua digit. '
            r'Interpolasi dengan ${} lalu menyusun barisnya tanpa satu pun +.',
      ),
      docs: 'https://dart.dev/language/built-in-types#strings',
      mistakes: const [
        Mistake(["'TEA 2.5'", null, null], Tr(
          "How many characters does padLeft(2, '0') leave the cents with?",
          "Berapa karakter yang tersisa untuk sen setelah padLeft(2, '0')?",
        )),
        Mistake(["' TEA  2.50'", null, null], Tr(
          'The name is trimmed before it goes into the line.',
          'Nama itu di-trim sebelum masuk ke dalam baris.',
        )),
        Mistake([null, "'RICE 12.5'", null], Tr(
          '1205 % 100 is a single digit. What does padLeft do with it?',
          '1205 % 100 hanya satu digit. Apa yang dilakukan padLeft terhadapnya?',
        )),
      ],
    ),
  ],
);

String _row(String item, int cents) {
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '${item.trim().toUpperCase()} ${cents ~/ 100}.$fraction';
}

// Must start at column 0: indentation would become part of the string.
const _haiku = """
old pond
frog""";

// Built at runtime so the analyzer does not fold them into constants.
String _text(String value) => value;
int _n(int value) => value;

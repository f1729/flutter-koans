import '../../engine/koan.dart';

final nullSafety = Category(
  id: 'null-safety',
  title: const Tr('Null Safety', 'Null Safety'),
  intro: const Tr(
    'Nothing is a value too, and Dart asks us to face it.',
    'Ketiadaan juga sebuah nilai, dan Dart meminta kita menghadapinya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A nullable name begins with nothing',
        'Nama yang nullable bermula dari ketiadaan',
      ),
      code: r'''
int? count;
expect(count, __);''',
      answers: ['null'],
      verify: () {
        int? count;
        return [count];
      },
      explanation: const Tr(
        'A nullable variable without an initializer starts as null. A '
            'non-nullable local has no default at all: Dart refuses to let us '
            'read it until it has definitely been assigned.',
        'Variabel nullable tanpa initializer bermula dari null. Variabel lokal '
            'yang bukan nullable sama sekali tidak punya nilai default: Dart '
            'menolak kita membacanya sampai ia pasti sudah diisi.',
      ),
      docs: 'https://dart.dev/language/variables#default-value',
      mistakes: const [
        Mistake(['0'], Tr(
          'Dart gives an int no automatic zero. What does an empty nullable '
              'hold?',
          'Dart tidak memberi int nilai nol otomatis. Apa isi variabel '
              'nullable yang masih kosong?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Even nothing has a type',
        'Bahkan ketiadaan pun punya tipe',
      ),
      code: 'expect(null.runtimeType, __);',
      answers: ['Null'],
      verify: () => [null.runtimeType],
      explanation: const Tr(
        'null is the only instance of the class Null. Under sound null safety '
            'Null is not a subtype of Object, which is why int? is really "int '
            'or Null" and why a plain int can never hold null.',
        'null adalah satu-satunya instance dari kelas Null. Dengan sound null '
            'safety, Null bukan subtipe dari Object, itulah sebabnya int? '
            'sesungguhnya berarti "int atau Null" dan int biasa tidak pernah '
            'bisa memegang null.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#nullability-in-the-type-system',
      mistakes: const [
        Mistake(['null'], Tr(
          'That is the value itself. runtimeType gives back its type, written '
              'as a type name.',
          'Itu nilainya sendiri. runtimeType mengembalikan tipenya, yang '
              'ditulis sebagai nama tipe.',
        )),
        Mistake(['Object'], Tr(
          'Under null safety, null is not an Object. It has a class of its own.',
          'Dengan null safety, null bukanlah Object. Ia punya kelasnya sendiri.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When there is nothing, offer something else',
        'Saat yang ada hanya ketiadaan, tawarkan yang lain',
      ),
      code: r'''
String? name;
expect(name ?? 'stranger', __);''',
      answers: ["'stranger'"],
      verify: () => [_nobody() ?? 'stranger'],
      explanation: const Tr(
        'a ?? b gives a when it is not null, and only otherwise evaluates b. '
            'The result is non-nullable here, so it can be used as a plain '
            'String.',
        'a ?? b menghasilkan a jika ia bukan null, dan hanya jika tidak, '
            'barulah b dievaluasi. Hasilnya di sini bukan nullable, jadi bisa '
            'dipakai sebagai String biasa.',
      ),
      docs: 'https://dart.dev/language/operators#conditional-expressions',
      mistakes: const [
        Mistake(['null'], Tr(
          '?? exists precisely to replace null with something else.',
          '?? ada justru untuk mengganti null dengan sesuatu yang lain.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Ask gently, and nothing answers with nothing',
        'Bertanyalah dengan lembut, dan ketiadaan menjawab dengan ketiadaan',
      ),
      code: r'''
String? nobody;
String? somebody = 'Ratu';
expect(nobody?.length, __);
expect(somebody?.length, __);''',
      answers: ['null', '4'],
      verify: () => [_nobody()?.length, _somebody()?.length],
      explanation: const Tr(
        'a?.b reads b only when a is not null; otherwise the whole expression '
            'is null instead of throwing. That is why its type is int?, even '
            'when the receiver turns out to hold a value.',
        'a?.b hanya membaca b jika a bukan null; jika null, seluruh ekspresi '
            'bernilai null alih-alih melempar error. Itulah sebabnya tipenya '
            'int?, bahkan ketika penerimanya ternyata punya nilai.',
      ),
      docs: 'https://dart.dev/language/operators#other-operators',
      mistakes: const [
        Mistake(['0', null], Tr(
          '?. does not make up a number when there is nothing to measure.',
          '?. tidak mengarang angka ketika tidak ada yang bisa diukur.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'One question mark guards the whole chain',
        'Satu tanda tanya menjaga seluruh rantai',
      ),
      code: r'''
String? name;
expect(name?.toUpperCase().length, __);''',
      answers: ['null'],
      hint: const Tr(
        'If the first link is null, nothing after it is evaluated.',
        'Jika mata rantai pertama null, sisanya tidak dievaluasi sama sekali.',
      ),
      verify: () => [_nobody()?.toUpperCase().length],
      explanation: const Tr(
        'Null-aware access short-circuits: once name is null, the rest of the '
            'chain is skipped, so toUpperCase() and length need no ?. of their '
            'own. One ?. at the point where null can appear is enough.',
        'Akses null-aware bersifat short-circuit: begitu name bernilai null, '
            'sisa rantainya dilewati, jadi toUpperCase() dan length tidak perlu '
            '?. sendiri. Cukup satu ?. di titik tempat null bisa muncul.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#smarter-null-aware-methods',
      mistakes: const [
        Mistake(['0'], Tr(
          'Nothing is measured when the chain stops at the first link.',
          'Tidak ada yang diukur ketika rantainya berhenti di mata rantai '
              'pertama.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Fill the empty cup, but never a full one',
        'Isi cangkir yang kosong, jangan yang sudah penuh',
      ),
      code: r'''
int? count;
count ??= 1;
count ??= 2;
expect(count, __);''',
      answers: ['1'],
      hint: const Tr(
        'Before each line, ask whether count is still null.',
        'Sebelum setiap baris, tanyakan apakah count masih null.',
      ),
      verify: () {
        int? count = _none();
        count ??= 1;
        // ignore: dead_null_aware_expression, dead_code
        count ??= 2;
        return [count];
      },
      explanation: const Tr(
        'x ??= v assigns only while x is null, so the first line fills count and '
            'the second does nothing. It is a common way to fill a cache or a '
            'default lazily.',
        'x ??= v hanya mengisi selama x masih null, jadi baris pertama mengisi '
            'count dan baris kedua tidak melakukan apa-apa. Ini cara umum untuk '
            'mengisi cache atau nilai default secara malas.',
      ),
      docs: 'https://dart.dev/language/operators#assignment-operators',
      mistakes: const [
        Mistake(['2'], Tr(
          '??= is not a plain =. Does it overwrite a value that is already '
              'there?',
          '??= bukan = biasa. Apakah ia menimpa nilai yang sudah ada?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When we know more than the compiler, we say so with !',
        'Saat kita tahu lebih banyak daripada compiler, kita menyatakannya '
            'dengan !',
      ),
      code: r'''
final ages = {'ratu': 7};
expect(ages['ratu']! + 1, __);''',
      answers: ['8'],
      verify: () {
        final ages = {'ratu': 7};
        return [ages['ratu']! + 1];
      },
      explanation: const Tr(
        "A map's [] returns a nullable value because the key might be missing. "
            '! casts that away, and throws if we were wrong; when absence is '
            'possible, ?? with a default is the safer choice.',
        'Operator [] pada map mengembalikan nilai nullable karena key-nya '
            'mungkin tidak ada. ! membuang kemungkinan null itu, dan melempar '
            'error jika kita keliru; jika key bisa saja tidak ada, ?? dengan '
            'nilai default adalah pilihan yang lebih aman.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable',
    ),
    Koan(
      prompt: const Tr(
        'But a broken promise breaks loudly',
        'Namun janji yang diingkari akan pecah dengan keras',
      ),
      code: r'''
String? name;
expect(() => name!, throwsA(isA<__>()));''',
      answers: ['TypeError'],
      hint: const Tr(
        'The value turned out not to be of the type we promised.',
        'Nilainya ternyata bukan tipe yang kita janjikan.',
      ),
      explanation: const Tr(
        'x! is a cast to the non-nullable type, and a failed cast throws a '
            'TypeError ("Null check operator used on a null value"). It is an '
            'Error, a sign of a bug to fix, not an Exception to catch.',
        'x! adalah cast ke tipe yang bukan nullable, dan cast yang gagal '
            'melempar TypeError ("Null check operator used on a null value"). '
            'Ini sebuah Error, tanda adanya bug yang perlu diperbaiki, bukan '
            'Exception untuk ditangkap.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#null-assertion-operator',
      mistakes: const [
        Mistake(['NoSuchMethodError'], Tr(
          'That is what calling a method on null used to throw before null '
              'safety. ! fails earlier, as a claim about the type.',
          'Itulah yang dulu dilempar saat memanggil method pada null sebelum '
              'null safety. ! gagal lebih awal, sebagai klaim tentang tipe.',
        )),
        Mistake(['StateError'], Tr(
          'StateError means an object was used at the wrong time. ! makes a '
              'claim about the type of a value.',
          'StateError berarti sebuah objek dipakai pada waktu yang salah. ! '
              'membuat klaim tentang tipe sebuah nilai.',
        )),
        Mistake(['Exception'], Tr(
          'In Dart, Errors and Exceptions are different families. A failed ! '
              'signals a programming bug.',
          'Di Dart, Error dan Exception adalah dua keluarga yang berbeda. ! '
              'yang gagal menandakan bug pemrograman.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Once null is ruled out, the type is promoted',
        'Begitu null tersingkir, tipenya pun dipromosikan',
      ),
      code: r'''
int lengthOf(String? text) {
  if (text == null) return 0;
  return text.__;
}
expect(lengthOf('zen'), 3);''',
      answers: ['length'],
      explanation: const Tr(
        'Flow analysis sees that text cannot be null after the early return, so '
            'it promotes String? to String and length needs no ?. or !. '
            'Promotion works on local variables and parameters, not on fields, '
            'which could change between the check and the use.',
        'Flow analysis melihat bahwa text tidak mungkin null setelah return '
            'lebih awal itu, jadi String? dipromosikan menjadi String dan '
            'length tidak perlu ?. atau !. Promosi berlaku untuk variabel lokal '
            'dan parameter, bukan field, karena field bisa berubah di antara '
            'pemeriksaan dan pemakaiannya.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#type-promotion-on-null-checks',
    ),
    Koan(
      prompt: const Tr(
        'A greeting that is ready for whatever arrives',
        'Sapaan yang siap untuk apa pun yang datang',
      ),
      code: r'''
String greet(Map<String, String?> user) {
  final nick = user['nick']?.trim();
  if (nick != null && nick.isNotEmpty) return 'Hi, $nick';
  return 'Hello, ${user['name'] ?? 'guest'}';
}
expect(greet({'nick': ' ratu '}), __);
expect(greet({'nick': '  ', 'name': 'Budi'}), __);
expect(greet({'name': null}), __);''',
      answers: ["'Hi, ratu'", "'Hello, Budi'", "'Hello, guest'"],
      capstone: true,
      verify: () => [
        _greet({'nick': ' ratu '}),
        _greet({'nick': '  ', 'name': 'Budi'}),
        _greet({'name': null}),
      ],
      explanation: const Tr(
        "A map lookup may give null, ?. carries that null safely through trim, "
            'and the null check promotes nick so isNotEmpty can be called '
            'directly. Finally ?? replaces a missing name, whether the key is '
            'absent or holds null.',
        'Pencarian di map bisa menghasilkan null, ?. membawa null itu dengan '
            'aman melewati trim, dan pemeriksaan null mempromosikan nick '
            'sehingga isNotEmpty bisa langsung dipanggil. Terakhir, ?? '
            'mengganti nama yang hilang, baik key-nya tidak ada maupun bernilai '
            'null.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety',
      mistakes: const [
        Mistake(["'Hi,  ratu '", null, null], Tr(
          'The nick is trimmed before it is used.',
          'Nick-nya di-trim sebelum dipakai.',
        )),
        Mistake([null, "'Hi, '", null], Tr(
          'After trim, what is left of that nick? Look at the second half of '
              'the condition.',
          'Setelah di-trim, apa yang tersisa dari nick itu? Perhatikan paruh '
              'kedua dari kondisinya.',
        )),
        Mistake([null, null, "'Hello, null'"], Tr(
          '?? steps in whenever the value is null, so null never reaches the '
              'string.',
          '?? turun tangan setiap kali nilainya null, jadi null tidak pernah '
              'sampai ke string.',
        )),
      ],
    ),
  ],
);

String _greet(Map<String, String?> user) {
  final nick = user['nick']?.trim();
  if (nick != null && nick.isNotEmpty) return 'Hi, $nick';
  return 'Hello, ${user['name'] ?? 'guest'}';
}

// Built at runtime so the analyzer does not know what they hold.
String? _nobody() => null;
String? _somebody() => 'Ratu';
int? _none() => null;

import '../../engine/koan.dart';
import 'keywords.dart';

final variables = Category(
  id: 'variables',
  title: const Tr('Variables', 'Variabel'),
  intro: const Tr(
    'A name is a promise about the value it holds.',
    'Sebuah nama adalah janji tentang nilai yang dipegangnya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A var may change its mind',
        'Sebuah var boleh berubah pikiran',
      ),
      code: r'''
var count = 1;
count = 2;
expect(count, __);''',
      answers: ['2'],
      verify: () {
        var count = 1;
        count = _two();
        return [count];
      },
      explanation: const Tr(
        'var declares a variable that can be reassigned, as long as the new '
            'value fits the type Dart inferred, here int. Use var for values '
            'that really change, and final for everything else.',
        'var mendeklarasikan variabel yang boleh diisi ulang, selama nilai '
            'barunya cocok dengan tipe yang disimpulkan Dart, di sini int. '
            'Gunakan var untuk nilai yang memang berubah, dan final untuk '
            'sisanya.',
      ),
      docs: 'https://dart.dev/language/variables',
      mistakes: const [
        Mistake(['1'], Tr(
          'var is not frozen: the second line really replaces the value.',
          'var tidak membeku: baris kedua benar-benar mengganti nilainya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Dart infers the type from the first value it sees',
        'Dart menyimpulkan tipe dari nilai pertama yang dilihatnya',
      ),
      code: r'''
var answer = 42;
expect(answer.runtimeType, __);''',
      answers: ['int'],
      verify: () {
        var answer = 42;
        return [answer.runtimeType];
      },
      explanation: const Tr(
        'var is not a type and not dynamic: Dart infers the static type int '
            'from the initializer and fixes it. Assigning a String to answer '
            'later would be a compile error.',
        'var bukanlah tipe dan bukan dynamic: Dart menyimpulkan tipe statis '
            'int dari initializer-nya lalu menetapkannya. Mengisi answer dengan '
            'String nanti akan menjadi error saat kompilasi.',
      ),
      docs: 'https://dart.dev/language/type-system#local-variable-inference',
      mistakes: const [
        Mistake(['var'], Tr(
          'var is a keyword, not a type. Dart replaces it with the type of the '
              'first value.',
          'var adalah kata kunci, bukan tipe. Dart menggantinya dengan tipe '
              'dari nilai pertamanya.',
        )),
        Mistake(['dynamic'], Tr(
          'A var with an initializer is not dynamic: its type is settled '
              'right away.',
          'var yang punya initializer bukanlah dynamic: tipenya langsung '
              'ditetapkan.',
        )),
        Mistake(['num'], Tr(
          'num is a supertype. Inference picks the most specific type of 42.',
          'num adalah supertipe. Inferensi memilih tipe paling spesifik dari '
              '42.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'final binds the name, not the value behind it',
        'final mengikat namanya, bukan nilai di baliknya',
      ),
      code: r'''
final list = [1, 2];
list.add(3);
expect(list, __);''',
      answers: ['[1, 2, 3]'],
      verify: () {
        final list = [1, 2];
        list.add(3);
        return [list];
      },
      explanation: const Tr(
        'final only forbids pointing the name at another object, so list = [] '
            'would not compile, but the list itself is still mutable. For a '
            'list that cannot change, use const or List.unmodifiable.',
        'final hanya melarang nama itu menunjuk ke objek lain, jadi list = [] '
            'tidak akan lolos kompilasi, tetapi list-nya sendiri tetap bisa '
            'diubah. Untuk list yang tidak bisa berubah, gunakan const atau '
            'List.unmodifiable.',
      ),
      docs: 'https://dart.dev/language/variables#final-and-const',
      mistakes: const [
        Mistake(['[1, 2]'], Tr(
          'final stops list = something else. Does it stop the list from '
              'changing inside?',
          'final mencegah list = sesuatu yang lain. Apakah ia mencegah isi '
              'list itu berubah?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Each turn of a loop receives a fresh final',
        'Setiap putaran loop mendapat final yang baru',
      ),
      code: r'''
final squares = <int>[];
for (final n in [1, 2, 3]) {
  squares.add(n * n);
}
expect(squares, __);''',
      answers: ['[1, 4, 9]'],
      verify: () {
        final squares = <int>[];
        for (final n in [1, 2, 3]) {
          squares.add(n * n);
        }
        return [squares];
      },
      explanation: const Tr(
        'A for-in loop creates a new variable for every iteration, so n can be '
            'final even though it takes three values. It also means a closure '
            'created in each turn captures its own n.',
        'Loop for-in membuat variabel baru di setiap iterasi, jadi n boleh '
            'final walaupun ia memegang tiga nilai. Ini juga berarti closure '
            'yang dibuat di setiap putaran menangkap n miliknya sendiri.',
      ),
      docs: 'https://dart.dev/language/loops#for-loops',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'Look at what each turn adds: n itself, or something made from n?',
          'Perhatikan apa yang ditambahkan setiap putaran: n itu sendiri, atau '
              'sesuatu yang dibuat dari n?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Name each as firmly as Dart allows: some values are known before '
            'the program runs, others only once it does',
        'Beri nama setegas yang Dart izinkan: ada nilai yang sudah diketahui '
            'sebelum program berjalan, ada pula yang baru diketahui saat '
            'program berjalan',
      ),
      code: r'''
__ secondsPerHour = 60 * 60;
__ startedAt = DateTime.now();''',
      answers: ['const', 'final'],
      hint: const Tr(
        'Only one of these values can be computed by the compiler.',
        'Hanya salah satu dari nilai ini yang bisa dihitung oleh compiler.',
      ),
      explanation: const Tr(
        'const needs a value the compiler can compute, and 60 * 60 is one. '
            'DateTime.now() is only known once the program runs, so final, '
            'assigned exactly once at runtime, is the firmest promise left.',
        'const membutuhkan nilai yang bisa dihitung compiler, dan 60 * 60 '
            'termasuk di antaranya. DateTime.now() baru diketahui saat program '
            'berjalan, jadi final, yang diisi tepat sekali saat runtime, adalah '
            'janji paling tegas yang tersisa.',
      ),
      docs: 'https://dart.dev/language/variables#final-and-const',
      mistakes: const [
        Mistake([null, 'const'], Tr(
          'DateTime.now() is only known once the program runs. Can the '
              'compiler compute it?',
          'DateTime.now() baru diketahui saat program berjalan. Bisakah '
              'compiler menghitungnya?',
        )),
        Mistake(['final', null], Tr(
          'final works, but the compiler could compute 60 * 60 by itself. Is '
              'there a firmer promise?',
          'final memang berhasil, tetapi compiler bisa menghitung 60 * 60 '
              'sendiri. Adakah janji yang lebih tegas?',
        )),
        Mistake(['var', null], Tr(
          'var allows reassignment. The koan asks for the firmest name Dart '
              'allows.',
          'var mengizinkan pengisian ulang. Koan ini meminta nama paling tegas '
              'yang diizinkan Dart.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A promise to assign later is still a promise',
        'Janji untuk mengisi nanti tetaplah sebuah janji',
      ),
      code: r'''
class Garden {
  __ String flower;
}

final garden = Garden()..flower = 'lotus';
expect(garden.flower, 'lotus');''',
      answers: ['late'],
      hint: const Tr(
        'The field starts without a value, yet its type is not nullable.',
        'Field ini dimulai tanpa nilai, padahal tipenya bukan nullable.',
      ),
      explanation: const Tr(
        'late promises that a non-nullable field will be assigned before it '
            'is read. Dart checks the promise at runtime: reading it too early '
            'throws a LateInitializationError instead of returning null.',
        'late berjanji bahwa field yang bukan nullable akan diisi sebelum '
            'dibaca. Dart memeriksa janji itu saat runtime: membacanya terlalu '
            'awal akan melempar LateInitializationError, bukan mengembalikan '
            'null.',
      ),
      docs: 'https://dart.dev/language/variables#late-variables',
      mistakes: const [
        Mistake(['final'], Tr(
          'A final field must get its value in the declaration or the '
              'constructor. This one is assigned afterwards.',
          'Field final harus mendapat nilainya di deklarasi atau di '
              'constructor. Field ini baru diisi sesudahnya.',
        )),
        Mistake(['required'], Tr(
          'required belongs to named parameters, not to fields.',
          'required milik parameter bernama, bukan milik field.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A late initializer waits until it is needed',
        'Initializer late menunggu sampai benar-benar dibutuhkan',
      ),
      code: r'''
var calls = 0;
late final answer = ++calls * 42;
expect(calls, __);
expect(answer + answer, 84);
expect(calls, __);''',
      answers: ['0', '1'],
      hint: const Tr(
        'Count how many times the initializer is allowed to run.',
        'Hitung berapa kali initializer itu boleh dijalankan.',
      ),
      explanation: const Tr(
        'A late variable with an initializer is lazy: the initializer runs on '
            'the first read, not at the declaration, and for late final only '
            'once. It is a cheap way to defer expensive work until it is '
            'really needed.',
        'Variabel late yang punya initializer bersifat malas: initializer-nya '
            'berjalan saat pertama kali dibaca, bukan saat dideklarasikan, dan '
            'untuk late final hanya sekali. Ini cara murah untuk menunda '
            'pekerjaan mahal sampai benar-benar dibutuhkan.',
      ),
      docs: 'https://dart.dev/null-safety/understanding-null-safety#lazy-initialization',
      mistakes: const [
        Mistake(['1', null], Tr(
          'Declaring a late variable does not run its initializer yet.',
          'Mendeklarasikan variabel late belum menjalankan initializer-nya.',
        )),
        Mistake([null, '2'], Tr(
          'answer is read twice, but how many times may a late final '
              'initializer run?',
          'answer dibaca dua kali, tetapi berapa kali initializer late final '
              'boleh berjalan?',
        )),
      ],
      verify: () {
        var calls = 0;
        late final answer = ++calls * 42;
        final before = calls;
        final sum = answer + answer;
        return [before, sum == 84 ? calls : -1];
      },
    ),
    Koan(
      prompt: const Tr(
        'var settles on a type once; to change shape, a name must let go of '
            'its type',
        'var memilih tipenya sekali saja; agar bisa berganti wujud, sebuah '
            'nama harus melepaskan tipenya',
      ),
      code: r'''
__ shape = 1;
shape = 'circle';
expect(shape, 'circle');''',
      answers: ['dynamic'],
      registry: keywords,
      accept: oneOf({'dynamic', 'Object'}),
      hint: const Tr(
        'Neither var nor int will do here.',
        'Baik var maupun int tidak akan berhasil di sini.',
      ),
      explanation: const Tr(
        'dynamic switches off static checking, so the name accepts anything and '
            'every use is checked only at runtime. Object also holds any '
            'non-null value but keeps type safety: we must check with is before '
            'treating it as a String, which is usually the better choice.',
        'dynamic mematikan pemeriksaan statis, jadi nama itu menerima apa saja '
            'dan setiap pemakaiannya baru diperiksa saat runtime. Object juga '
            'bisa memegang nilai apa pun yang bukan null, tetapi tetap aman '
            'tipe: kita harus memeriksa dengan is sebelum memperlakukannya '
            'sebagai String, dan biasanya itulah pilihan yang lebih baik.',
      ),
      docs: 'https://dart.dev/effective-dart/design#avoid-using-dynamic-unless-you-want-to-disable-static-checking',
      mistakes: const [
        Mistake(['var'], Tr(
          'var infers int from the first value, and a String does not fit in '
              'an int.',
          'var menyimpulkan int dari nilai pertama, dan String tidak muat di '
              'dalam int.',
        )),
        Mistake(['int'], Tr(
          'An int name cannot later hold a String.',
          'Nama bertipe int tidak bisa memegang String di kemudian hari.',
        )),
        Mistake(['String'], Tr(
          'Then the first value, 1, would not fit.',
          'Kalau begitu nilai pertamanya, 1, tidak akan muat.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Each name keeps the promise it was given',
        'Setiap nama menepati janji yang diberikan kepadanya',
      ),
      code: r'''
const greeting = 'Hello';
final visitors = <String>[];
var count = 0;
late final summary = '$greeting, $count visitors';
for (final name in ['Ratu', 'Budi']) {
  visitors.add(name);
  count++;
}
expect(visitors, __);
expect(summary, __);''',
      answers: ["['Ratu', 'Budi']", "'Hello, 2 visitors'"],
      capstone: true,
      verify: () {
        const greeting = 'Hello';
        final visitors = <String>[];
        var count = 0;
        late final summary = '$greeting, $count visitors';
        for (final name in [_text('Ratu'), 'Budi']) {
          visitors.add(name);
          count++;
        }
        return [visitors, summary];
      },
      explanation: const Tr(
        'Each keyword makes a different promise: const is fixed at compile '
            'time, final never points elsewhere though its list may grow, var '
            'may change, and late final waits for its first read, which here '
            'happens after the loop has counted both visitors.',
        'Setiap kata kunci membuat janji yang berbeda: const ditetapkan saat '
            'kompilasi, final tidak pernah menunjuk ke tempat lain walaupun '
            'list-nya boleh bertambah, var boleh berubah, dan late final '
            'menunggu pembacaan pertamanya, yang di sini terjadi setelah loop '
            'menghitung kedua pengunjung.',
      ),
      docs: 'https://dart.dev/language/variables',
      mistakes: const [
        Mistake(['[]', null], Tr(
          'visitors is final, but the list behind the name can still grow.',
          'visitors memang final, tetapi list di balik nama itu tetap bisa '
              'bertambah.',
        )),
        Mistake([null, "'Hello, 0 visitors'"], Tr(
          'summary is late: when does its initializer actually run?',
          'summary bersifat late: kapan initializer-nya benar-benar berjalan?',
        )),
      ],
    ),
  ],
);

// Built at runtime so the analyzer does not fold them into constants.
int _two() => 2;
String _text(String value) => value;

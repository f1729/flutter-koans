import '../../engine/koan.dart';

final functions = Category(
  id: 'functions',
  title: const Tr('Functions', 'Fungsi'),
  intro: const Tr(
    'A function is a value that waits to be called.',
    'Fungsi adalah nilai yang menunggu untuk dipanggil.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A function takes values and gives one back',
        'Fungsi menerima nilai dan memberikan satu nilai kembali',
      ),
      code: r'''
int add(int a, int b) {
  return a + b;
}
expect(add(2, 3), __);''',
      answers: ['5'],
      verify: () {
        int add(int a, int b) {
          return a + b;
        }

        return [add(2, 3)];
      },
      explanation: const Tr(
        'A function declares its return type and the types of its parameters, '
            'and a block body hands its result back with return. Forgetting '
            'return in a function that promises an int is a compile error.',
        'Fungsi mendeklarasikan tipe kembalian dan tipe parameternya, dan body '
            'berupa blok mengembalikan hasilnya dengan return. Lupa menulis '
            'return di fungsi yang menjanjikan int adalah error saat kompilasi.',
      ),
      docs: 'https://dart.dev/language/functions',
    ),
    Koan(
      prompt: const Tr(
        'An arrow is a shorter road to the same place',
        'Panah adalah jalan pintas menuju tempat yang sama',
      ),
      code: r'''
int square(int x) => x * x;
expect(square(4), __);''',
      answers: ['16'],
      verify: () {
        int square(int x) => x * x;
        return [square(4)];
      },
      explanation: const Tr(
        '=> expr is shorthand for { return expr; }. It holds exactly one '
            'expression, so statements such as if or a loop still need a block '
            'body.',
        '=> expr adalah singkatan dari { return expr; }. Ia hanya memuat satu '
            'ekspresi, jadi pernyataan seperti if atau loop tetap membutuhkan '
            'body berupa blok.',
      ),
      docs: 'https://dart.dev/language/functions',
      mistakes: const [
        Mistake(['8'], Tr(
          'x * x multiplies x by itself; it does not double it.',
          'x * x mengalikan x dengan dirinya sendiri; ia tidak '
              'menggandakannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Square brackets make a parameter optional',
        'Kurung siku membuat sebuah parameter menjadi opsional',
      ),
      code: r'''
String greet(String name, [String greeting = 'Hello']) =>
    '$greeting, $name';
expect(greet('Ratu'), __);
expect(greet('Ratu', 'Halo'), __);''',
      answers: ["'Hello, Ratu'", "'Halo, Ratu'"],
      verify: () {
        String greet(String name, [String greeting = 'Hello']) =>
            '$greeting, $name';
        return [greet('Ratu'), greet('Ratu', 'Halo')];
      },
      explanation: const Tr(
        'Parameters in [] are optional and positional, and a default fills in '
            'when the caller leaves one out. They must come last, and a caller '
            'cannot skip one to reach the next, which is why named parameters '
            'suit longer lists of options.',
        'Parameter di dalam [] bersifat opsional dan posisional, dan nilai '
            'default mengisinya jika pemanggil tidak menyertakannya. Parameter '
            'ini harus berada di akhir, dan pemanggil tidak bisa melewati satu '
            'untuk mencapai yang berikutnya, itulah sebabnya parameter bernama '
            'lebih cocok untuk daftar opsi yang panjang.',
      ),
      docs: 'https://dart.dev/language/functions#optional-positional-parameters',
      mistakes: const [
        Mistake(["'null, Ratu'", null], Tr(
          'This parameter has a default value. What fills in when it is left '
              'out?',
          'Parameter ini punya nilai default. Apa yang mengisinya ketika ia '
              'tidak disertakan?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An argument left unspoken still has a value',
        'Argumen yang tidak disebutkan tetap punya nilai',
      ),
      code: r'''
String describe(String name, [int? age]) => '$name $age';
expect(describe('Ratu'), __);''',
      answers: ["'Ratu null'"],
      hint: const Tr(
        'Without a default, an optional parameter must be nullable. What '
            'does it hold when skipped?',
        'Tanpa nilai default, parameter opsional harus nullable. Apa isinya '
            'jika dilewati?',
      ),
      verify: () {
        String describe(String name, [int? age]) => '$name $age';
        return [describe('Ratu')];
      },
      explanation: const Tr(
        'An optional parameter without a default is null when skipped, so its '
            'type must be nullable. Interpolation writes null as the text '
            '"null", which is a common surprise in user-facing strings.',
        'Parameter opsional tanpa nilai default bernilai null jika dilewati, '
            'jadi tipenya harus nullable. Interpolasi menuliskan null sebagai '
            'teks "null", kejutan yang sering muncul di teks yang dilihat '
            'pengguna.',
      ),
      docs: 'https://dart.dev/language/functions#default-parameters',
      mistakes: const [
        Mistake(["'Ratu'"], Tr(
          'The space and the missing age are still part of the string. What '
              'does interpolating null write?',
          'Spasi dan umur yang hilang tetap bagian dari string. Apa yang '
              'ditulis ketika null diinterpolasi?',
        )),
        Mistake(["'Ratu '"], Tr(
          'Interpolating null does not produce an empty string.',
          'Menginterpolasi null tidak menghasilkan string kosong.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Named parameters may come in any order, or not at all',
        'Parameter bernama boleh datang dalam urutan apa pun, atau tidak '
            'sama sekali',
      ),
      code: r'''
String box({int width = 1, int height = 1}) => '${width}x$height';
expect(box(height: 3), __);''',
      answers: ["'1x3'"],
      verify: () {
        String box({int width = 1, int height = 1}) => '${width}x$height';
        return [box(height: 3)];
      },
      explanation: const Tr(
        r'Named parameters in {} are matched by name, so callers may pass any '
            r'subset in any order, the style Flutter uses everywhere. The braces '
            r'in ${width}x matter: $widthx would look for a variable named '
            'widthx.',
        r'Parameter bernama di dalam {} dicocokkan berdasarkan nama, jadi '
            r'pemanggil boleh mengirim sebagian saja dalam urutan apa pun, gaya '
            r'yang dipakai Flutter di mana-mana. Kurung kurawal pada ${width}x '
            r'penting: $widthx akan mencari variabel bernama widthx.',
      ),
      docs: 'https://dart.dev/language/functions#named-parameters',
      mistakes: const [
        Mistake(["'3x1'"], Tr(
          'Named arguments are matched by name, not by position.',
          'Argumen bernama dicocokkan berdasarkan nama, bukan posisi.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Some names must always be spoken',
        'Beberapa nama harus selalu disebutkan',
      ),
      code: r'''
String hello({__ String name}) => 'Hello, $name';
expect(hello(name: 'Ratu'), 'Hello, Ratu');''',
      answers: ['required'],
      explanation: const Tr(
        'Named parameters are optional by default, so a non-nullable one with '
            'no default must be marked required. The compiler then rejects any '
            'call that leaves it out.',
        'Parameter bernama secara default bersifat opsional, jadi parameter '
            'yang bukan nullable dan tanpa nilai default harus ditandai '
            'required. Compiler lalu menolak setiap pemanggilan yang tidak '
            'menyertakannya.',
      ),
      docs: 'https://dart.dev/language/functions#named-parameters',
      mistakes: const [
        Mistake(['final'], Tr(
          'A final parameter is still optional when it is named, and this one '
              'has no default and cannot be null.',
          'Parameter final tetap opsional jika ia bernama, dan parameter ini '
              'tidak punya nilai default dan tidak boleh null.',
        )),
        Mistake(['late'], Tr(
          'late belongs to variables and fields, not to parameters.',
          'late milik variabel dan field, bukan parameter.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Functions are values; they can be handed to other functions',
        'Fungsi adalah nilai; ia bisa diserahkan kepada fungsi lain',
      ),
      code: r'''
int twice(int Function(int) f, int x) => f(f(x));
expect(twice((n) => n + 3, 1), __);''',
      answers: ['7'],
      hint: const Tr(
        'Apply f once, then apply it again to the result.',
        'Jalankan f sekali, lalu jalankan lagi pada hasilnya.',
      ),
      verify: () {
        int twice(int Function(int) f, int x) => f(f(x));
        return [twice((n) => n + 3, 1)];
      },
      explanation: const Tr(
        'Functions are objects with types such as int Function(int), so they '
            'can be passed, stored and returned like any value. Here f runs '
            'twice: 1 + 3, then 4 + 3.',
        'Fungsi adalah objek dengan tipe seperti int Function(int), jadi ia '
            'bisa dikirim, disimpan, dan dikembalikan seperti nilai lainnya. Di '
            'sini f berjalan dua kali: 1 + 3, lalu 4 + 3.',
      ),
      docs: 'https://dart.dev/language/functions#functions-as-first-class-objects',
      mistakes: const [
        Mistake(['4'], Tr(
          'twice calls f, then calls it again on the result.',
          'twice memanggil f, lalu memanggilnya lagi pada hasilnya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A function can be torn off and handed over without being called',
        'Fungsi bisa di-tear-off dan diserahkan tanpa dipanggil',
      ),
      code: "expect(['1', '2', '3'].map(int.parse).toList(), __);",
      answers: ['[1, 2, 3]'],
      verify: () => [
        ['1', '2', '3'].map(int.parse).toList(),
      ],
      explanation: const Tr(
        'Writing int.parse without parentheses tears off the function itself, '
            'equivalent to (s) => int.parse(s) but shorter. Tear-offs work for '
            'methods, constructors and top-level functions alike.',
        'Menulis int.parse tanpa tanda kurung melakukan tear-off pada fungsinya '
            'sendiri, setara dengan (s) => int.parse(s) tetapi lebih pendek. '
            'Tear-off berlaku untuk method, constructor, maupun fungsi '
            'top-level.',
      ),
      docs: 'https://dart.dev/language/functions#tear-offs',
      mistakes: const [
        Mistake(["['1', '2', '3']"], Tr(
          'map applies int.parse to each string. What does parse return?',
          'map menerapkan int.parse pada setiap string. Apa yang dikembalikan '
              'parse?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A closure carries its own small world',
        'Closure membawa dunia kecilnya sendiri',
      ),
      code: r'''
int Function() counter() {
  var count = 0;
  return () => ++count;
}
final next = counter();
next();
next();
expect(next(), __);
expect(counter()(), __);''',
      answers: ['3', '1'],
      hint: const Tr(
        'Every call to counter creates a fresh count.',
        'Setiap pemanggilan counter membuat count yang baru.',
      ),
      verify: () {
        int Function() counter() {
          var count = 0;
          return () => ++count;
        }

        final next = counter();
        next();
        next();
        return [next(), counter()()];
      },
      explanation: const Tr(
        'The returned closure keeps count alive after counter() has returned, '
            'so next shares one count across calls. Each new call to counter '
            'creates a fresh count, and a fresh closure around it.',
        'Closure yang dikembalikan menjaga count tetap hidup setelah counter() '
            'selesai, jadi next berbagi satu count di setiap pemanggilan. '
            'Setiap pemanggilan baru ke counter membuat count yang baru, dan '
            'closure baru di sekelilingnya.',
      ),
      docs: 'https://dart.dev/language/functions#lexical-closures',
      mistakes: const [
        Mistake(['1', null], Tr(
          'next keeps the same count between its calls.',
          'next memakai count yang sama di antara pemanggilannya.',
        )),
        Mistake([null, '4'], Tr(
          'counter() builds a brand-new closure with its own count.',
          'counter() membangun closure yang benar-benar baru dengan count '
              'miliknya sendiri.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A closure remembers the variable, not the moment',
        'Closure mengingat variabelnya, bukan momennya',
      ),
      code: r'''
var factor = 2;
int scale(int n) => n * factor;
factor = 10;
expect(scale(3), __);''',
      answers: ['30'],
      hint: const Tr(
        'Ask what factor holds at the moment scale runs.',
        'Tanyakan berapa nilai factor pada saat scale dijalankan.',
      ),
      verify: () {
        var factor = 2;
        int scale(int n) => n * factor;
        factor = 10;
        return [scale(3)];
      },
      explanation: const Tr(
        'A closure captures the variable itself, not a snapshot of its value, '
            'so scale reads factor at the moment it runs. If we want a fixed '
            'value, we copy it into a final first.',
        'Closure menangkap variabelnya sendiri, bukan potret nilainya, jadi '
            'scale membaca factor pada saat ia dijalankan. Jika kita '
            'menginginkan nilai yang tetap, salin dulu ke dalam sebuah final.',
      ),
      docs: 'https://dart.dev/language/functions#lexical-closures',
      mistakes: const [
        Mistake(['6'], Tr(
          'scale does not copy factor when it is defined.',
          'scale tidak menyalin factor saat ia didefinisikan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A function that makes functions, each with its own rule',
        'Fungsi yang membuat fungsi, masing-masing dengan aturannya sendiri',
      ),
      code: r'''
int Function(int) discount({required int percent, int minimum = 0}) {
  return (price) => (price - price * percent ~/ 100).clamp(minimum, price);
}
final sale = discount(percent: 20);
final deep = discount(percent: 90, minimum: 50);
expect(sale(200), __);
expect(deep(200), __);
expect([100, 300].map(sale).toList(), __);''',
      answers: ['160', '50', '[80, 240]'],
      capstone: true,
      verify: () {
        int Function(int) discount({required int percent, int minimum = 0}) {
          return (price) =>
              (price - price * percent ~/ 100).clamp(minimum, price);
        }

        final sale = discount(percent: 20);
        final deep = discount(percent: 90, minimum: 50);
        return [
          sale(200),
          deep(200),
          [100, 300].map(sale).toList(),
        ];
      },
      explanation: const Tr(
        'discount returns a closure that remembers percent and minimum, so '
            'sale and deep are two different rules made by one function. The '
            'named parameters make each call read clearly, and sale can be '
            'torn off and handed straight to map.',
        'discount mengembalikan closure yang mengingat percent dan minimum, '
            'jadi sale dan deep adalah dua aturan berbeda yang dibuat oleh satu '
            'fungsi. Parameter bernama membuat setiap pemanggilan mudah dibaca, '
            'dan sale bisa di-tear-off lalu langsung diserahkan ke map.',
      ),
      docs: 'https://dart.dev/language/functions#lexical-closures',
      mistakes: const [
        Mistake(['40', null, null], Tr(
          'The closure returns the price after the discount, not the discount '
              'itself.',
          'Closure itu mengembalikan harga setelah diskon, bukan besar '
              'diskonnya.',
        )),
        Mistake([null, '20', null], Tr(
          'Look at what clamp does with minimum.',
          'Perhatikan apa yang dilakukan clamp terhadap minimum.',
        )),
        Mistake([null, null, '[20, 60]'], Tr(
          'map(sale) gives the price after the discount for each element.',
          'map(sale) menghasilkan harga setelah diskon untuk setiap elemen.',
        )),
      ],
    ),
  ],
);

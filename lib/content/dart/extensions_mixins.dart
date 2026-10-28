import '../../engine/koan.dart';

final extensionsMixins = Category(
  id: 'extensions-mixins',
  title: const Tr('Extensions and Mixins', 'Extension dan Mixin'),
  intro: const Tr(
    'Behaviour can be lent, borrowed and promised, not only inherited.',
    'Perilaku bisa dipinjamkan, dipinjam, dan dijanjikan, bukan hanya '
        'diwariskan.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'We can teach an old type a new trick',
        'Kita bisa mengajari tipe lama sebuah trik baru',
      ),
      code: r'''
extension Shout on String {
  String get shout => '${toUpperCase()}!';
}
expect('hey'.shout, __);''',
      answers: ["'HEY!'"],
      verify: () => ['hey'.shout],
      explanation: const Tr(
        'An extension adds members to a type we do not own, here String. '
            'Inside it, `this` is the receiver, so `toUpperCase()` means '
            '`this.toUpperCase()`.',
        'Extension menambahkan member pada tipe yang bukan milik kita, di sini '
            'String. Di dalamnya, `this` adalah penerimanya, jadi '
            '`toUpperCase()` berarti `this.toUpperCase()`.',
      ),
      docs: 'https://dart.dev/language/extension-methods#implementing-extension-methods',
      mistakes: const [
        Mistake(["'hey!'"], Tr(
          'The getter does more than add punctuation.',
          'Getter ini melakukan lebih dari sekadar menambah tanda baca.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An extension is seen by the compiler, not by the value',
        'Extension dilihat oleh compiler, bukan oleh nilainya',
      ),
      code: r'''
extension Shout on String {
  String get shout => '${toUpperCase()}!';
}
dynamic word = 'hey';
var found = true;
try { word.shout; } catch (_) { found = false; }
expect(found, __);''',
      answers: ['false'],
      verify: () {
        dynamic word = 'hey';
        var found = true;
        try {
          word.shout;
        } catch (_) {
          found = false;
        }
        return [found];
      },
      hint: const Tr(
        'What does the compiler know about a dynamic value?',
        'Apa yang diketahui compiler tentang nilai dynamic?',
      ),
      explanation: const Tr(
        'Extensions are resolved statically, from the declared type. A '
            '`dynamic` value is looked up at runtime instead, where the '
            'extension does not exist, so the call throws a NoSuchMethodError.',
        'Extension di-resolve secara statis, berdasarkan tipe yang '
            'dideklarasikan. Nilai `dynamic` dicari saat runtime, ketika '
            'extension itu tidak ada, sehingga pemanggilannya melempar '
            'NoSuchMethodError.',
      ),
      docs: 'https://dart.dev/language/extension-methods#static-types-and-dynamic',
      mistakes: const [
        Mistake(['true'], Tr(
          'At runtime the value is a String, but extensions are not part of '
              'String itself.',
          'Saat runtime nilainya memang String, tetapi extension bukan bagian '
              'dari String itu sendiri.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An extension can be generic, and fit every list',
        'Extension bisa generik, dan cocok untuk setiap list',
      ),
      code: r'''
extension Second<T> on List<T> {
  T? get second => length > 1 ? this[1] : null;
}
expect([7, 8, 9].second, __);
expect(['solo'].second, __);''',
      answers: ['8', 'null'],
      verify: () => [
        [7, 8, 9].second,
        ['solo'].second,
      ],
      explanation: const Tr(
        'The type parameter `T` is inferred from the list, so `second` returns '
            'an `int?` for a `List<int>` and a `String?` for a '
            '`List<String>`. The nullable return type lets it say "there is '
            'none" instead of throwing.',
        'Parameter tipe `T` disimpulkan dari list-nya, jadi `second` '
            'mengembalikan `int?` untuk `List<int>` dan `String?` untuk '
            '`List<String>`. Tipe kembalian nullable membuatnya bisa berkata '
            '"tidak ada" alih-alih melempar error.',
      ),
      docs: 'https://dart.dev/language/extension-methods#implementing-generic-extensions',
      mistakes: const [
        Mistake(['7', null], Tr(
          'Positions start at zero, and this getter reads position 1.',
          'Posisi dimulai dari nol, dan getter ini membaca posisi 1.',
        )),
        Mistake([null, "'solo'"], Tr(
          'A list of one has no second element. What does the getter return '
              'then?',
          'List berisi satu elemen tidak punya elemen kedua. Apa yang '
              'dikembalikan getter dalam kasus itu?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A mixin brings its methods into any class that welcomes it',
        'Mixin membawa method-nya ke kelas mana pun yang menerimanya',
      ),
      code: r'''
mixin Greets {
  String get name;
  String greet() => 'Hi, I am $name';
}
class Robot with Greets {
  @override
  String get name => 'R2';
}
expect(Robot().greet(), __);''',
      answers: ["'Hi, I am R2'"],
      verify: () => [_Robot().greet()],
      explanation: const Tr(
        'A mixin is a bundle of members that can be mixed into many unrelated '
            'classes with `with`. It may declare abstract members, like '
            '`name`, that the class must provide.',
        'Mixin adalah kumpulan member yang bisa dicampurkan ke banyak kelas '
            'yang tidak saling berhubungan dengan `with`. Ia boleh '
            'mendeklarasikan member abstract, seperti `name`, yang wajib '
            'disediakan oleh kelasnya.',
      ),
      docs: 'https://dart.dev/language/mixins#define-abstract-members-in-the-mixin',
    ),
    Koan(
      prompt: const Tr(
        'One small word invites the mixin in',
        'Satu kata kecil mengundang mixin masuk',
      ),
      code: r'''
mixin Swims {
  String swim() => 'splash';
}
class Animal {}
class Duck extends Animal __ Swims {}
expect(Duck().swim(), 'splash');''',
      answers: ['with'],
      explanation: const Tr(
        'A class extends one superclass, and adds any number of mixins after '
            '`with`. Mixins share code across class hierarchies without the '
            'problems of multiple inheritance.',
        'Sebuah kelas meng-extend satu superclass, lalu menambahkan mixin '
            'sebanyak apa pun setelah `with`. Mixin membagikan kode lintas '
            'hierarki kelas tanpa masalah pewarisan berganda.',
      ),
      docs: 'https://dart.dev/language/mixins',
      mistakes: const [
        Mistake(['implements'], Tr(
          'implements makes a promise but brings no code; Duck would have to '
              'write swim itself.',
          'implements membuat janji tetapi tidak membawa kode; Duck harus '
              'menulis swim sendiri.',
        )),
        Mistake(['extends'], Tr(
          'A class extends only one superclass, and Duck already has one.',
          'Sebuah kelas hanya meng-extend satu superclass, dan Duck sudah '
              'punya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When mixins disagree, the last one speaks',
        'Ketika mixin-mixin tidak sepakat, yang terakhir yang bicara',
      ),
      code: r'''
mixin Calm {
  String mood() => 'calm';
}
mixin Busy {
  String mood() => 'busy';
}
class Monk with Busy, Calm {}
expect(Monk().mood(), __);''',
      answers: ["'calm'"],
      verify: () => [_Monk().mood()],
      explanation: const Tr(
        'Mixins are stacked as layers in the order they are listed, each on '
            'top of the one before. A method call finds the topmost layer '
            'first, so the mixin listed last wins.',
        'Mixin ditumpuk sebagai lapisan sesuai urutan penulisannya, '
            'masing-masing di atas yang sebelumnya. Pemanggilan method '
            'menemukan lapisan paling atas lebih dulu, sehingga mixin yang '
            'ditulis terakhir yang menang.',
      ),
      docs: 'https://dart.dev/language/mixins',
      mistakes: const [
        Mistake(["'busy'"], Tr(
          'The first one listed sits at the bottom of the stack.',
          'Yang ditulis pertama berada di dasar tumpukan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A mixin may ask what it rests upon',
        'Mixin boleh menanyakan apa yang menjadi alasnya',
      ),
      code: r'''
class Animal {
  String sound() => 'woof';
}
mixin Loud on Animal {
  @override
  String sound() => '${super.sound().toUpperCase()}!';
}
class Dog extends Animal with Loud {}
expect(Dog().sound(), __);''',
      answers: ["'WOOF!'"],
      verify: () => [_Dog().sound()],
      explanation: const Tr(
        '`on Animal` means the mixin can only be used on Animals, and in '
            'return it may call `super.sound()`, which reaches the class '
            'beneath it. This is how a mixin decorates behaviour instead of '
            'replacing it.',
        '`on Animal` berarti mixin ini hanya bisa dipakai pada Animal, dan '
            'sebagai gantinya ia boleh memanggil `super.sound()`, yang '
            'menjangkau kelas di bawahnya. Begitulah mixin menghias perilaku '
            'alih-alih menggantikannya.',
      ),
      docs: 'https://dart.dev/language/mixins#use-the-on-clause-to-declare-a-superclass',
      mistakes: const [
        Mistake(["'woof'"], Tr(
          'Dog takes sound from the mixin, which sits above Animal.',
          'Dog mengambil sound dari mixin, yang berada di atas Animal.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'To extend is to inherit; to implement is only to promise',
        'Meng-extend berarti mewarisi; meng-implement hanya berarti berjanji',
      ),
      code: r'''
class Bird {
  String fly() => 'flap';
}
class Sparrow extends Bird {}
class Plane implements Bird {
  @override
  String fly() => 'zoom';
}
expect(Sparrow().fly(), __);
expect(Plane() is Bird, __);''',
      answers: ["'flap'", 'true'],
      // ignore: unnecessary_type_check
      verify: () => [_Sparrow().fly(), _Plane() is _Bird],
      explanation: const Tr(
        'Every class is also an implicit interface. `extends` inherits the '
            'code; `implements` inherits only the type, so Plane must write '
            'every member itself, yet it is still accepted wherever a Bird is '
            'expected.',
        'Setiap kelas juga merupakan interface implisit. `extends` mewarisi '
            'kodenya; `implements` hanya mewarisi tipenya, jadi Plane harus '
            'menulis setiap member sendiri, tetapi tetap diterima di mana pun '
            'Bird dibutuhkan.',
      ),
      docs: 'https://dart.dev/language/classes#implicit-interfaces',
      mistakes: const [
        Mistake([null, 'false'], Tr(
          'Plane inherits no code from Bird, but it does take on its type.',
          'Plane tidak mewarisi kode dari Bird, tetapi ia mengambil tipenya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An abstract class is a shape waiting to be filled',
        'Kelas abstract adalah bentuk yang menunggu untuk diisi',
      ),
      code: r'''
abstract class Shape {
  double get area;
  String describe() => 'area $area';
}
class Square extends Shape {
  Square(this.side);
  final double side;
  @override
  double get area => side * side;
}
expect(Square(3).describe(), __);''',
      answers: ["'area 9.0'"],
      verify: () => [_Square(3).describe()],
      explanation: const Tr(
        'An abstract class cannot be built, and may leave members without a '
            'body. Its concrete methods can already rely on them, like '
            '`describe` using `area`, and each subclass fills in the rest.',
        'Kelas abstract tidak bisa dibuat, dan boleh membiarkan member tanpa '
            'body. Method konkretnya sudah bisa bergantung pada member '
            'tersebut, seperti `describe` yang memakai `area`, dan setiap '
            'subclass melengkapi sisanya.',
      ),
      docs: 'https://dart.dev/language/class-modifiers#abstract',
      mistakes: const [
        Mistake(["'area 9'"], Tr(
          'side is a double, even when written as 3. How does a double print?',
          'side adalah double, meskipun ditulis sebagai 3. Bagaimana double '
              'dicetak?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a cat that inherits, borrows and is extended',
        'Kumpulkan semuanya: kucing yang mewarisi, meminjam, dan diperluas',
      ),
      code: r'''
abstract class Animal {
  String get name;
  String speak();
}
mixin Polite on Animal {
  String greet() => '${speak()}, I am $name';
}
class Cat extends Animal with Polite {
  @override String get name => 'Tom';
  @override String speak() => 'Meow';
}
extension on String { String get loud => toUpperCase(); }
expect(Cat().greet(), __);
expect(Cat().greet().loud, __);
expect(Cat() is Polite, __);''',
      answers: ["'Meow, I am Tom'", "'MEOW, I AM TOM'", 'true'],
      verify: () => [
        _Cat().greet(),
        _Cat().greet().loud,
        // ignore: unnecessary_type_check
        _Cat() is _Polite,
      ],
      capstone: true,
      explanation: const Tr(
        'The abstract class sets the contract, the mixin builds on it through '
            '`on`, the class fills in the blanks, and an extension adds a '
            'finishing touch to String. Mixing in a mixin also makes the '
            'class a subtype of it.',
        'Kelas abstract menetapkan kontraknya, mixin membangun di atasnya '
            'lewat `on`, kelasnya mengisi bagian yang kosong, dan extension '
            'menambahkan sentuhan akhir pada String. Mencampurkan sebuah '
            'mixin juga menjadikan kelas itu subtype dari mixin tersebut.',
      ),
      docs: 'https://dart.dev/language/mixins',
      mistakes: const [
        Mistake([null, null, 'false'], Tr(
          'with does more than copy methods: it also adds a type.',
          'with melakukan lebih dari menyalin method: ia juga menambahkan '
              'tipe.',
        )),
      ],
    ),
  ],
);

extension _Shout on String {
  String get shout => '${toUpperCase()}!';
}

extension _Second<T> on List<T> {
  T? get second => length > 1 ? this[1] : null;
}

mixin _Greets {
  String get name;
  String greet() => 'Hi, I am $name';
}

class _Robot with _Greets {
  @override
  String get name => 'R2';
}

mixin _Calm {
  String mood() => 'calm';
}

mixin _Busy {
  String mood() => 'busy';
}

class _Monk with _Busy, _Calm {}

class _Animal {
  String sound() => 'woof';
}

mixin _Loud on _Animal {
  @override
  String sound() => '${super.sound().toUpperCase()}!';
}

class _Dog extends _Animal with _Loud {}

class _Bird {
  String fly() => 'flap';
}

class _Sparrow extends _Bird {}

class _Plane implements _Bird {
  @override
  String fly() => 'zoom';
}

abstract class _Shape {
  double get area;
  String describe() => 'area $area';
}

class _Square extends _Shape {
  _Square(this.side);
  final double side;
  @override
  double get area => side * side;
}

abstract class _Pet {
  String get name;
  String speak();
}

mixin _Polite on _Pet {
  String greet() => '${speak()}, I am $name';
}

class _Cat extends _Pet with _Polite {
  @override
  String get name => 'Tom';
  @override
  String speak() => 'Meow';
}

extension _Loudly on String {
  String get loud => toUpperCase();
}

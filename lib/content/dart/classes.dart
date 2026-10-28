import '../../engine/koan.dart';

final classes = Category(
  id: 'classes',
  title: const Tr('Classes', 'Kelas'),
  intro: const Tr(
    'A class is a mold; every object remembers the shape it was poured from.',
    'Kelas adalah cetakan; setiap objek mengingat bentuk tempat ia dituang.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A constructor can fill the fields straight from its parameters',
        'Constructor bisa mengisi field langsung dari parameternya',
      ),
      code: r'''
class Point {
  Point({this.x = 0, this.y = 0});
  final int x;
  final int y;
}
final p = Point(y: 5);
expect(p.x, __);
expect(p.y, __);''',
      answers: ['0', '5'],
      verify: () {
        final p = _Point(y: 5);
        return [p.x, p.y];
      },
      explanation: const Tr(
        '`this.x` is an initializing formal: the argument goes straight into '
            'the field, so final fields need no extra assignment. Inside braces '
            'it becomes a named parameter, and its default fills the gap when '
            'the caller says nothing.',
        '`this.x` adalah initializing formal: argumen langsung masuk ke field, '
            'sehingga field final tidak perlu diisi lagi. Di dalam kurung '
            'kurawal ia menjadi parameter bernama, dan nilai default-nya '
            'mengisi kekosongan saat pemanggil tidak menyebutkannya.',
      ),
      docs: 'https://dart.dev/language/constructors#use-initializing-formal-parameters',
      mistakes: const [
        Mistake(['5', null], Tr(
          'Arguments are matched by name, not by position. Which name did the '
              'call actually use?',
          'Argumen dicocokkan berdasarkan nama, bukan posisi. Nama mana yang '
              'benar-benar dipakai saat pemanggilan?',
        )),
        Mistake(['null', null], Tr(
          'x is a non-nullable int. What does the constructor give it when the '
              'caller is silent?',
          'x adalah int yang non-nullable. Apa yang diberikan constructor saat '
              'pemanggil diam saja?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A named constructor is another door into the same class',
        'Constructor bernama adalah pintu lain menuju kelas yang sama',
      ),
      code: r'''
class Temperature {
  Temperature(this.celsius);
  Temperature.fromFahrenheit(double f) : celsius = (f - 32) * 5 / 9;
  final double celsius;
}
expect(Temperature.fromFahrenheit(212).celsius, __);''',
      answers: ['100.0'],
      verify: () => [_Temperature.fromFahrenheit(212).celsius],
      hint: const Tr(
        'Water boils at 212 degrees Fahrenheit. And what kind of number does / '
            'give?',
        'Air mendidih pada 212 derajat Fahrenheit. Lalu, angka jenis apa yang '
            'dihasilkan oleh / ?',
      ),
      explanation: const Tr(
        'Dart has no constructor overloading, so extra ways to build an object '
            'get names. The initializer list after `:` sets final fields '
            'before the body runs, and `/` always gives a double.',
        'Dart tidak punya overloading constructor, jadi cara lain untuk '
            'membuat objek diberi nama. Initializer list setelah `:` mengisi '
            'field final sebelum body dijalankan, dan `/` selalu menghasilkan '
            'double.',
      ),
      docs: 'https://dart.dev/language/constructors#use-an-initializer-list',
      mistakes: const [
        Mistake(['212.0'], Tr(
          'The field is not the argument itself: the initializer list computes '
              'it first.',
          'Field-nya bukan argumen itu sendiri: initializer list menghitungnya '
              'terlebih dahulu.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A getter is asked anew each time it is read',
        'Getter ditanya ulang setiap kali ia dibaca',
      ),
      code: r'''
class Rect {
  Rect(this.width, this.height);
  int width;
  int height;
  int get area => width * height;
}
final r = Rect(3, 4);
r.width = 5;
expect(r.area, __);''',
      answers: ['20'],
      verify: () {
        final r = _Rect(3, 4);
        r.width = 5;
        return [r.area];
      },
      explanation: const Tr(
        'A getter is a method that looks like a field. Nothing is stored: '
            '`area` is computed from the current width and height whenever '
            'someone reads it, so it can never go stale.',
        'Getter adalah method yang tampak seperti field. Tidak ada yang '
            'disimpan: `area` dihitung dari width dan height saat ini setiap '
            'kali dibaca, sehingga nilainya tidak pernah basi.',
      ),
      docs: 'https://dart.dev/language/methods#getters-and-setters',
      mistakes: const [
        Mistake(['12'], Tr(
          'That was the area when the rectangle was born. A getter does not '
              'remember; it computes.',
          'Itu luasnya saat persegi panjang baru dibuat. Getter tidak '
              'mengingat; ia menghitung.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A setter stands guard at the door of a field',
        'Setter berjaga di pintu sebuah field',
      ),
      code: r'''
class Volume {
  int _level = 0;
  int get level => _level;
  set level(int value) => _level = value.clamp(0, 10);
}
final v = Volume()..level = 42;
expect(v.level, __);''',
      answers: ['10'],
      verify: () {
        final v = _Volume()..level = 42;
        return [v.level];
      },
      explanation: const Tr(
        'Assigning to `level` calls the setter, which may check or adjust the '
            'value before storing it. Callers write `v.level = 42` either way, '
            'so a plain field can later become a getter and setter without '
            'changing any code that uses it.',
        'Menetapkan nilai ke `level` memanggil setter, yang boleh memeriksa '
            'atau menyesuaikan nilainya sebelum disimpan. Pemanggil tetap '
            'menulis `v.level = 42`, jadi field biasa bisa kelak diganti '
            'getter dan setter tanpa mengubah kode yang memakainya.',
      ),
      docs: 'https://dart.dev/language/methods#getters-and-setters',
      mistakes: const [
        Mistake(['42'], Tr(
          'The assignment did not write the field directly; it passed through '
              'the setter first.',
          'Penetapan nilai itu tidak langsung menulis field; ia melewati setter '
              'terlebih dahulu.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'What is static belongs to the class, not to any one object',
        'Yang static dimiliki kelas, bukan oleh satu objek tertentu',
      ),
      code: r'''
class Ticket {
  static int issued = 0;
  Ticket() {
    issued++;
  }
}
Ticket();
Ticket();
Ticket();
expect(Ticket.issued, __);''',
      answers: ['3'],
      verify: () {
        _Ticket.issued = 0;
        _Ticket();
        _Ticket();
        _Ticket();
        return [_Ticket.issued];
      },
      explanation: const Tr(
        'A static field exists once, shared by every instance, and is reached '
            'through the class name: `Ticket.issued`. It is created lazily, '
            'the first time it is used.',
        'Field static hanya ada satu, dipakai bersama oleh semua instance, dan '
            'diakses lewat nama kelasnya: `Ticket.issued`. Ia dibuat secara '
            'lazy, saat pertama kali dipakai.',
      ),
      docs: 'https://dart.dev/language/classes#static-variables',
      mistakes: const [
        Mistake(['1'], Tr(
          'Each ticket does not get its own counter. How many counters are '
              'there?',
          'Setiap tiket tidak punya penghitungnya sendiri. Ada berapa '
              'penghitung?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An object may choose how it introduces itself',
        'Sebuah objek boleh memilih cara memperkenalkan dirinya',
      ),
      code: r'''
class Point {
  Point(this.x, this.y);
  final int x;
  final int y;
  @override
  String toString() => 'Point($x, $y)';
}
expect('at ${Point(1, 2)}', __);''',
      answers: ["'at Point(1, 2)'"],
      verify: () => ['at ${_Point(x: 1, y: 2)}'],
      explanation: const Tr(
        'String interpolation calls `toString()` on the value. Every class '
            'inherits one from Object, which only says "Instance of ...", so '
            'overriding it makes logs and test failures readable.',
        'Interpolasi string memanggil `toString()` pada nilainya. Setiap kelas '
            'mewarisinya dari Object, yang hanya berkata "Instance of ...", '
            'jadi meng-override-nya membuat log dan pesan test yang gagal '
            'lebih mudah dibaca.',
      ),
      docs: 'https://api.dart.dev/dart-core/Object/toString.html',
      mistakes: const [
        Mistake(["\"at Instance of 'Point'\""], Tr(
          "That is Object's toString. Does this class keep it?",
          'Itu toString milik Object. Apakah kelas ini mempertahankannya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Two objects become equal when we teach them what equal means',
        'Dua objek menjadi setara ketika kita mengajari mereka arti setara',
      ),
      code: r'''
class Point {
  Point(this.x, this.y);
  final int x;
  final int y;
  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}
expect(Point(1, 2) == Point(1, 2), __);
expect({Point(1, 2), Point(1, 2)}.length, __);''',
      answers: ['true', '1'],
      verify: () => [
        _Pt(1, 2) == _Pt(1, 2),
        {_Pt(1, 2), _Pt(1, 2)}.length,
      ],
      explanation: const Tr(
        'By default `==` asks "are these the same object?". Overriding it '
            'compares fields instead, and `hashCode` must agree with it: sets '
            'and map keys look at the hash first, so equal objects need equal '
            'hashes. `Object.hash` combines fields for us.',
        'Secara default `==` bertanya "apakah ini objek yang sama?". '
            'Meng-override-nya membuat perbandingan berdasarkan field, dan '
            '`hashCode` harus sejalan: set dan key map melihat hash lebih '
            'dulu, jadi objek yang setara harus punya hash yang sama. '
            '`Object.hash` menggabungkan field-field itu untuk kita.',
      ),
      docs: 'https://api.dart.dev/dart-core/Object/operator_equals.html',
      mistakes: const [
        Mistake(['false', null], Tr(
          'They are two objects, yet this class has its own idea of ==.',
          'Keduanya memang dua objek, tetapi kelas ini punya pengertiannya '
              'sendiri tentang ==.',
        )),
        Mistake([null, '2'], Tr(
          'A set keeps only one of each value, and it decides "the same" with '
              '== and hashCode.',
          'Set hanya menyimpan satu dari setiap nilai, dan ia menentukan '
              '"sama" lewat == dan hashCode.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A factory need not make something new',
        'Factory tidak harus membuat sesuatu yang baru',
      ),
      code: r'''
class Logger {
  Logger._(this.name);
  final String name;
  static final _cache = <String, Logger>{};
  factory Logger(String name) =>
      _cache.putIfAbsent(name, () => Logger._(name));
}
expect(identical(Logger('ui'), Logger('ui')), __);
expect(identical(Logger('ui'), Logger('db')), __);''',
      answers: ['true', 'false'],
      verify: () => [
        identical(_Logger('ui'), _Logger('ui')),
        identical(_Logger('ui'), _Logger('db')),
      ],
      explanation: const Tr(
        'A generative constructor always creates a fresh object; a factory '
            'constructor is free to return one it already has, or a subtype. '
            'Callers cannot tell the difference, which makes caching '
            'invisible to them.',
        'Constructor generatif selalu membuat objek baru; constructor factory '
            'bebas mengembalikan objek yang sudah ada, atau sebuah subtype. '
            'Pemanggil tidak bisa membedakannya, sehingga cache tidak '
            'terlihat oleh mereka.',
      ),
      docs: 'https://dart.dev/language/constructors#factory-constructors',
      mistakes: const [
        Mistake(['false', null], Tr(
          'Calling a constructor usually means a new object. Look at what this '
              'one returns the second time.',
          'Memanggil constructor biasanya berarti objek baru. Lihat apa yang '
              'dikembalikan constructor ini pada panggilan kedua.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'One door, many rooms behind it',
        'Satu pintu, banyak ruangan di baliknya',
      ),
      code: r'''
abstract class Shape {
  __ Shape(String kind) => kind == 'circle' ? Circle() : Square();
}
class Circle implements Shape {}
class Square implements Shape {}
expect(Shape('circle') is Circle, true);''',
      answers: ['factory'],
      hint: const Tr(
        'An abstract class cannot be built directly, yet this constructor '
            'returns something else.',
        'Kelas abstract tidak bisa dibuat langsung, tetapi constructor ini '
            'mengembalikan sesuatu yang lain.',
      ),
      explanation: const Tr(
        'Only a factory constructor can return a value, so only it can hand '
            'back a subtype. This is how `Shape(...)` can sit in front of an '
            'abstract class and still give the caller a real object.',
        'Hanya constructor factory yang boleh mengembalikan nilai, jadi hanya '
            'ia yang bisa memberikan sebuah subtype. Begitulah `Shape(...)` '
            'bisa berdiri di depan kelas abstract dan tetap memberi pemanggil '
            'objek yang nyata.',
      ),
      docs: 'https://dart.dev/language/constructors#factory-constructors',
      mistakes: const [
        Mistake(['static'], Tr(
          'A static method would need its own name, and it would not be a '
              'constructor.',
          'Method static butuh namanya sendiri, dan ia bukan constructor.',
        )),
        Mistake(['const'], Tr(
          'A const constructor builds this very class, and an abstract class '
              'cannot be built.',
          'Constructor const membuat kelas ini sendiri, padahal kelas abstract '
              'tidak bisa dibuat.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a small value that knows how to count its money',
        'Kumpulkan semuanya: sebuah nilai kecil yang tahu cara menghitung '
            'uangnya',
      ),
      code: r'''
class Money {
  Money(this.cents);
  Money.dollars(int d) : cents = d * 100;
  final int cents;
  int get dollars => cents ~/ 100;
  Money operator +(Money other) => Money(cents + other.cents);
  @override
  String toString() => '$dollars.${cents % 100} USD';
}
final total = Money.dollars(2) + Money(150);
expect(total.cents, __);
expect(total.dollars, __);
expect('$total', __);''',
      answers: ['350', '3', "'3.50 USD'"],
      verify: () {
        final total = _Money.dollars(2) + _Money(150);
        return [total.cents, total.dollars, '$total'];
      },
      capstone: true,
      explanation: const Tr(
        'A named constructor with an initializer list, a computed getter, an '
            'operator and toString work together so Money reads like a built-in '
            'type. Storing whole cents in an int avoids the rounding surprises '
            'of doubles.',
        'Constructor bernama dengan initializer list, getter yang dihitung, '
            'operator, dan toString bekerja sama sehingga Money terasa seperti '
            'tipe bawaan. Menyimpan sen utuh dalam int menghindari kejutan '
            'pembulatan pada double.',
      ),
      docs: 'https://dart.dev/language/methods#operators',
      mistakes: const [
        Mistake(['152', null, null], Tr(
          'Money.dollars counts whole dollars. How many cents is that?',
          'Money.dollars menghitung dolar utuh. Berapa sen jumlahnya?',
        )),
        Mistake([null, '3.5', null], Tr(
          '~/ divides and keeps only the whole part.',
          '~/ membagi dan hanya menyimpan bagian bulatnya.',
        )),
      ],
    ),
  ],
);

class _Point {
  _Point({this.x = 0, this.y = 0});
  final int x;
  final int y;
  @override
  String toString() => 'Point($x, $y)';
}

class _Temperature {
  _Temperature.fromFahrenheit(double f) : celsius = (f - 32) * 5 / 9;
  final double celsius;
}

class _Rect {
  _Rect(this.width, this.height);
  int width;
  int height;
  int get area => width * height;
}

class _Volume {
  int _level = 0;
  int get level => _level;
  set level(int value) => _level = value.clamp(0, 10);
}

class _Ticket {
  static int issued = 0;
  _Ticket() {
    issued++;
  }
}

class _Pt {
  _Pt(this.x, this.y);
  final int x;
  final int y;
  @override
  bool operator ==(Object other) =>
      other is _Pt && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}

class _Logger {
  _Logger._(this.name);
  final String name;
  static final _cache = <String, _Logger>{};
  factory _Logger(String name) =>
      _cache.putIfAbsent(name, () => _Logger._(name));
}

class _Money {
  _Money(this.cents);
  _Money.dollars(int d) : cents = d * 100;
  final int cents;
  int get dollars => cents ~/ 100;
  _Money operator +(_Money other) => _Money(cents + other.cents);
  @override
  String toString() => '$dollars.${cents % 100} USD';
}

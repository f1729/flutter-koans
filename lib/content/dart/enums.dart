import '../../engine/koan.dart';

final enums = Category(
  id: 'enums',
  title: const Tr('Enums', 'Enum'),
  intro: const Tr(
    'An enum is a closed circle: every member is known, and none can be added.',
    'Enum adalah lingkaran tertutup: setiap anggotanya sudah dikenal, dan '
        'tidak ada yang bisa ditambahkan.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Every value of an enum knows its place in line',
        'Setiap nilai enum tahu tempatnya dalam barisan',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
expect(Season.autumn.index, __);''',
      answers: ['2'],
      verify: () => [_Season.autumn.index],
      explanation: const Tr(
        '`index` is the position in the declaration, counting from zero like a '
            'list. Because it shifts when values are reordered, avoid storing '
            'it; store the name instead.',
        '`index` adalah posisi dalam deklarasi, dihitung dari nol seperti '
            'list. Karena ia bergeser saat urutan nilai diubah, sebaiknya '
            'jangan disimpan; simpan namanya saja.',
      ),
      docs: 'https://api.dart.dev/dart-core/Enum/index.html',
      mistakes: const [
        Mistake(['3'], Tr(
          'Positions in Dart start where list positions start.',
          'Posisi di Dart dimulai dari tempat yang sama dengan posisi list.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'And it knows its own name',
        'Dan ia tahu namanya sendiri',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
expect(Season.winter.name, __);''',
      answers: ["'winter'"],
      verify: () => [_Season.winter.name],
      explanation: const Tr(
        '`name` is the identifier as written, without the enum prefix, while '
            '`toString()` gives `Season.winter`. The name is a stable thing to '
            'save in JSON or preferences.',
        '`name` adalah identifier seperti yang ditulis, tanpa awalan nama '
            'enum, sedangkan `toString()` menghasilkan `Season.winter`. Nama '
            'inilah yang aman disimpan di JSON atau preferensi.',
      ),
      docs: 'https://api.dart.dev/dart-core/EnumName/name.html',
      mistakes: const [
        Mistake(["'Season.winter'"], Tr(
          "That is what toString says. name leaves out the enum's own name.",
          'Itu yang dikatakan toString. name tidak menyertakan nama enum-nya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'The whole circle can be walked, in order',
        'Seluruh lingkaran bisa dijelajahi, secara berurutan',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
expect(Season.values.length, __);
expect(Season.values.last, __);''',
      answers: ['4', 'Season.winter'],
      registry: _seasons,
      verify: () => [_Season.values.length, _Season.values.last],
      explanation: const Tr(
        'Every enum gets a static `values` list holding its members in '
            'declaration order. It is a constant list, handy for building '
            'menus or looping over every case.',
        'Setiap enum mendapat list static `values` yang berisi anggotanya '
            'sesuai urutan deklarasi. List ini konstan, berguna untuk membuat '
            'menu atau menelusuri setiap kemungkinan.',
      ),
      docs: 'https://dart.dev/language/enums#using-enums',
      mistakes: const [
        Mistake(['3', null], Tr(
          'length counts the values; it is not the last index.',
          'length menghitung jumlah nilai; ia bukan indeks terakhir.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A name, once spoken, can be turned back into a value',
        'Sebuah nama, setelah diucapkan, bisa diubah kembali menjadi nilai',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
final s = Season.values.byName('summer');
expect(s, __);
expect(s.index, __);''',
      answers: ['Season.summer', '1'],
      registry: _seasons,
      verify: () {
        final s = _Season.values.byName('summer');
        return [s, s.index];
      },
      explanation: const Tr(
        '`byName` is the reverse of `name`: it finds the value with that exact '
            'name, and throws an ArgumentError if there is none. It is how a '
            'saved name comes back as an enum.',
        '`byName` adalah kebalikan dari `name`: ia mencari nilai dengan nama '
            'yang persis sama, dan melempar ArgumentError jika tidak ada. '
            'Begitulah nama yang tersimpan kembali menjadi enum.',
      ),
      docs: 'https://api.dart.dev/dart-core/EnumByName/byName.html',
      mistakes: const [
        Mistake(["'summer'", null], Tr(
          'byName gives back an enum value, not a string.',
          'byName mengembalikan nilai enum, bukan string.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An enum may carry values of its own',
        'Enum boleh membawa nilai-nilainya sendiri',
      ),
      code: r'''
enum Coin {
  penny(1), nickel(5), dime(10), quarter(25);

  const Coin(this.cents);
  final int cents;
}
expect(Coin.dime.cents * 3, __);''',
      answers: ['30'],
      verify: () => [_Coin.dime.cents * 3],
      explanation: const Tr(
        'An enhanced enum declares fields and a const constructor, and each '
            'value passes its arguments in parentheses. The data lives with '
            'the value, so there is no separate map to keep in sync.',
        'Enhanced enum mendeklarasikan field dan constructor const, dan setiap '
            'nilai memberikan argumennya di dalam kurung. Datanya melekat pada '
            'nilai itu, jadi tidak perlu map terpisah yang harus selalu '
            'diselaraskan.',
      ),
      docs: 'https://dart.dev/language/enums#declaring-enhanced-enums',
      mistakes: const [
        Mistake(['6'], Tr(
          'The arithmetic uses cents, not the position of the coin.',
          'Perhitungannya memakai cents, bukan posisi koin tersebut.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An enum can teach its values to move',
        'Enum bisa mengajari nilai-nilainya untuk bergerak',
      ),
      code: r'''
enum Season {
  spring, summer, autumn, winter;

  Season get next => values[(index + 1) % values.length];
}
expect(Season.spring.next, __);
expect(Season.winter.next, __);''',
      answers: ['Season.summer', 'Season.spring'],
      registry: _seasons,
      verify: () => [_Season.spring.next, _Season.winter.next],
      explanation: const Tr(
        'Enhanced enums may have getters and methods, and inside them `this`, '
            '`index` and `values` are all in reach. The `%` makes the seasons '
            'wrap around instead of running off the end of the list.',
        'Enhanced enum boleh punya getter dan method, dan di dalamnya `this`, '
            '`index`, serta `values` bisa langsung dipakai. Operator `%` '
            'membuat musim berputar kembali, alih-alih melewati ujung list.',
      ),
      docs: 'https://dart.dev/language/enums#declaring-enhanced-enums',
      mistakes: const [
        Mistake([null, 'Season.autumn'], Tr(
          'next moves forward, not back. What comes after the last one?',
          'next bergerak maju, bukan mundur. Apa yang datang setelah yang '
              'terakhir?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'When every case is named, no default is needed',
        'Ketika setiap kemungkinan disebutkan, default tidak diperlukan',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
String feel(Season s) => switch (s) {
  Season.spring => 'fresh',
  Season.summer => 'warm',
  Season.autumn || Season.winter => 'cold',
};
expect(feel(Season.winter), __);''',
      answers: ["'cold'"],
      verify: () => [_feel(_Season.winter)],
      explanation: const Tr(
        'A switch over an enum is exhaustive once every value is covered, so '
            'no `_` case is needed. Better still, if someone adds a fifth '
            'season, the compiler points at every switch that forgot it.',
        'Switch atas sebuah enum sudah exhaustive begitu setiap nilainya '
            'tercakup, jadi kasus `_` tidak diperlukan. Lebih baik lagi, jika '
            'seseorang menambahkan musim kelima, compiler akan menunjuk setiap '
            'switch yang melupakannya.',
      ),
      docs: 'https://dart.dev/language/branches#exhaustiveness-checking',
    ),
    Koan(
      prompt: const Tr(
        'Values that know their place can be put back in order',
        'Nilai yang tahu tempatnya bisa dikembalikan ke urutannya',
      ),
      code: r'''
enum Season { spring, summer, autumn, winter }
final seen = [Season.winter, Season.spring, Season.autumn];
seen.sort(Enum.compareByIndex);
expect(seen.first, __);
expect(seen.last, __);''',
      answers: ['Season.spring', 'Season.winter'],
      registry: _seasons,
      verify: () {
        final seen = [_Season.winter, _Season.spring, _Season.autumn];
        seen.sort(Enum.compareByIndex);
        return [seen.first, seen.last];
      },
      explanation: const Tr(
        'Enum values are not Comparable on their own, but '
            '`Enum.compareByIndex` sorts them by declaration order. '
            '`Enum.compareByName` sorts them alphabetically instead.',
        'Nilai enum tidak Comparable dengan sendirinya, tetapi '
            '`Enum.compareByIndex` mengurutkannya sesuai urutan deklarasi. '
            '`Enum.compareByName` mengurutkannya secara alfabetis.',
      ),
      docs: 'https://api.dart.dev/dart-core/Enum/compareByIndex.html',
      mistakes: const [
        Mistake(['Season.autumn', null], Tr(
          'The sort is by position in the declaration, not by name.',
          'Pengurutannya berdasarkan posisi dalam deklarasi, bukan nama.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a menu that cannot hold a size that does not exist',
        'Kumpulkan semuanya: menu yang tidak mungkin memuat ukuran yang tidak '
            'ada',
      ),
      code: r'''
enum Size {
  small(250), medium(350), large(500);

  const Size(this.ml);
  final int ml;
  int get price => switch (this) {
    Size.small => 3,
    Size.medium => 4,
    Size.large => 5,
  };
}
final cup = Size.values.byName('medium');
expect(cup.ml, __);
expect(cup.price, __);
expect(Size.values.firstWhere((s) => s.ml > 400), __);''',
      answers: ['350', '4', 'Size.large'],
      registry: const Registry(symbols: {
        'Size.small': _Size.small,
        'Size.medium': _Size.medium,
        'Size.large': _Size.large,
      }),
      verify: () {
        final cup = _Size.values.byName('medium');
        return [
          cup.ml,
          cup.price,
          _Size.values.firstWhere((s) => s.ml > 400),
        ];
      },
      capstone: true,
      explanation: const Tr(
        'Fields, a getter with an exhaustive switch on `this`, `byName` and '
            '`values` turn the enum into a small, closed table. A typo in a '
            'size name fails loudly in byName instead of slipping through as '
            'a string.',
        'Field, getter dengan switch exhaustive atas `this`, `byName`, dan '
            '`values` menjadikan enum ini sebuah tabel kecil yang tertutup. '
            'Salah ketik pada nama ukuran langsung gagal di byName, alih-alih '
            'lolos sebagai string.',
      ),
      docs: 'https://dart.dev/language/enums#declaring-enhanced-enums',
      mistakes: const [
        Mistake([null, '1', null], Tr(
          'price is not the index; it comes from the switch.',
          'price bukan indeks; nilainya berasal dari switch.',
        )),
        Mistake([null, null, 'Size.medium'], Tr(
          'firstWhere wants more than 400 ml.',
          'firstWhere mencari yang lebih dari 400 ml.',
        )),
      ],
    ),
  ],
);

enum _Season {
  spring,
  summer,
  autumn,
  winter;

  _Season get next => values[(index + 1) % values.length];
}

const _seasons = Registry(symbols: {
  'Season.spring': _Season.spring,
  'Season.summer': _Season.summer,
  'Season.autumn': _Season.autumn,
  'Season.winter': _Season.winter,
});

String _feel(_Season s) => switch (s) {
      _Season.spring => 'fresh',
      _Season.summer => 'warm',
      _Season.autumn || _Season.winter => 'cold',
    };

// The other coins are there to mirror the koan, though only dime is read.
enum _Coin {
  // ignore: unused_field
  penny(1),
  // ignore: unused_field
  nickel(5),
  dime(10),
  // ignore: unused_field
  quarter(25);

  const _Coin(this.cents);
  final int cents;
}

enum _Size {
  small(250),
  medium(350),
  large(500);

  const _Size(this.ml);
  final int ml;
  int get price => switch (this) {
        _Size.small => 3,
        _Size.medium => 4,
        _Size.large => 5,
      };
}

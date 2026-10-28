import '../../engine/koan.dart';

final exceptions = Category(
  id: 'exceptions',
  title: const Tr('Exceptions', 'Exception'),
  intro: const Tr(
    'Things go wrong. The wise program expects it, and knows where to land.',
    'Segala sesuatu bisa salah. Program yang bijak sudah menduganya, dan tahu '
        'di mana harus mendarat.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'What is thrown can be caught',
        'Apa yang dilempar bisa ditangkap',
      ),
      code: r'''
String describe(String s) {
  try {
    return 'number ${int.parse(s)}';
  } on FormatException {
    return 'not a number';
  }
}
expect(describe('42'), __);
expect(describe('4x2'), __);''',
      answers: ["'number 42'", "'not a number'"],
      verify: () => [_describe('42'), _describe('4x2')],
      explanation: const Tr(
        'When `int.parse` cannot read the text it throws a FormatException, '
            'which skips the rest of the `try` block and lands in the matching '
            '`on` clause. When nothing is thrown, the handler never runs.',
        'Saat `int.parse` tidak bisa membaca teksnya, ia melempar '
            'FormatException, yang melewati sisa blok `try` dan mendarat di '
            'klausa `on` yang cocok. Jika tidak ada yang dilempar, handler-nya '
            'tidak pernah dijalankan.',
      ),
      docs: 'https://dart.dev/language/error-handling#catch',
      mistakes: const [
        Mistake([null, "'number 4'"], Tr(
          'int.parse does not read as far as it can; the whole text must be a '
              'number.',
          'int.parse tidak membaca sejauh yang ia bisa; seluruh teksnya harus '
              'berupa angka.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Name the kind of trouble you are ready for',
        'Sebutkan jenis masalah yang siap kita hadapi',
      ),
      code: r'''
var caught = false;
try {
  int.parse('seven');
} on __ {
  caught = true;
}
expect(caught, true);''',
      answers: ['FormatException'],
      registry: _errors,
      // Its supertypes catch it too.
      accept: (values) =>
          const {FormatException, Exception, Object}.contains(values.single),
      explanation: const Tr(
        '`on T` catches only errors that are a `T`. FormatException is the '
            'most precise answer, but its supertypes Exception and Object '
            'would catch it too, along with much more than we meant to.',
        '`on T` hanya menangkap error yang merupakan `T`. FormatException '
            'adalah jawaban paling tepat, tetapi supertype-nya, Exception dan '
            'Object, juga bisa menangkapnya, sekaligus jauh lebih banyak dari '
            'yang kita maksud.',
      ),
      docs: 'https://api.dart.dev/dart-core/FormatException-class.html',
      mistakes: const [
        Mistake(['ArgumentError'], Tr(
          'The argument is a fine String. What is wrong is how it is written.',
          'Argumennya String yang sah. Yang salah adalah cara penulisannya.',
        )),
        Mistake(['TypeError'], Tr(
          'parse got the type it wanted: a String. The trouble is in the text.',
          'parse mendapatkan tipe yang ia mau: String. Masalahnya ada pada '
              'teksnya.',
        )),
        Mistake(['Error'], Tr(
          'Bad input is not a bug in the program, so it is not an Error.',
          'Input yang buruk bukan bug di dalam program, jadi ia bukan Error.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Anything can be thrown, even a plain word',
        'Apa pun bisa dilempar, bahkan sebuah kata biasa',
      ),
      code: r'''
Object? caught;
try {
  throw 'out of tea';
} catch (e) {
  caught = e;
}
expect(caught, __);''',
      answers: ["'out of tea'"],
      verify: () {
        Object? caught;
        try {
          // ignore: only_throw_errors
          throw 'out of tea';
        } catch (e) {
          caught = e;
        }
        return [caught];
      },
      explanation: const Tr(
        'Dart can throw any non-null object, and `catch (e)` without `on` '
            'catches them all. By convention we throw Exception or Error '
            'subtypes, so handlers can tell the kinds of trouble apart.',
        'Dart bisa melempar objek apa pun yang bukan null, dan `catch (e)` '
            'tanpa `on` menangkap semuanya. Sesuai konvensi, kita melempar '
            'subtype Exception atau Error, agar handler bisa membedakan jenis '
            'masalahnya.',
      ),
      docs: 'https://dart.dev/language/error-handling#throw',
      mistakes: const [
        Mistake(['null'], Tr(
          'The catch block did run. What did it receive?',
          'Blok catch memang dijalankan. Apa yang diterimanya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'finally keeps its promise, even after a return',
        'finally menepati janjinya, bahkan setelah return',
      ),
      code: r'''
final log = <String>[];
String run() {
  try {
    log.add('try');
    return 'result';
  } finally {
    log.add('finally');
  }
}
expect(run(), __);
expect(log, __);''',
      answers: ["'result'", "['try', 'finally']"],
      verify: () {
        final log = <String>[];
        String run() {
          try {
            log.add('try');
            return 'result';
          } finally {
            log.add('finally');
          }
        }

        return [run(), log];
      },
      explanation: const Tr(
        'A `finally` block runs however the `try` ends: normally, by `return`, '
            'or by an exception. That makes it the place to close files and '
            'release locks.',
        'Blok `finally` dijalankan bagaimanapun `try` berakhir: secara normal, '
            'lewat `return`, atau karena exception. Karena itu ia tempat yang '
            'tepat untuk menutup file dan melepas lock.',
      ),
      docs: 'https://dart.dev/language/error-handling#finally',
      mistakes: const [
        Mistake([null, "['try']"], Tr(
          'return leaves the function, but not before finally has had its say.',
          'return keluar dari fungsi, tetapi tidak sebelum finally mendapat '
              'gilirannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An Error is a mistake in the program; an Exception is a misfortune '
            'to handle',
        'Error adalah kesalahan dalam program; Exception adalah kemalangan '
            'yang perlu ditangani',
      ),
      code: r'''
String kind(Object problem) {
  try { throw problem; }
  on FormatException { return 'format'; }
  on Exception { return 'exception'; }
  catch (_) { return 'other'; }
}
expect(kind(Exception('offline')), __);
expect(kind(StateError('broken')), __);''',
      answers: ["'exception'", "'other'"],
      verify: () => [_kind(Exception('offline')), _kind(StateError('broken'))],
      explanation: const Tr(
        'Clauses are tried top to bottom, and the first that matches wins. '
            'StateError is an Error, not an Exception: Errors signal bugs to '
            'be fixed rather than conditions to recover from, so they '
            'usually should not be caught at all.',
        'Klausa dicoba dari atas ke bawah, dan yang pertama cocok yang '
            'menang. StateError adalah Error, bukan Exception: Error menandakan '
            'bug yang harus diperbaiki, bukan kondisi yang bisa dipulihkan, '
            'jadi biasanya ia tidak perlu ditangkap sama sekali.',
      ),
      docs: 'https://api.dart.dev/dart-core/Error-class.html',
      mistakes: const [
        Mistake(["'format'", null], Tr(
          'A plain Exception is not a FormatException; the subtype relation '
              'goes the other way.',
          'Exception biasa bukanlah FormatException; hubungan subtype-nya '
              'berlaku sebaliknya.',
        )),
        Mistake([null, "'exception'"], Tr(
          'Despite the name, a StateError is not an Exception.',
          'Meskipun namanya begitu, StateError bukanlah Exception.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Catch it, note it, and let it fly on',
        'Tangkap, catat, lalu biarkan ia terbang lagi',
      ),
      code: r'''
final log = <String>[];
try {
  try {
    throw StateError('broken');
  } catch (e) {
    log.add('noted');
    rethrow;
  }
} on StateError {
  log.add('handled');
}
expect(log, __);''',
      answers: ["['noted', 'handled']"],
      verify: () {
        final log = <String>[];
        try {
          try {
            throw StateError('broken');
          } catch (e) {
            log.add('noted');
            rethrow;
          }
        } on StateError {
          log.add('handled');
        }
        return [log];
      },
      explanation: const Tr(
        '`rethrow` sends the same error onward, with its original stack '
            'trace, to the next handler outside. It lets one layer log or '
            'clean up while another decides what to do.',
        '`rethrow` meneruskan error yang sama, dengan stack trace aslinya, ke '
            'handler berikutnya di luar. Dengan begitu satu lapisan bisa '
            'mencatat atau membersihkan, sementara lapisan lain memutuskan '
            'apa yang harus dilakukan.',
      ),
      docs: 'https://dart.dev/language/error-handling#catch',
      mistakes: const [
        Mistake(["['noted']"], Tr(
          'Catching it once does not end its journey here.',
          'Menangkapnya sekali tidak mengakhiri perjalanannya di sini.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Our own troubles deserve their own names',
        'Masalah kita sendiri layak mendapat nama sendiri',
      ),
      code: r'''
class InsufficientFunds implements Exception {
  InsufficientFunds(this.missing);
  final int missing;
  @override
  String toString() => 'Need $missing more';
}
void withdraw(int balance, int amount) {
  if (amount > balance) throw InsufficientFunds(amount - balance);
}
var message = '';
try { withdraw(30, 50); } on InsufficientFunds catch (e) { message = '$e'; }
expect(message, __);''',
      answers: ["'Need 20 more'"],
      verify: () {
        var message = '';
        try {
          _withdraw(30, 50);
        } on _InsufficientFunds catch (e) {
          message = '$e';
        }
        return [message];
      },
      explanation: const Tr(
        'A custom exception is an ordinary class that implements Exception. '
            'It can carry data, like the missing amount, and callers can '
            'catch exactly this case with `on InsufficientFunds`.',
        'Exception kustom adalah kelas biasa yang meng-implement Exception. '
            'Ia bisa membawa data, seperti jumlah yang kurang, dan pemanggil '
            'bisa menangkap kasus ini secara tepat dengan '
            '`on InsufficientFunds`.',
      ),
      docs: 'https://api.dart.dev/dart-core/Exception-class.html',
      mistakes: const [
        Mistake(["'Need 50 more'"], Tr(
          'The exception carries what is missing, not what was asked for.',
          'Exception ini membawa jumlah yang kurang, bukan yang diminta.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'throw is an expression; it can stand where a value would',
        'throw adalah ekspresi; ia bisa berdiri di tempat sebuah nilai',
      ),
      code: r'''
int age(String s) => int.tryParse(s) ?? (throw FormatException(s));
var result = 0;
try { result = age('ten'); } on FormatException { result = -1; }
expect(age('7'), __);
expect(result, __);''',
      answers: ['7', '-1'],
      verify: () {
        var result = 0;
        try {
          result = _age('ten');
        } on FormatException {
          result = -1;
        }
        return [_age('7'), result];
      },
      explanation: const Tr(
        'Because `throw` is an expression, it fits after `??` or in an arrow '
            'body. `int.tryParse` returns null instead of throwing, which lets '
            'us choose the error ourselves.',
        'Karena `throw` adalah ekspresi, ia bisa diletakkan setelah `??` atau '
            'di body arrow. `int.tryParse` mengembalikan null alih-alih '
            'melempar error, sehingga kita bisa memilih error-nya sendiri.',
      ),
      docs: 'https://dart.dev/language/error-handling#throw',
      mistakes: const [
        Mistake([null, '0'], Tr(
          'The assignment never happened, but something else did.',
          'Penetapan nilainya memang tidak terjadi, tetapi ada hal lain yang '
              'terjadi.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a checkout that fails gracefully',
        'Kumpulkan semuanya: kasir yang gagal dengan anggun',
      ),
      code: r'''
class EmptyCart implements Exception {}
final log = <String>[];
int checkout(List<int> prices) {
  try {
    if (prices.isEmpty) throw EmptyCart();
    return prices.reduce((a, b) => a + b);
  } on EmptyCart {
    log.add('empty');
    return 0;
  } finally {
    log.add('done');
  }
}
expect(checkout([3, 4]), __);
expect(checkout([]), __);
expect(log, __);''',
      answers: ['7', '0', "['done', 'empty', 'done']"],
      verify: () {
        final log = <String>[];
        int checkout(List<int> prices) {
          try {
            if (prices.isEmpty) throw _EmptyCart();
            return prices.reduce((a, b) => a + b);
          } on _EmptyCart {
            log.add('empty');
            return 0;
          } finally {
            log.add('done');
          }
        }

        return [checkout([3, 4]), checkout([]), log];
      },
      capstone: true,
      explanation: const Tr(
        'A custom exception marks the expected failure, `on` handles just '
            'that case, and `finally` runs after both the happy path and the '
            'handler. Throwing early keeps `reduce` from ever seeing an empty '
            'list, where it would throw a StateError of its own.',
        'Exception kustom menandai kegagalan yang sudah diduga, `on` hanya '
            'menangani kasus itu, dan `finally` berjalan setelah jalur normal '
            'maupun handler. Melempar sejak awal mencegah `reduce` menerima '
            'list kosong, yang akan membuatnya melempar StateError sendiri.',
      ),
      docs: 'https://dart.dev/language/error-handling',
      mistakes: const [
        Mistake([null, null, "['empty', 'done']"], Tr(
          'finally ran for the first checkout too.',
          'finally juga berjalan pada checkout yang pertama.',
        )),
        Mistake([null, null, "['done', 'done', 'empty']"], Tr(
          'finally comes after the handler, not before it.',
          'finally datang setelah handler, bukan sebelumnya.',
        )),
      ],
    ),
  ],
);

const _errors = Registry(symbols: {
  'FormatException': FormatException,
  'Exception': Exception,
  'Error': Error,
  'ArgumentError': ArgumentError,
  'StateError': StateError,
  'TypeError': TypeError,
  'RangeError': RangeError,
  'UnsupportedError': UnsupportedError,
});

String _describe(String s) {
  try {
    return 'number ${int.parse(s)}';
  } on FormatException {
    return 'not a number';
  }
}

String _kind(Object problem) {
  try {
    throw problem;
  } on FormatException {
    return 'format';
  } on Exception {
    return 'exception';
  } catch (_) {
    return 'other';
  }
}

class _InsufficientFunds implements Exception {
  _InsufficientFunds(this.missing);
  final int missing;
  @override
  String toString() => 'Need $missing more';
}

void _withdraw(int balance, int amount) {
  if (amount > balance) throw _InsufficientFunds(amount - balance);
}

int _age(String s) => int.tryParse(s) ?? (throw FormatException(s));

class _EmptyCart implements Exception {}

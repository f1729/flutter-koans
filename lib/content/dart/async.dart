import 'dart:async';

import '../../engine/koan.dart';

final asyncKoans = Category(
  id: 'async',
  title: const Tr('Async', 'Async'),
  intro: const Tr(
    'A future is a value that has not arrived yet. Patience is part of the '
        'type.',
    'Future adalah nilai yang belum tiba. Kesabaran adalah bagian dari '
        'tipenya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'An async function hands back a promise, not the thing itself',
        'Fungsi async mengembalikan sebuah janji, bukan bendanya sendiri',
      ),
      code: r'''
Future<String> greet() async => 'hello';
final f = greet();
expect(f is String, __);
expect(await f, __);''',
      answers: ['false', "'hello'"],
      verify: () async {
        final Object f = _greet();
        return [f is String, await (f as Future<String>)];
      },
      explanation: const Tr(
        'Calling an async function always returns a Future, even when the '
            'value is ready at once. `await` unwraps it, giving the String '
            'inside once the future completes.',
        'Memanggil fungsi async selalu mengembalikan Future, meskipun nilainya '
            'sudah langsung siap. `await` membukanya, memberikan String di '
            'dalamnya setelah future itu selesai.',
      ),
      docs: 'https://dart.dev/libraries/async/async-await#what-is-a-future',
      mistakes: const [
        Mistake(['true', null], Tr(
          'The function body returns a String, but what does the caller '
              'receive?',
          'Body fungsinya mengembalikan String, tetapi apa yang diterima '
              'pemanggilnya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'One word waits for the promise to be kept',
        'Satu kata menunggu janji itu ditepati',
      ),
      code: r'''
Future<int> fetchScore() async => 99;
final int score = __ fetchScore();
expect(score, 99);''',
      answers: ['await'],
      explanation: const Tr(
        '`await` pauses the surrounding async function until the future '
            'completes, then gives its value: here a plain int. It is only '
            'allowed inside an `async` function.',
        '`await` menjeda fungsi async di sekitarnya sampai future selesai, '
            'lalu memberikan nilainya: di sini sebuah int biasa. Ia hanya '
            'boleh dipakai di dalam fungsi `async`.',
      ),
      docs: 'https://dart.dev/language/async#handling-futures',
      mistakes: const [
        Mistake(['async'], Tr(
          'async marks a function that may wait; something else does the '
              'waiting.',
          'async menandai fungsi yang boleh menunggu; ada kata lain yang '
              'melakukan penantiannya.',
        )),
        Mistake(['final'], Tr(
          'The variable is already final. The value on the right is still a '
              'Future.',
          'Variabelnya sudah final. Nilai di sebelah kanan masih berupa '
              'Future.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'then passes the value along when it arrives',
        'then meneruskan nilainya saat ia tiba',
      ),
      code: r'''
final result = await Future.value(3)
    .then((n) => n * 2)
    .then((n) => '$n!');
expect(result, __);''',
      answers: ["'6!'"],
      verify: () async {
        final result =
            await Future.value(_n(3)).then((n) => n * 2).then((n) => '$n!');
        return [result];
      },
      explanation: const Tr(
        '`then` registers a callback and returns a new future for its result, '
            'so calls chain like a pipeline. `await` is usually easier to '
            'read, but both describe the same steps.',
        '`then` mendaftarkan callback dan mengembalikan future baru untuk '
            'hasilnya, sehingga pemanggilannya bisa dirangkai seperti pipa. '
            '`await` biasanya lebih mudah dibaca, tetapi keduanya menjelaskan '
            'langkah yang sama.',
      ),
      docs: 'https://api.dart.dev/dart-async/Future/then.html',
      mistakes: const [
        Mistake(["'3!'"], Tr(
          'Each then receives the result of the step before it.',
          'Setiap then menerima hasil dari langkah sebelumnya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An async function runs at once, until its first await',
        'Fungsi async langsung berjalan, sampai await pertamanya',
      ),
      code: r'''
final log = <String>[];
Future<void> work() async {
  log.add('start');
  await Future.delayed(Duration.zero);
  log.add('end');
}
final job = work();
log.add('caller');
await job;
expect(log, __);''',
      answers: ["['start', 'caller', 'end']"],
      verify: () async {
        final log = <String>[];
        Future<void> work() async {
          log.add('start');
          await Future<void>.delayed(Duration.zero);
          log.add('end');
        }

        final job = work();
        log.add('caller');
        await job;
        return [log];
      },
      explanation: const Tr(
        'The body of an async function starts synchronously and runs until '
            'the first `await`. Then it suspends, the caller carries on, and '
            'the rest resumes later from the event loop.',
        'Body fungsi async dimulai secara sinkron dan berjalan sampai `await` '
            'pertama. Lalu ia ditangguhkan, pemanggil melanjutkan, dan sisanya '
            'dilanjutkan nanti dari event loop.',
      ),
      docs: 'https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await',
      mistakes: const [
        Mistake(["['start', 'end', 'caller']"], Tr(
          'await pauses only the function it is in; the caller does not wait '
              'for it.',
          'await hanya menjeda fungsi tempat ia berada; pemanggilnya tidak '
              'ikut menunggu.',
        )),
        Mistake(["['caller', 'start', 'end']"], Tr(
          'Calling an async function does not postpone its first lines.',
          'Memanggil fungsi async tidak menunda baris-baris pertamanya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Microtasks cut in line before the next event',
        'Microtask menyela antrean sebelum event berikutnya',
      ),
      code: r'''
final log = <String>[];
Future.delayed(Duration.zero, () => log.add('timer'));
scheduleMicrotask(() => log.add('microtask'));
log.add('sync');
await Future.delayed(Duration.zero);
expect(log, __);''',
      answers: ["['sync', 'microtask', 'timer']"],
      verify: () async {
        final log = <String>[];
        Future<void>.delayed(Duration.zero, () => log.add('timer'));
        scheduleMicrotask(() => log.add('microtask'));
        log.add('sync');
        await Future<void>.delayed(Duration.zero);
        return [log];
      },
      hint: const Tr(
        'Synchronous code always finishes first. Then the microtask queue is '
            'emptied, and only then does the event loop take the next event.',
        'Kode sinkron selalu selesai lebih dulu. Lalu antrean microtask '
            'dikosongkan, dan baru setelah itu event loop mengambil event '
            'berikutnya.',
      ),
      explanation: const Tr(
        'Even with a zero delay, a timer is an event that waits its turn in '
            'the event loop. The microtask queue is drained completely before '
            'any event runs, which is why awaited futures resolve so quickly.',
        'Bahkan dengan jeda nol, timer adalah event yang menunggu gilirannya '
            'di event loop. Antrean microtask dikosongkan sepenuhnya sebelum '
            'event apa pun dijalankan, itulah sebabnya future yang di-await '
            'selesai begitu cepat.',
      ),
      docs: 'https://dart.dev/language/concurrency#event-loop',
      mistakes: const [
        Mistake(["['timer', 'microtask', 'sync']"], Tr(
          'Nothing asynchronous can interrupt synchronous code.',
          'Tidak ada yang asinkron yang bisa menyela kode sinkron.',
        )),
        Mistake(["['sync', 'timer', 'microtask']"], Tr(
          'A zero delay is still a trip through the event loop.',
          'Jeda nol tetaplah perjalanan melewati event loop.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Many promises can be awaited together',
        'Banyak janji bisa ditunggu bersama-sama',
      ),
      code: r'''
Future<int> slow(int n) async {
  await Future.delayed(Duration(milliseconds: n));
  return n * 10;
}
final results = await Future.wait([slow(3), slow(1), slow(2)]);
expect(results, __);''',
      answers: ['[30, 10, 20]'],
      verify: () async => [
        await Future.wait([_slow(3), _slow(1), _slow(2)]),
      ],
      explanation: const Tr(
        '`Future.wait` runs the futures at the same time and completes when '
            'all of them do. The results come back in the order the futures '
            'were given, however they happened to finish.',
        '`Future.wait` menjalankan future-future itu bersamaan dan selesai '
            'ketika semuanya selesai. Hasilnya kembali sesuai urutan future '
            'diberikan, bagaimanapun urutan selesainya.',
      ),
      docs: 'https://api.dart.dev/dart-async/Future/wait.html',
      mistakes: const [
        Mistake(['[10, 20, 30]'], Tr(
          'That is the order they finished in. Is that the order the results '
              'keep?',
          'Itu urutan selesainya. Apakah itu urutan yang dipakai untuk '
              'hasilnya?',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A broken promise can be caught like any other error',
        'Janji yang diingkari bisa ditangkap seperti error lainnya',
      ),
      code: r'''
Future<int> load() async => throw StateError('offline');
String status;
try {
  await load();
  status = 'loaded';
} on StateError {
  status = 'failed';
}
expect(status, __);''',
      answers: ["'failed'"],
      verify: () async {
        String status;
        try {
          await _load();
          status = 'loaded';
        } on StateError {
          status = 'failed';
        }
        return [status];
      },
      explanation: const Tr(
        'A future that fails rethrows its error at the `await`, so an '
            'ordinary try/catch handles it. Without the `await`, the error '
            'would escape the try block and surface elsewhere, unhandled.',
        'Future yang gagal melempar ulang error-nya di titik `await`, jadi '
            'try/catch biasa bisa menanganinya. Tanpa `await`, error itu akan '
            'lolos dari blok try dan muncul di tempat lain tanpa tertangani.',
      ),
      docs: 'https://dart.dev/libraries/async/async-await#handling-errors',
      mistakes: const [
        Mistake(["'loaded'"], Tr(
          'The error arrives at the await, before the next line runs.',
          'Error-nya tiba di await, sebelum baris berikutnya dijalankan.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Or a fallback can be offered in advance',
        'Atau sebuah cadangan bisa disiapkan sebelumnya',
      ),
      code: r'''
final value = await Future<int>.error('boom')
    .catchError((_) => -1);
expect(value, __);''',
      answers: ['-1'],
      verify: () async {
        final value = await Future<int>.error('boom').catchError((_) => -1);
        return [value];
      },
      explanation: const Tr(
        '`catchError` turns a failed future into a successful one with the '
            'value its callback returns. It is the `then`-style twin of '
            'try/catch around an `await`.',
        '`catchError` mengubah future yang gagal menjadi future yang berhasil '
            'dengan nilai yang dikembalikan callback-nya. Ia adalah kembaran '
            'gaya `then` dari try/catch di sekitar `await`.',
      ),
      docs: 'https://api.dart.dev/dart-async/Future/catchError.html',
      mistakes: const [
        Mistake(["'boom'"], Tr(
          'The error is replaced by what the callback returns.',
          'Error-nya digantikan oleh apa yang dikembalikan callback.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: fetch together, and fail together',
        'Kumpulkan semuanya: ambil bersama, dan gagal bersama',
      ),
      code: r'''
Future<int> fetch(String id) async {
  await Future.delayed(Duration.zero);
  if (id.isEmpty) throw StateError('missing');
  return id.length;
}
Future<int> total(List<String> ids) async {
  try {
    final sizes = await Future.wait(ids.map(fetch));
    return sizes.reduce((a, b) => a + b);
  } on StateError {
    return -1;
  }
}
expect(await total(['ab', 'cde']), __);
expect(await total(['ab', '']), __);''',
      answers: ['5', '-1'],
      verify: () async => [
        await _total(['ab', 'cde']),
        await _total(['ab', '']),
      ],
      capstone: true,
      explanation: const Tr(
        'Future.wait starts every fetch at once and gathers their results in '
            'order. If any fetch fails, the combined future fails with that '
            'error, and the try/catch around the `await` turns it into a '
            'fallback.',
        'Future.wait memulai setiap fetch sekaligus dan mengumpulkan hasilnya '
            'secara berurutan. Jika ada fetch yang gagal, future gabungannya '
            'ikut gagal dengan error itu, dan try/catch di sekitar `await` '
            'mengubahnya menjadi nilai cadangan.',
      ),
      docs: 'https://dart.dev/language/async',
      mistakes: const [
        Mistake([null, '2'], Tr(
          'Future.wait does not skip the futures that fail.',
          'Future.wait tidak melewatkan future yang gagal.',
        )),
      ],
    ),
  ],
);

Future<String> _greet() async => 'hello';

Future<int> _slow(int n) async {
  await Future<void>.delayed(Duration(milliseconds: n));
  return n * 10;
}

Future<int> _load() async => throw StateError('offline');

Future<int> _fetch(String id) async {
  await Future<void>.delayed(Duration.zero);
  if (id.isEmpty) throw StateError('missing');
  return id.length;
}

Future<int> _total(List<String> ids) async {
  try {
    final sizes = await Future.wait(ids.map(_fetch));
    return sizes.reduce((a, b) => a + b);
  } on StateError {
    return -1;
  }
}

// Built at runtime so the analyzer does not fold it into a constant.
int _n(int value) => value;

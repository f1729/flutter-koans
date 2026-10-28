import '../../engine/koan.dart';

final streams = Category(
  id: 'streams',
  title: const Tr('Streams', 'Stream'),
  intro: const Tr(
    'A future gives one value; a stream is a river of them.',
    'Future memberikan satu nilai; stream adalah sungai yang mengalirkan '
        'banyak nilai.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A stream can be shaped as it flows',
        'Stream bisa dibentuk selagi ia mengalir',
      ),
      code: r'''
final squares = Stream.fromIterable([1, 2, 3]).map((x) => x * x);
expect(await squares.toList(), __);''',
      answers: ['[1, 4, 9]'],
      verify: () async => [
        await Stream.fromIterable([1, 2, 3]).map((x) => x * x).toList(),
      ],
      explanation: const Tr(
        'Streams have many of the same methods as iterables, but each one '
            'returns a new stream that works as values arrive. `toList` '
            'returns a Future that completes when the stream is done.',
        'Stream punya banyak method yang sama dengan iterable, tetapi '
            'masing-masing mengembalikan stream baru yang bekerja saat '
            'nilai-nilai tiba. `toList` mengembalikan Future yang selesai '
            'ketika stream-nya berakhir.',
      ),
      docs: 'https://dart.dev/libraries/async/using-streams#modify-stream-methods',
      mistakes: const [
        Mistake(['[2, 4, 6]'], Tr(
          'Look again at what map does to each x.',
          'Perhatikan lagi apa yang dilakukan map pada setiap x.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Let only some through, and stop when we have enough',
        'Loloskan hanya sebagian, dan berhenti saat sudah cukup',
      ),
      code: r'''
final evens = Stream.fromIterable([1, 2, 3, 4, 5, 6])
    .where((n) => n.isEven)
    .take(2);
expect(await evens.toList(), __);''',
      answers: ['[2, 4]'],
      verify: () async => [
        await Stream.fromIterable([1, 2, 3, 4, 5, 6])
            .where((n) => n.isEven)
            .take(2)
            .toList(),
      ],
      explanation: const Tr(
        '`where` filters events and `take(2)` ends the stream after two of '
            'them, cancelling its source. The order of the steps matters: '
            'taking first would give fewer evens.',
        '`where` menyaring event dan `take(2)` mengakhiri stream setelah dua '
            'event, sekaligus membatalkan sumbernya. Urutan langkahnya '
            'penting: jika take didahulukan, bilangan genapnya akan lebih '
            'sedikit.',
      ),
      docs: 'https://api.dart.dev/dart-async/Stream/take.html',
      mistakes: const [
        Mistake(['[2]'], Tr(
          'take counts the events that made it through where.',
          'take menghitung event yang berhasil lolos dari where.',
        )),
        Mistake(['[2, 4, 6]'], Tr(
          'take puts a limit on how many get through.',
          'take membatasi berapa banyak yang boleh lewat.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'await for walks the river, one stone at a time',
        'await for menyusuri sungai, satu batu demi satu batu',
      ),
      code: r'''
var sum = 0;
await for (final n in Stream.fromIterable([1, 2, 3, 4])) {
  sum += n;
}
expect(sum, __);''',
      answers: ['10'],
      verify: () async {
        var sum = 0;
        await for (final n in Stream.fromIterable([1, 2, 3, 4])) {
          sum += n;
        }
        return [sum];
      },
      explanation: const Tr(
        '`await for` runs the loop body once per event and waits between '
            'them, finishing only when the stream is done. Like `await`, it '
            'needs an async function, and it should not be used on streams '
            'that never end, such as UI events.',
        '`await for` menjalankan body loop sekali untuk setiap event dan '
            'menunggu di antaranya, lalu baru selesai saat stream-nya '
            'berakhir. Seperti `await`, ia butuh fungsi async, dan sebaiknya '
            'tidak dipakai pada stream yang tak pernah berakhir, seperti '
            'event UI.',
      ),
      docs: 'https://dart.dev/language/async#handling-streams',
    ),
    Koan(
      prompt: const Tr(
        'An async* function sings its values one by one',
        'Fungsi async* menyanyikan nilai-nilainya satu per satu',
      ),
      code: r'''
Stream<int> countdown(int from) async* {
  for (var i = from; i > 0; i--) {
    yield i;
  }
}
expect(await countdown(3).toList(), __);''',
      answers: ['[3, 2, 1]'],
      verify: () async => [await _countdown(3).toList()],
      explanation: const Tr(
        'An `async*` function returns a Stream, and each `yield` sends one '
            'event to the listener. The body runs only when someone listens, '
            'and the stream closes when the body ends.',
        'Fungsi `async*` mengembalikan Stream, dan setiap `yield` mengirim '
            'satu event ke listener. Body-nya hanya berjalan saat ada yang '
            'mendengarkan, dan stream-nya ditutup saat body berakhir.',
      ),
      docs: 'https://dart.dev/language/functions#generators',
      mistakes: const [
        Mistake(['[3, 2, 1, 0]'], Tr(
          'Look at when the loop stops.',
          'Perhatikan kapan loop-nya berhenti.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'One word releases each value into the stream',
        'Satu kata melepaskan setiap nilai ke dalam stream',
      ),
      code: r'''
Stream<String> greetings() async* {
  __ 'hello';
  __ 'goodbye';
}
expect(await greetings().toList(), ['hello', 'goodbye']);''',
      answers: ['yield', 'yield'],
      explanation: const Tr(
        '`yield` emits a value and lets the function continue, so a single '
            'call can produce many events. `return` would end the stream, '
            'and in an `async*` function it cannot carry a value.',
        '`yield` mengirim sebuah nilai dan membiarkan fungsinya berlanjut, '
            'jadi satu pemanggilan bisa menghasilkan banyak event. `return` '
            'akan mengakhiri stream, dan di fungsi `async*` ia tidak boleh '
            'membawa nilai.',
      ),
      docs: 'https://dart.dev/language/functions#generators',
      mistakes: const [
        Mistake(['return', null], Tr(
          'return would end the function at once, and an async* function '
              'cannot return a value.',
          'return akan langsung mengakhiri fungsi, dan fungsi async* tidak '
              'boleh mengembalikan nilai.',
        )),
        Mistake(['await', null], Tr(
          'await waits for a value; here we want to send one out.',
          'await menunggu sebuah nilai; di sini kita ingin mengirimkannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A stream can pour another stream into itself',
        'Stream bisa menuangkan stream lain ke dalam dirinya',
      ),
      code: r'''
Stream<int> middle() async* {
  yield 1;
  yield 2;
}
Stream<int> all() async* {
  yield 0;
  yield* middle();
  yield 3;
}
expect(await all().toList(), __);''',
      answers: ['[0, 1, 2, 3]'],
      verify: () async => [await _all().toList()],
      explanation: const Tr(
        '`yield*` forwards every event of another stream, in order, before '
            'continuing. It is how generators delegate to one another, and '
            'how recursive generators stay simple.',
        '`yield*` meneruskan setiap event dari stream lain, secara berurutan, '
            'sebelum melanjutkan. Begitulah generator mendelegasikan kepada '
            'generator lain, dan begitulah generator rekursif tetap '
            'sederhana.',
      ),
      docs: 'https://dart.dev/language/functions#generators',
      mistakes: const [
        Mistake(['[0, 3]'], Tr(
          'yield* does not skip the inner stream; it emits it.',
          'yield* tidak melewatkan stream di dalamnya; ia mengirimkannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'A listener is called later, never right away',
        'Listener dipanggil nanti, tidak pernah saat itu juga',
      ),
      code: r'''
final seen = <String>[];
final sub = Stream.fromIterable(['a', 'b']).listen(seen.add);
final before = seen.length;
await sub.asFuture<void>();
expect(before, __);
expect(seen, __);''',
      answers: ['0', "['a', 'b']"],
      verify: () async {
        final seen = <String>[];
        final sub = Stream.fromIterable(['a', 'b']).listen(seen.add);
        final before = seen.length;
        await sub.asFuture<void>();
        return [before, seen];
      },
      explanation: const Tr(
        '`listen` registers a callback and returns a StreamSubscription '
            'straight away; events are delivered asynchronously, after the '
            'current code finishes. The subscription can pause, resume or '
            'cancel the flow.',
        '`listen` mendaftarkan callback dan langsung mengembalikan '
            'StreamSubscription; event dikirim secara asinkron, setelah kode '
            'saat ini selesai. Subscription itu bisa menjeda, melanjutkan, '
            'atau membatalkan alirannya.',
      ),
      docs: 'https://dart.dev/libraries/async/using-streams#listen-method',
      mistakes: const [
        Mistake(['2', null], Tr(
          'The values were all ready, yet listen did not deliver them on the '
              'spot.',
          'Nilai-nilainya sudah siap semua, tetapi listen tidak langsung '
              'mengirimkannya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Most streams can be heard only once',
        'Kebanyakan stream hanya bisa didengarkan sekali',
      ),
      code: r'''
Stream<int> numbers() async* {
  yield 1;
}
final stream = numbers();
await stream.toList();
expect(() => stream.toList(), throwsA(isA<__>()));''',
      answers: ['StateError'],
      registry: const Registry(symbols: {'StateError': StateError}),
      verify: () async {
        final stream = _numbers();
        await stream.toList();
        Type? thrown;
        try {
          await stream.toList();
        } on StateError {
          thrown = StateError;
        }
        return [thrown];
      },
      explanation: const Tr(
        'A single-subscription stream delivers its events to one listener; '
            'listening again is a StateError. Broadcast streams, from '
            '`asBroadcastStream()` or `StreamController.broadcast()`, allow '
            'many listeners instead.',
        'Stream single-subscription mengirim event-nya ke satu listener saja; '
            'mendengarkannya lagi menghasilkan StateError. Broadcast stream, '
            'dari `asBroadcastStream()` atau `StreamController.broadcast()`, '
            'mengizinkan banyak listener.',
      ),
      docs: 'https://dart.dev/libraries/async/using-streams#single-subscription-streams',
      mistakes: const [
        Mistake(['ArgumentError'], Tr(
          'Nothing is wrong with the arguments. What is wrong is the state of '
              'the stream.',
          'Tidak ada yang salah dengan argumennya. Yang salah adalah keadaan '
              'stream-nya.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'An endless river is fine, if we only drink what we need',
        'Sungai yang tak berujung tidak apa-apa, asalkan kita hanya minum '
            'secukupnya',
      ),
      code: r'''
Stream<int> naturals() async* {
  var n = 0;
  while (true) {
    yield n++;
  }
}
expect(await naturals().take(3).toList(), __);''',
      answers: ['[0, 1, 2]'],
      verify: () async => [await _naturals().take(3).toList()],
      explanation: const Tr(
        'A generator only runs while someone is listening. When `take(3)` has '
            'its three values it cancels the subscription, and the `async*` '
            'body stops at its next `yield`.',
        'Generator hanya berjalan selama ada yang mendengarkan. Saat '
            '`take(3)` sudah mendapat tiga nilainya, ia membatalkan '
            'subscription, dan body `async*` berhenti di `yield` '
            'berikutnya.',
      ),
      docs: 'https://api.dart.dev/dart-async/Stream/take.html',
      mistakes: const [
        Mistake(['[1, 2, 3]'], Tr(
          'n++ gives the value before it grows.',
          'n++ memberikan nilai sebelum ia bertambah.',
        )),
      ],
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: read the sensor, skip the noise',
        'Kumpulkan semuanya: baca sensornya, abaikan gangguannya',
      ),
      code: r'''
Stream<int> temps() async* {
  for (final line in ['t 21', 'noise', 't 25', 't 19']) {
    if (line.startsWith('t ')) yield int.parse(line.substring(2));
  }
}
var max = 0;
await for (final t in temps()) {
  if (t > max) max = t;
}
expect(max, __);
expect(await temps().where((t) => t > 20).length, __);
expect(await temps().map((t) => t - 20).toList(), __);''',
      answers: ['25', '2', '[1, 5, -1]'],
      verify: () async {
        var max = 0;
        await for (final t in _temps()) {
          if (t > max) max = t;
        }
        return [
          max,
          await _temps().where((t) => t > 20).length,
          await _temps().map((t) => t - 20).toList(),
        ];
      },
      capstone: true,
      explanation: const Tr(
        'The generator filters and parses as it yields, `await for` consumes '
            'it like a loop, and stream methods transform it like an '
            'iterable. Each call to `temps()` makes a fresh stream, so it can '
            'be listened to again.',
        'Generator-nya menyaring dan mengurai selagi ia melakukan yield, '
            '`await for` mengonsumsinya seperti loop, dan method stream '
            'mengubahnya seperti iterable. Setiap pemanggilan `temps()` '
            'membuat stream baru, jadi ia bisa didengarkan lagi.',
      ),
      docs: 'https://dart.dev/libraries/async/using-streams',
      mistakes: const [
        Mistake([null, '3', null], Tr(
          'where keeps only the readings above 20.',
          'where hanya menyimpan bacaan yang di atas 20.',
        )),
        Mistake([null, null, '[1, 5, 1]'], Tr(
          'One reading is below 20. What is left when we subtract 20 from it?',
          'Ada satu bacaan di bawah 20. Berapa sisanya jika dikurangi 20?',
        )),
      ],
    ),
  ],
);

Stream<int> _countdown(int from) async* {
  for (var i = from; i > 0; i--) {
    yield i;
  }
}

Stream<int> _middle() async* {
  yield 1;
  yield 2;
}

Stream<int> _all() async* {
  yield 0;
  yield* _middle();
  yield 3;
}

Stream<int> _numbers() async* {
  yield 1;
}

Stream<int> _naturals() async* {
  var n = 0;
  while (true) {
    yield n++;
  }
}

Stream<int> _temps() async* {
  for (final line in ['t 21', 'noise', 't 25', 't 19']) {
    if (line.startsWith('t ')) yield int.parse(line.substring(2));
  }
}

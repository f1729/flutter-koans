import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

const _quote = 'Water flows around the stone';
const _failure = 'the well is dry';
const _fetchTime = Duration(milliseconds: 1600);

/// Snapshot getters and lifecycle methods a learner may name.
const _snapshotGetters = [
  'hasData',
  'hasError',
  'data',
  'error',
  'connectionState',
  'requireData',
  'stackTrace',
];
const _lifecycle = [
  'createState',
  'initState',
  'didChangeDependencies',
  'build',
  'didUpdateWidget',
  'setState',
  'deactivate',
  'dispose',
];

final _asyncRegistry = flutterRegistry.merge(
  Registry(
    symbols: {
      for (final name in [..._snapshotGetters, ..._lifecycle]) name: name,
    },
  ),
);

/// Reads a bool getter of [s] by name; the preview checks the name first.
bool _ask(AsyncSnapshot<Object?> s, String getter) =>
    getter == 'hasError' ? s.hasError : s.hasData;

String _boolGetter(Object? v) {
  if (v != 'hasError' && v != 'hasData') throw ArgumentError.value(v);
  return v! as String;
}

/// The four connection states, with the current one lit.
class _States extends StatelessWidget {
  const _States(this.current);

  final ConnectionState current;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in ConnectionState.values)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: s == current ? kSky : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: s == current ? kSky : kFrame),
            ),
            child: Text(
              s.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: s == current
                    ? Colors.white
                    : kInk.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    ),
  );
}

/// What a builder shows: the connection state above, the result below.
Widget _stage(ConnectionState state, Widget result) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    _States(state),
    const SizedBox(height: 18),
    SizedBox(height: 74, child: Center(child: result)),
  ],
);

const _spinner = SizedBox(
  width: 28,
  height: 28,
  child: CircularProgressIndicator(strokeWidth: 3),
);

Widget _text(Object? data) => Text(
  '$data',
  textAlign: TextAlign.center,
  style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
);

const _nullCheck = FittedBox(
  child: ErrorCard(
    'Null check operator used on a null value',
    title: 'TypeError',
  ),
);

/// Runs a pretend fetch, a future that settles after a moment, and offers
/// to run it again. A ticker drives it, so no timer is ever left pending.
class _Replay extends StatefulWidget {
  const _Replay({
    required this.builder,
    this.value = _quote,
    this.fails = false,
    this.offerFailure = false,
  });

  final Widget Function(Future<Object?> future) builder;
  final Object? value;
  final bool fails;

  /// Whether to offer both a run that succeeds and one that fails.
  final bool offerFailure;

  @override
  State<_Replay> createState() => _ReplayState();
}

class _ReplayState extends State<_Replay> with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(vsync: this, duration: _fetchTime)
    ..addStatusListener(_settle);
  late Completer<Object?> _completer;
  late bool _fails;

  @override
  void initState() {
    super.initState();
    _start(widget.fails);
  }

  void _start(bool fails) {
    _fails = fails;
    _completer = Completer()..future.ignore();
    _clock.forward(from: 0);
  }

  void _settle(AnimationStatus status) {
    if (status != AnimationStatus.completed || _completer.isCompleted) return;
    _fails
        ? _completer.completeError(_failure)
        : _completer.complete(widget.value);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  Widget _button(String label, bool fails) => TextButton(
    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    onPressed: () => setState(() => _start(fails)),
    child: Text(label),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(child: Center(child: widget.builder(_completer.future))),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              child: AnimatedBuilder(
                animation: _clock,
                builder: (context, _) => LinearProgressIndicator(
                  value: _clock.value,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (widget.offerFailure) ...[
              _button('succeed', false),
              _button('fail', true),
            ] else
              _button('replay', widget.fails),
          ],
        ),
      ),
    ],
  );
}

/// Fetches a quote from the lifecycle method named [mode], and rebuilds on
/// demand, to show which methods run once and which run again and again.
class _Lifecycle extends StatefulWidget {
  const _Lifecycle({super.key, required this.mode});

  final String mode;

  @override
  State<_Lifecycle> createState() => _LifecycleState();
}

class _LifecycleState extends State<_Lifecycle>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(vsync: this, duration: _fetchTime)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && !_pending.isCompleted) {
        _pending.complete(_quote);
      }
    });
  Completer<Object?> _pending = Completer();
  Future<Object?>? _future;
  int _fetches = 0;

  Future<Object?> _fetch() {
    _fetches++;
    _pending = Completer();
    // Started after the frame, since build may be what called us.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _clock.forward(from: 0);
    });
    return _pending.future;
  }

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'initState') _future = _fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.mode == 'didChangeDependencies') _future = _fetch();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'build') _future = _fetch();
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FutureBuilder<Object?>(
              future: _future,
              builder: (context, s) =>
                  _stage(s.connectionState, switch (s.connectionState) {
                    ConnectionState.none => const Caption(
                      'no future, nothing to wait for',
                    ),
                    ConnectionState.waiting => _spinner,
                    _ => _text(s.data),
                  }),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Caption('fetches: $_fetches'),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => setState(() {}),
                child: const Text('rebuild'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A stream of three breaths, then silence, shown through a StreamBuilder
/// that names [breathing] as the state in which breaths are shown.
class _Breaths extends StatefulWidget {
  const _Breaths({required this.breathing});

  final ConnectionState breathing;

  @override
  State<_Breaths> createState() => _BreathsState();
}

class _BreathsState extends State<_Breaths>
    with SingleTickerProviderStateMixin {
  static const _marks = [0.2, 0.45, 0.7];
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..addListener(_tick);
  late StreamController<int> _breaths;
  int _sent = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _breaths = StreamController();
    _sent = 0;
    _clock.forward(from: 0);
  }

  void _tick() {
    while (_sent < _marks.length && _clock.value >= _marks[_sent]) {
      _breaths.add(++_sent);
    }
    if (_clock.isCompleted && !_breaths.isClosed) _breaths.close();
  }

  @override
  void dispose() {
    _clock.dispose();
    _breaths.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: StreamBuilder<int>(
            stream: _breaths.stream,
            builder: (context, s) {
              final state = s.connectionState;
              final shown = state == widget.breathing
                  ? 'Breath ${s.data}'
                  : switch (state) {
                      ConnectionState.none => 'No stream',
                      ConnectionState.waiting => 'Settling in',
                      ConnectionState.done => 'Rest',
                      ConnectionState.active => '(no case for active)',
                    };
              return _stage(state, _text(shown));
            },
          ),
        ),
      ),
      TextButton(
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => setState(() {
          _breaths.close();
          _start();
        }),
        child: const Text('replay'),
      ),
    ],
  );
}

final asyncUi = Category(
  id: 'async-ui',
  title: const Tr('Async UI', 'UI Asinkron'),
  intro: const Tr(
    'The future has not arrived yet. Build for the waiting, too.',
    'Future belum tiba. Bangun juga tampilan untuk masa menunggunya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A future is a promise of a value. Build one thing while we wait, '
            'and another when it arrives',
        'Future adalah janji akan sebuah nilai. Bangun satu tampilan selama '
            'kita menunggu, dan tampilan lain saat nilainya tiba',
      ),
      code: r'''
__<String>(
  future: _quote,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    return Text(snapshot.data!);
  },
)''',
      answers: ['FutureBuilder'],
      explanation: const Tr(
        'FutureBuilder listens to the future and calls builder again each '
            'time the snapshot changes: once while waiting, once more when the '
            'value or an error arrives. The builder runs before the future is '
            'done, so it must handle every state.',
        'FutureBuilder mendengarkan future dan memanggil builder lagi setiap '
            'kali snapshot berubah: sekali saat menunggu, sekali lagi saat '
            'nilai atau error tiba. Builder berjalan sebelum future selesai, '
            'jadi ia harus menangani setiap state.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html',
      mistakes: const [
        Mistake(
          ['StreamBuilder'],
          Tr(
            'A StreamBuilder listens to a stream of many values; here there is '
                'a single future.',
            'StreamBuilder mendengarkan stream berisi banyak nilai; di sini '
                'hanya ada satu future.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) {
        if (v[0] != FutureBuilder) throw ArgumentError.value(v[0]);
        return PreviewCanvas(
          child: _Replay(
            builder: (future) => FutureBuilder<Object?>(
              future: future,
              builder: (context, s) => _stage(
                s.connectionState,
                s.hasData ? _text(s.data) : _spinner,
              ),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Before there is any future, there is nothing to wait for',
        'Sebelum ada future, tidak ada yang perlu ditunggu',
      ),
      code: r'''
const snapshot = AsyncSnapshot<String>.nothing();
expect(snapshot.connectionState, __);
expect(snapshot.hasData, __);''',
      answers: ['ConnectionState.none', 'false'],
      verify: () {
        const snapshot = AsyncSnapshot<String>.nothing();
        return [snapshot.connectionState, snapshot.hasData];
      },
      explanation: const Tr(
        'A FutureBuilder whose future is null stays in ConnectionState.none, '
            'holding only its initialData, if any. Given a future, it moves '
            'to waiting, and then to done.',
        'FutureBuilder yang future-nya null tetap berada di '
            'ConnectionState.none, hanya memegang initialData jika ada. Saat '
            'diberi future, ia pindah ke waiting, lalu ke done.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/AsyncSnapshot/AsyncSnapshot.nothing.html',
      mistakes: const [
        Mistake(
          ['ConnectionState.waiting', null],
          Tr(
            'Waiting means a future exists and has not finished. Here there is '
                'no future at all.',
            'Waiting berarti future sudah ada dan belum selesai. Di sini tidak '
                'ada future sama sekali.',
          ),
        ),
      ],
      registry: _asyncRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Show the spinner only while the future is still on its way',
        'Tampilkan spinner hanya selama future masih dalam perjalanan',
      ),
      code: r'''
builder: (context, snapshot) {
  if (snapshot.connectionState == __) {
    return const CircularProgressIndicator();
  }
  return Text(snapshot.data!);
},''',
      answers: ['ConnectionState.waiting'],
      explanation: const Tr(
        'A FutureBuilder with a future starts in waiting and ends in done; it '
            'never reports active, which belongs to streams. While waiting, '
            'data is null unless initialData was given, so data! there would '
            'throw.',
        'FutureBuilder yang punya future dimulai di waiting dan berakhir di '
            'done; ia tidak pernah melaporkan active, yang merupakan milik '
            'stream. Selama waiting, data bernilai null kecuali initialData '
            'diberikan, jadi data! di sana akan melempar error.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ConnectionState.html',
      mistakes: const [
        Mistake(
          ['ConnectionState.done'],
          Tr(
            'Then the spinner appears only after the quote has come, and before '
                'that, data! meets a null.',
            'Maka spinner baru muncul setelah kutipannya tiba, dan sebelum itu, '
                'data! bertemu null.',
          ),
        ),
        Mistake(
          ['ConnectionState.active'],
          Tr(
            'active belongs to streams that are still flowing. A future goes '
                'straight from waiting to done.',
            'active milik stream yang masih mengalir. Future langsung berpindah '
                'dari waiting ke done.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) {
        final spinning = v[0] as ConnectionState;
        return PreviewCanvas(
          child: _Replay(
            builder: (future) => FutureBuilder<Object?>(
              future: future,
              builder: (context, s) => _stage(
                s.connectionState,
                s.connectionState == spinning
                    ? _spinner
                    : s.data == null
                    ? _nullCheck
                    : _text(s.data),
              ),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Until the real count arrives, show zero rather than null',
        'Sampai jumlah sebenarnya tiba, tampilkan nol, bukan null',
      ),
      code: r'''
FutureBuilder<int>(
  future: _likes,
  initialData: __,
  builder: (context, snapshot) => Text('♥ ${snapshot.data}'),
)''',
      answers: ['0'],
      explanation: const Tr(
        'initialData is what the snapshot holds before the future completes, '
            'so the very first build already has something to show. It is '
            'used only at the start; if the future is later replaced, the last '
            'data is kept instead.',
        'initialData adalah isi snapshot sebelum future selesai, jadi build '
            'pertama pun sudah punya sesuatu untuk ditampilkan. Ia hanya '
            'dipakai di awal; jika future kemudian diganti, data terakhir yang '
            'dipertahankan.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/FutureBuilder/initialData.html',
      mistakes: const [
        Mistake(
          ['null'],
          Tr(
            'That is what data already is while waiting, and the heart would '
                'read null.',
            'Itulah nilai data selama menunggu, dan hatinya akan bertuliskan '
                'null.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) => PreviewCanvas(
        child: _Replay(
          value: 108,
          builder: (future) => FutureBuilder<Object?>(
            future: future,
            initialData: v[0],
            builder: (context, s) => _stage(
              s.connectionState,
              Text(
                '♥ ${s.data}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: kRose,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Not every promise is kept. When the well runs dry, say so',
        'Tidak setiap janji ditepati. Saat sumurnya kering, katakan saja',
      ),
      code: r'''
builder: (context, snapshot) {
  if (snapshot.__) {
    return Text('The well is dry');
  }
  if (!snapshot.hasData) {
    return const CircularProgressIndicator();
  }
  return Text(snapshot.data!);
},''',
      answers: ['hasError'],
      explanation: const Tr(
        'When a future fails, the snapshot holds an error and no data. Check '
            'hasError before hasData; otherwise a failure looks exactly like '
            'waiting, and the spinner turns forever.',
        'Saat future gagal, snapshot memegang error dan tidak memegang data. '
            'Periksa hasError sebelum hasData; jika tidak, kegagalan tampak '
            'persis seperti menunggu, dan spinner berputar selamanya.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/AsyncSnapshot/hasError.html',
      mistakes: const [
        Mistake(
          ['hasData'],
          Tr(
            'An error is not data. When the future fails, hasData stays false '
                'and the spinner turns forever.',
            'Error bukanlah data. Saat future gagal, hasData tetap false dan '
                'spinner berputar selamanya.',
          ),
        ),
        Mistake(
          ['error'],
          Tr(
            'error holds the error itself, not a yes or a no, and if needs a '
                'bool.',
            'error menyimpan error itu sendiri, bukan ya atau tidak, sedangkan '
                'if membutuhkan bool.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) {
        final getter = _boolGetter(v[0]);
        return PreviewCanvas(
          child: _Replay(
            fails: true,
            builder: (future) => FutureBuilder<Object?>(
              future: future,
              builder: (context, s) => _stage(
                s.connectionState,
                _ask(s, getter)
                    ? _text('The well is dry')
                    : !s.hasData
                    ? _spinner
                    : _text(s.data),
              ),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A future made in build is made again on every rebuild, and the '
            'waiting starts over. Make it once, when the State is born',
        'Future yang dibuat di build akan dibuat lagi setiap build ulang, dan '
            'penantiannya dimulai dari awal. Buat sekali saja, saat State '
            'lahir',
      ),
      code: r'''
late Future<String> _quote;

@override
void __() {
  super.__();
  _quote = fetchQuote();
}''',
      answers: ['initState', 'initState'],
      hint: const Tr(
        'Press rebuild in both previews and watch the fetches.',
        'Tekan rebuild di kedua pratinjau dan perhatikan jumlah fetch-nya.',
      ),
      explanation: const Tr(
        'initState runs exactly once per State, so the future it creates '
            'survives every rebuild and FutureBuilder keeps its result. A '
            'future created inside build is a new future each time, and '
            'FutureBuilder dutifully starts waiting again.',
        'initState berjalan tepat sekali untuk setiap State, jadi future yang '
            'dibuatnya bertahan melewati setiap build ulang dan FutureBuilder '
            'tetap menyimpan hasilnya. Future yang dibuat di dalam build '
            'adalah future baru setiap kali, dan FutureBuilder dengan patuh '
            'mulai menunggu lagi.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/FutureBuilder/future.html',
      mistakes: const [
        Mistake(
          ['build', 'build'],
          Tr(
            'build runs again and again; a future made there is fetched again '
                'each time.',
            'build berjalan berulang kali; future yang dibuat di sana diambil '
                'ulang setiap kali.',
          ),
        ),
        Mistake(
          ['didChangeDependencies', 'didChangeDependencies'],
          Tr(
            'That runs again whenever an inherited widget it depends on '
                'changes. We want exactly once.',
            'Itu berjalan lagi setiap kali inherited widget yang menjadi '
                'dependensinya berubah. Kita ingin tepat sekali.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) {
        final mode = v[0] as String;
        if (mode != v[1] || !_lifecycle.contains(mode)) {
          throw ArgumentError.value(v);
        }
        return PreviewCanvas(
          child: _Lifecycle(key: ValueKey(mode), mode: mode),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A stream keeps flowing. While its values arrive, what state is the '
            'connection in?',
        'Stream terus mengalir. Selama nilai-nilainya berdatangan, dalam '
            'state apa koneksinya?',
      ),
      code: r'''
StreamBuilder<int>(
  stream: _breaths,
  builder: (context, snapshot) => switch (snapshot.connectionState) {
    ConnectionState.none => Text('No stream'),
    ConnectionState.waiting => Text('Settling in'),
    __ => Text('Breath ${snapshot.data}'),
    ConnectionState.done => Text('Rest'),
  },
)''',
      answers: ['ConnectionState.active'],
      explanation: const Tr(
        'A StreamBuilder is waiting until the first event, active while '
            'events keep coming, and done once the stream closes. Futures skip '
            'active, because a future has only one value to give.',
        'StreamBuilder berada di waiting sampai event pertama, active selama '
            'event terus berdatangan, dan done setelah stream ditutup. Future '
            'melewatkan active, karena future hanya punya satu nilai untuk '
            'diberikan.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html',
      mistakes: const [
        Mistake(
          ['ConnectionState.done'],
          Tr(
            'done comes only once the stream has closed; no breath follows it.',
            'done baru datang setelah stream ditutup; tidak ada napas setelah '
                'itu.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) =>
          PreviewCanvas(child: _Breaths(breathing: v[0] as ConnectionState)),
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: spin until the future is done, admit failure '
            'honestly, and otherwise show the quote',
        'Satukan semuanya: berputar sampai future selesai, akui kegagalan '
            'dengan jujur, dan selain itu tampilkan kutipannya',
      ),
      code: r'''
FutureBuilder<String>(
  future: _quote,
  builder: (context, snapshot) {
    if (snapshot.connectionState != __) {
      return const CircularProgressIndicator();
    }
    if (snapshot.__) return const Text('No quote today');
    return Text(snapshot.data!);
  },
)''',
      answers: ['ConnectionState.done', 'hasError'],
      capstone: true,
      hint: const Tr(
        'Try both buttons under the preview: one future succeeds, one fails.',
        'Coba kedua tombol di bawah pratinjau: satu future berhasil, satu '
            'gagal.',
      ),
      explanation: const Tr(
        'Checking for done first, then for an error, covers every outcome of '
            'a future: still on its way, failed, or fulfilled. This is the '
            'shape of most FutureBuilders in real apps.',
        'Memeriksa done terlebih dahulu, lalu error, mencakup setiap hasil '
            'dari sebuah future: masih dalam perjalanan, gagal, atau '
            'terpenuhi. Inilah bentuk sebagian besar FutureBuilder di aplikasi '
            'sungguhan.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/networking/fetch-data',
      mistakes: const [
        Mistake(
          ['ConnectionState.waiting', null],
          Tr(
            'That turns the logic inside out: the spinner appears once '
                'everything has arrived.',
            'Itu membalik logikanya: spinner justru muncul setelah semuanya '
                'tiba.',
          ),
        ),
        Mistake(
          [null, 'hasData'],
          Tr(
            'Then every quote that arrives is called a failure, and a real '
                'failure reaches data!.',
            'Maka setiap kutipan yang tiba disebut kegagalan, dan kegagalan '
                'yang sebenarnya justru sampai ke data!.',
          ),
        ),
      ],
      registry: _asyncRegistry,
      preview: (v) {
        final until = v[0] as ConnectionState;
        final getter = _boolGetter(v[1]);
        return PreviewCanvas(
          child: _Replay(
            offerFailure: true,
            builder: (future) => FutureBuilder<Object?>(
              future: future,
              builder: (context, s) => _stage(
                s.connectionState,
                s.connectionState != until
                    ? _spinner
                    : _ask(s, getter)
                    ? _text('No quote today')
                    : s.data == null
                    ? _nullCheck
                    : _text(s.data),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

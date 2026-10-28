import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

/// Callback names a learner may write, so a preview can wire them up.
const _callbacks = [
  'onTap',
  'onDoubleTap',
  'onLongPress',
  'onSecondaryTap',
  'onTapDown',
  'onTapUp',
  'onPressed',
];

final _gestureRegistry = flutterRegistry.merge(
  Registry(symbols: {for (final name in _callbacks) name: name}),
);

/// The GestureDetector callback slots, filled only where [names] ask.
GestureDetector _detector(
  Map<String, VoidCallback> on, {
  required Widget child,
  HitTestBehavior? behavior,
}) => GestureDetector(
  behavior: behavior,
  onTap: on['onTap'],
  onDoubleTap: on['onDoubleTap'],
  onLongPress: on['onLongPress'],
  onSecondaryTap: on['onSecondaryTap'],
  onTapDown: on['onTapDown'] == null ? null : (_) => on['onTapDown']!(),
  onTapUp: on['onTapUp'] == null ? null : (_) => on['onTapUp']!(),
  child: child,
);

String _callbackOf(Object? v) {
  final name = v as String;
  if (!_callbacks.contains(name)) throw ArgumentError.value(name);
  return name;
}

/// A stone that counts the gestures it hears through [callback].
class _GesturePad extends StatefulWidget {
  const _GesturePad({
    required this.callback,
    required this.label,
    required this.hint,
  });

  final String callback;
  final String label;
  final String hint;

  @override
  State<_GesturePad> createState() => _GesturePadState();
}

class _GesturePadState extends State<_GesturePad> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final heard = widget.callback == 'onPressed'
        ? <String, VoidCallback>{}
        : {widget.callback: () => setState(() => _count++)};
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _detector(
            heard,
            child: Container(
              width: 150,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kSky,
                borderRadius: BorderRadius.circular(44),
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${widget.callback}: $_count',
              key: ValueKey(_count),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Caption(widget.hint),
        ],
      ),
    );
  }
}

/// A tappable area in front of a listener that feels whatever passes
/// through: shows how [behavior] decides who is hit.
class _HitTestDemo extends StatefulWidget {
  const _HitTestDemo({required this.behavior});

  final HitTestBehavior behavior;

  @override
  State<_HitTestDemo> createState() => _HitTestDemoState();
}

class _HitTestDemoState extends State<_HitTestDemo> {
  int _here = 0;
  int _behind = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => setState(() => _behind++),
                  child: const SizedBox.expand(),
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: 200,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kSky, width: 2),
                  ),
                ),
              ),
              GestureDetector(
                behavior: widget.behavior,
                onTap: () => setState(() => _here++),
                child: const SizedBox(
                  width: 200,
                  height: 110,
                  child: Center(child: Text('Tap anywhere')),
                ),
              ),
            ],
          ),
        ),
        Text(
          'detector: $_here   ·   behind: $_behind',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// A button that may be enabled only once the box is ticked.
class _AgreeDemo extends StatefulWidget {
  const _AgreeDemo({required this.otherwise});

  /// What `onPressed` is when not agreed: null, or anything else.
  final Object? otherwise;

  @override
  State<_AgreeDemo> createState() => _AgreeDemoState();
}

class _AgreeDemoState extends State<_AgreeDemo> {
  bool _agreed = false;
  int _sent = 0;

  @override
  Widget build(BuildContext context) {
    void send() => setState(() => _sent++);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            title: const Text('I have read the scroll'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _agreed
                ? send
                : (widget.otherwise == null ? null : send),
            child: const Text('Send'),
          ),
          const SizedBox(height: 10),
          Caption('sent: $_sent'),
        ],
      ),
    );
  }
}

/// A photo card that a double tap loves and a long press keeps.
class _PhotoCard extends StatefulWidget {
  const _PhotoCard({required this.love, required this.keep});

  final String love;
  final String keep;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _liked = false;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final on = <String, VoidCallback>{};
    on[widget.keep] = () => setState(() => _saved = !_saved);
    on[widget.love] = () => setState(() => _liked = !_liked);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _detector(
            on,
            child: Container(
              width: 200,
              height: 130,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9CC7F0), Color(0xFFF3D9A4)],
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 28,
                    top: 22,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFFFF4D6),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 44,
                    child: Container(color: kSage.withValues(alpha: 0.75)),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: AnimatedScale(
                      scale: _saved ? 1 : 0.6,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        _saved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedScale(
                      scale: _liked ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: const Icon(Icons.favorite, color: kRose, size: 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Caption('double-tap to love · long-press to keep'),
        ],
      ),
    );
  }
}

final gestures = Category(
  id: 'gestures',
  title: const Tr('Gestures', 'Gestur'),
  intro: const Tr(
    'A touch is only a touch until a widget listens for it.',
    'Sentuhan hanyalah sentuhan sampai ada widget yang mendengarkannya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A GestureDetector draws nothing; it only listens. Let it hear a '
            'single tap, then tap the stone',
        'GestureDetector tidak menggambar apa pun; ia hanya mendengarkan. '
            'Biarkan ia mendengar satu ketukan, lalu ketuk batunya',
      ),
      code: r'''
GestureDetector(
  __: () => setState(() => _bows++),
  child: Box('Bow'),
)''',
      answers: ['onTap'],
      explanation: const Tr(
        'GestureDetector turns raw pointer events into gestures and calls '
            'onTap when a pointer goes down and comes up in about the same '
            'place. It paints nothing itself, so its child decides what is '
            'seen.',
        'GestureDetector mengubah event pointer mentah menjadi gestur dan '
            'memanggil onTap saat pointer ditekan lalu diangkat di tempat yang '
            'kurang lebih sama. Ia sendiri tidak menggambar apa pun, jadi '
            'child-nya yang menentukan apa yang terlihat.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/gestures/handling-taps',
      mistakes: const [
        Mistake(
          ['onPressed'],
          Tr(
            'onPressed belongs to buttons. A GestureDetector names the gesture '
                'itself.',
            'onPressed milik tombol. GestureDetector menyebut nama gesturnya '
                'langsung.',
          ),
        ),
        Mistake(
          ['onClick'],
          Tr(
            'Flutter speaks of taps, not clicks, even with a mouse.',
            'Flutter berbicara tentang tap, bukan klik, bahkan dengan mouse.',
          ),
        ),
      ],
      registry: _gestureRegistry,
      preview: (v) => PreviewCanvas(
        child: _GesturePad(
          callback: _callbackOf(v[0]),
          label: 'Bow',
          hint: 'tap the stone',
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Some intentions need patience. Respond only when the finger lingers',
        'Ada niat yang butuh kesabaran. Tanggapi hanya saat jari bertahan '
            'lama',
      ),
      code: r'''
GestureDetector(
  __: () => _showMenu(context),
  child: Box('Hold me'),
)''',
      answers: ['onLongPress'],
      explanation: const Tr(
        'onLongPress fires once the pointer has stayed down for '
            'kLongPressTimeout, 500 milliseconds, without moving much. A right '
            'click on the web or desktop is a different gesture: '
            'onSecondaryTap.',
        'onLongPress terpanggil setelah pointer ditekan selama '
            'kLongPressTimeout, 500 milidetik, tanpa banyak bergerak. Klik '
            'kanan di web atau desktop adalah gestur yang berbeda: '
            'onSecondaryTap.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/GestureDetector-class.html',
      mistakes: const [
        Mistake(
          ['onDoubleTap'],
          Tr(
            'That listens for two quick taps; we want one slow one.',
            'Itu mendengarkan dua ketukan cepat; kita ingin satu yang lambat.',
          ),
        ),
      ],
      registry: _gestureRegistry,
      preview: (v) => PreviewCanvas(
        child: _GesturePad(
          callback: _callbackOf(v[0]),
          label: 'Hold me',
          hint: 'press and hold',
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Whoever listens for a second tap must wait before trusting the '
            'first. How long does Flutter wait?',
        'Siapa pun yang menunggu ketukan kedua harus bersabar sebelum '
            'memercayai yang pertama. Berapa lama Flutter menunggu?',
      ),
      code: r'''
GestureDetector(
  onTap: _select,
  onDoubleTap: _like,
  child: const Photo(),
);
expect(kDoubleTapTimeout, __);''',
      answers: ['Duration(milliseconds: 300)'],
      verify: () => [kDoubleTapTimeout],
      explanation: const Tr(
        'With onDoubleTap listening, a single tap is only reported once no '
            'second tap has come within 300 milliseconds, so onTap feels '
            'slower. Listen for double taps only where they truly matter.',
        'Saat onDoubleTap ikut mendengarkan, satu ketukan baru dilaporkan '
            'setelah tidak ada ketukan kedua dalam 300 milidetik, sehingga '
            'onTap terasa lebih lambat. Dengarkan double tap hanya di tempat '
            'yang benar-benar membutuhkannya.',
      ),
      docs: 'https://api.flutter.dev/flutter/gestures/kDoubleTapTimeout-constant.html',
      mistakes: const [
        Mistake(
          ['Duration(milliseconds: 500)'],
          Tr(
            'That is how long a long press takes. A second tap must come '
                'sooner.',
            'Itu lamanya sebuah long press. Ketukan kedua harus datang lebih '
                'cepat.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Empty space is deaf by default. Let the whole area hear the tap, '
            'and keep it from passing through to what lies behind',
        'Ruang kosong pada dasarnya tuli. Biarkan seluruh area mendengar '
            'ketukan, dan jangan biarkan ketukan itu tembus ke apa yang ada '
            'di belakangnya',
      ),
      code: r'''
GestureDetector(
  behavior: __,
  onTap: () => setState(() => _taps++),
  child: SizedBox(
    width: 200,
    height: 110,
    child: Center(child: Text('Tap anywhere')),
  ),
)''',
      answers: ['HitTestBehavior.opaque'],
      hint: const Tr(
        'Tap the empty corners of the frame and watch both counters.',
        'Ketuk sudut-sudut kosong di dalam bingkai dan perhatikan kedua '
            'penghitung.',
      ),
      explanation: const Tr(
        'Hit testing asks each render box whether a point lands on it. With '
            'opaque the detector claims its whole area and hides what is '
            'behind; translucent claims it too but lets things behind receive '
            'the event as well.',
        'Hit testing menanyakan setiap render box apakah sebuah titik '
            'mengenainya. Dengan opaque, detector mengklaim seluruh areanya '
            'dan menutupi apa yang ada di belakang; translucent juga '
            'mengklaimnya, tetapi membiarkan yang di belakang ikut menerima '
            'event.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/HitTestBehavior.html',
      mistakes: const [
        Mistake(
          ['HitTestBehavior.deferToChild'],
          Tr(
            'That is the default: only what the child paints can be hit, and '
                'an empty SizedBox paints nothing.',
            'Itu nilai bawaan: hanya yang digambar child yang bisa terkena, dan '
                'SizedBox kosong tidak menggambar apa pun.',
          ),
        ),
        Mistake(
          ['HitTestBehavior.translucent'],
          Tr(
            'Now the empty space hears the tap, but it also passes through to '
                'what lies behind.',
            'Sekarang ruang kosong mendengar ketukan, tetapi ketukan itu juga '
                'tembus ke yang ada di belakang.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) =>
          PreviewCanvas(child: _HitTestDemo(behavior: v[0] as HitTestBehavior)),
    ),
    Koan(
      prompt: const Tr(
        'A GestureDetector hears, but leaves no trace. Let the tap ripple '
            'across the Material',
        'GestureDetector mendengar, tetapi tidak meninggalkan jejak. Biarkan '
            'ketukan beriak di atas Material',
      ),
      code: r'''
Material(
  color: Colors.teal,
  child: __(
    onTap: () {},
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('Ripple'),
    ),
  ),
)''',
      answers: ['InkWell'],
      explanation: const Tr(
        'InkWell is a tap detector that also paints Material ink: a splash '
            'spreading from the touch point, and a highlight. It draws on the '
            'nearest Material ancestor, so one must be there.',
        'InkWell adalah pendeteksi tap yang juga menggambar tinta Material: '
            'percikan yang menyebar dari titik sentuh, dan highlight. Ia '
            'menggambar di atas Material terdekat di atasnya, jadi Material '
            'itu harus ada.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/InkWell-class.html',
      mistakes: const [
        Mistake(
          ['GestureDetector'],
          Tr(
            'It hears the tap just as well, but it draws nothing, so the tap '
                'leaves no trace.',
            'Ia mendengar ketukan sama baiknya, tetapi tidak menggambar apa '
                'pun, jadi ketukan tidak meninggalkan jejak.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        const label = Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ripple',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
        final Widget inner = switch (v[0]) {
          const (InkWell) => InkWell(onTap: () {}, child: label),
          const (InkResponse) => InkResponse(onTap: () {}, child: label),
          const (GestureDetector) => GestureDetector(
            onTap: () {},
            child: label,
          ),
          _ => throw ArgumentError.value(v[0]),
        };
        return PreviewCanvas(
          child: Center(
            child: Material(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: inner,
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'The ripple is painted on the Material, beneath everything else. '
            'Let the teal be painted there too, so the ripple shows above it',
        'Riak digambar di atas Material, di bawah semua yang lain. Biarkan '
            'warna teal juga digambar di sana, agar riaknya tampak di '
            'atasnya',
      ),
      code: r'''
Material(
  child: InkWell(
    onTap: () {},
    child: __(
      color: Colors.teal,
      padding: EdgeInsets.all(24),
      child: Text('Ripple'),
    ),
  ),
)''',
      answers: ['Ink'],
      hint: const Tr(
        'Tap both previews and look for the ripple.',
        'Ketuk kedua pratinjau dan cari riaknya.',
      ),
      explanation: const Tr(
        'Ink paints its decoration onto the Material itself, beneath the '
            'splashes, instead of on top of them. Use it whenever a colored or '
            'image background sits inside an InkWell.',
        'Ink menggambar dekorasinya langsung di atas Material, di bawah '
            'percikan, bukan menutupinya. Gunakan Ink setiap kali latar '
            'berwarna atau bergambar berada di dalam InkWell.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/Ink-class.html',
      mistakes: const [
        Mistake(
          ['Container'],
          Tr(
            'A Container paints its color above the Material, so the ripple '
                'spreads underneath, out of sight.',
            'Container menggambar warnanya di atas Material, jadi riaknya '
                'menyebar di bawahnya, tidak terlihat.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        const label = Text(
          'Ripple',
          style: TextStyle(color: Colors.white, fontSize: 18),
        );
        const pad = EdgeInsets.all(24);
        final Widget inner = switch (v[0]) {
          const (Ink) => Ink(color: Colors.teal, padding: pad, child: label),
          const (Container) => Container(
            color: Colors.teal,
            padding: pad,
            child: label,
          ),
          _ => throw ArgumentError.value(v[0]),
        };
        return PreviewCanvas(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                splashColor: Colors.white54,
                highlightColor: Colors.white24,
                child: inner,
              ),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A button with nothing to do should say so. Until the box is ticked, '
            'disable Send',
        'Tombol yang tidak punya tugas sebaiknya menunjukkannya. Sampai '
            'kotaknya dicentang, nonaktifkan tombol Send',
      ),
      code: r'''
FilledButton(
  onPressed: _agreed ? _send : __,
  child: Text('Send'),
)''',
      answers: ['null'],
      explanation: const Tr(
        'A Material button whose onPressed (and onLongPress) is null is '
            'disabled: it greys out, ignores taps and tells assistive '
            'technology it is unavailable. There is no separate enabled flag.',
        'Tombol Material yang onPressed (dan onLongPress)-nya null menjadi '
            'nonaktif: warnanya memudar, ketukan diabaikan, dan teknologi '
            'bantu diberi tahu bahwa tombol itu tidak tersedia. Tidak ada '
            'flag enabled tersendiri.',
      ),
      docs: 'https://api.flutter.dev/flutter/material/ButtonStyleButton/onPressed.html',
      mistakes: const [
        Mistake(
          ['false'],
          Tr(
            'onPressed wants a function, or nothing at all. false is a value, '
                'not an absence.',
            'onPressed menginginkan sebuah fungsi, atau tidak ada sama sekali. '
                'false adalah sebuah nilai, bukan ketiadaan.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(child: _AgreeDemo(otherwise: v[0])),
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a double tap to love the photo, a long press to keep '
            'it',
        'Satukan semuanya: double tap untuk menyukai foto, long press untuk '
            'menyimpannya',
      ),
      code: r'''
GestureDetector(
  __: () => setState(() => _liked = !_liked),
  __: () => setState(() => _saved = !_saved),
  child: PhotoCard(liked: _liked, saved: _saved),
)''',
      answers: ['onDoubleTap', 'onLongPress'],
      capstone: true,
      explanation: const Tr(
        'One GestureDetector can listen for several gestures at once. They '
            'compete in the gesture arena, where each touch is won by exactly '
            'one recognizer, so a long press never also counts as a tap.',
        'Satu GestureDetector bisa mendengarkan beberapa gestur sekaligus. '
            'Mereka bersaing di gesture arena, tempat setiap sentuhan '
            'dimenangkan oleh tepat satu recognizer, sehingga long press '
            'tidak pernah sekaligus dihitung sebagai tap.',
      ),
      docs: 'https://docs.flutter.dev/ui/interactivity/gestures',
      mistakes: const [
        Mistake(
          ['onTap', null],
          Tr(
            'A single tap is too light for love here; this card wants two in a '
                'row.',
            'Satu ketukan terlalu ringan untuk rasa suka di sini; kartu ini '
                'ingin dua ketukan berturut-turut.',
          ),
        ),
        Mistake(
          ['onLongPress', 'onDoubleTap'],
          Tr(
            'The two gestures are swapped. Which one is quick and doubled, '
                'which one slow and patient?',
            'Kedua gestur tertukar. Mana yang cepat dan berulang, mana yang '
                'lambat dan sabar?',
          ),
        ),
      ],
      registry: _gestureRegistry,
      preview: (v) => PreviewCanvas(
        child: _PhotoCard(love: _callbackOf(v[0]), keep: _callbackOf(v[1])),
      ),
    ),
  ],
);

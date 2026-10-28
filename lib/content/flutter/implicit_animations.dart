import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

const _ms600 = Duration(milliseconds: 600);

/// A duration a preview can afford to wait for.
Duration _durationOf(Object? v) {
  final d = v as Duration;
  return d > const Duration(seconds: 5)
      ? const Duration(seconds: 5)
      : d.isNegative
      ? Duration.zero
      : d;
}

/// Flips a switch on every tap, and builds [builder] with its state.
class _Toggle extends StatefulWidget {
  const _Toggle({required this.builder});

  final Widget Function(bool on) builder;

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _on = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _on = !_on),
      child: Column(
        children: [
          Expanded(child: Center(child: widget.builder(_on))),
          const Caption('tap to change'),
        ],
      ),
    );
  }
}

/// A ball that travels across a track with [curve], once whenever the curve
/// changes and again on every tap, beside a plot of the curve.
class _CurveTrack extends StatefulWidget {
  const _CurveTrack({required this.curve});

  final Curve curve;

  @override
  State<_CurveTrack> createState() => _CurveTrackState();
}

class _CurveTrackState extends State<_CurveTrack> {
  bool _there = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _there = true);
    });
  }

  @override
  void didUpdateWidget(_CurveTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) _there = !_there;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _there = !_there),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(120, 70),
            painter: _CurvePlot(widget.curve),
          ),
          const SizedBox(height: 14),
          Frame(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 52,
                child: AnimatedAlign(
                  alignment: _there
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: const Duration(milliseconds: 900),
                  curve: widget.curve,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(radius: 18, backgroundColor: kRose),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Caption('tap to replay'),
        ],
      ),
    );
  }
}

class _CurvePlot extends CustomPainter {
  const _CurvePlot(this.curve);

  final Curve curve;

  @override
  void paint(Canvas canvas, Size size) {
    // Leave room above and below for curves that overshoot.
    final top = size.height * 0.15;
    final h = size.height * 0.7;
    final axis = Paint()
      ..color = kInk.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, top + h), Offset(size.width, top + h), axis);
    canvas.drawLine(Offset(0, top), Offset(size.width, top), axis);
    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final t = i / 60;
      final p = Offset(t * size.width, top + h - curve.transform(t) * h);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = kSky
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CurvePlot oldDelegate) => oldDelegate.curve != curve;
}

const _keyTypes = [ValueKey, ObjectKey, UniqueKey, GlobalKey, Key];

/// A big number that grows with each tap, keyed by [keyType].
class _SwitchCounter extends StatefulWidget {
  const _SwitchCounter({required this.keyType});

  final Object? keyType;

  @override
  State<_SwitchCounter> createState() => _SwitchCounterState();
}

class _SwitchCounterState extends State<_SwitchCounter> {
  int _count = 0;

  Key? _keyFor(int n) => switch (widget.keyType) {
    const (ValueKey) => ValueKey(n),
    const (ObjectKey) => ObjectKey(n),
    const (UniqueKey) => UniqueKey(),
    const (GlobalKey) => GlobalKey(),
    _ => Key('$n'),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _count++),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Text(
                  '$_count',
                  key: _keyFor(_count),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    color: kInk,
                  ),
                ),
              ),
            ),
          ),
          const Caption('tap to count'),
        ],
      ),
    );
  }
}

/// A switch whose track and knob are animated with the learner's values.
class _Switch extends StatefulWidget {
  const _Switch({
    required this.knobDuration,
    required this.curve,
    required this.onAlignment,
  });

  final Duration knobDuration;
  final Curve curve;
  final AlignmentGeometry onAlignment;

  @override
  State<_Switch> createState() => _SwitchState();
}

class _SwitchState extends State<_Switch> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _on = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 300);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _on = !_on),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOut,
                width: 120,
                height: 64,
                decoration: BoxDecoration(
                  color: _on ? Colors.teal : Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: AnimatedAlign(
                  duration: widget.knobDuration,
                  curve: widget.curve,
                  alignment: _on ? widget.onAlignment : Alignment.centerLeft,
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Caption('tap the switch'),
        ],
      ),
    );
  }
}

final implicitAnimations = Category(
  id: 'implicit-animations',
  title: const Tr('Implicit Animations', 'Animasi Implisit'),
  intro: const Tr(
    'Say where things should be, and let Flutter carry them there.',
    'Katakan di mana sesuatu seharusnya berada, dan biarkan Flutter '
        'membawanya ke sana.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A Container leaps to its new shape. Let this one glide there '
            'instead, then tap it',
        'Container melompat ke bentuk barunya. Biarkan yang ini meluncur ke '
            'sana, lalu ketuklah',
      ),
      code: r'''
__(
  duration: Duration(milliseconds: 600),
  width: _wide ? 200 : 80,
  height: 80,
  color: _wide ? Colors.teal : Colors.amber,
)''',
      answers: ['AnimatedContainer'],
      explanation: const Tr(
        'An implicitly animated widget remembers its previous values. When '
            'it is rebuilt with new ones, it animates from the old to the new '
            'over its duration, with no AnimationController of our own.',
        'Widget yang dianimasikan secara implisit mengingat nilai '
            'sebelumnya. Saat di-build ulang dengan nilai baru, ia '
            'beranimasi dari yang lama ke yang baru selama durasinya, tanpa '
            'AnimationController buatan kita sendiri.',
      ),
      docs: 'https://docs.flutter.dev/cookbook/animation/animated-container',
      mistakes: const [
        Mistake(
          ['Container'],
          Tr(
            'A Container jumps straight to its new size; it has no duration and '
                'no memory of where it was.',
            'Container langsung melompat ke ukuran barunya; ia tidak punya '
                'durasi dan tidak ingat di mana ia sebelumnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        if (type != AnimatedContainer && type != Container) {
          throw ArgumentError.value(type);
        }
        return PreviewCanvas(
          child: _Toggle(
            builder: (wide) => type == AnimatedContainer
                ? AnimatedContainer(
                    duration: _ms600,
                    curve: Curves.easeInOut,
                    width: wide ? 200 : 80,
                    height: 80,
                    color: wide ? Colors.teal : Colors.amber,
                  )
                : Container(
                    width: wide ? 200 : 80,
                    height: 80,
                    color: wide ? Colors.teal : Colors.amber,
                  ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'We never tell it to move; we only say where it should be. Ask for a '
            'width of 200, and watch it travel',
        'Kita tidak pernah menyuruhnya bergerak; kita hanya mengatakan di '
            'mana ia seharusnya berada. Minta lebar 200, dan lihat ia '
            'berjalan',
      ),
      code: r'''
AnimatedContainer(
  duration: Duration(milliseconds: 600),
  width: __,
  height: 80,
  color: Colors.teal,
)''',
      answers: ['200'],
      accept: (v) => isNum(v[0], 200),
      explanation: const Tr(
        'Every rebuild with a new width starts a fresh animation from the '
            'current width, even halfway through the last one. That is why '
            'typing 2, 20, 200 makes the box chase each value in turn.',
        'Setiap build ulang dengan lebar baru memulai animasi baru dari lebar '
            'saat ini, bahkan saat animasi sebelumnya baru setengah jalan. '
            'Itulah sebabnya mengetik 2, 20, 200 membuat kotak mengejar '
            'setiap nilai bergantian.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html',
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: AnimatedContainer(
            duration: _ms600,
            curve: Curves.easeInOut,
            width: px(v[0], max: 256),
            height: 80,
            color: Colors.teal,
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Haste is optional. Let the change unfold over two whole seconds',
        'Tergesa-gesa itu pilihan. Biarkan perubahan ini berlangsung selama '
            'dua detik penuh',
      ),
      code: r'''
AnimatedContainer(
  duration: __,
  width: _wide ? 200 : 80,
  height: 80,
  color: Colors.teal,
)''',
      answers: ['Duration(seconds: 2)'],
      explanation: const Tr(
        'duration is required on every implicitly animated widget, because '
            'Flutter has no default length for a change. Two seconds feels '
            'slow on purpose; most interface motion lasts a few hundred '
            'milliseconds.',
        'duration wajib diisi pada setiap widget animasi implisit, karena '
            'Flutter tidak punya panjang bawaan untuk sebuah perubahan. Dua '
            'detik sengaja terasa lambat; kebanyakan gerakan antarmuka hanya '
            'beberapa ratus milidetik.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget/duration.html',
      mistakes: const [
        Mistake(
          ['2'],
          Tr(
            'duration wants a Duration, not a bare number. Flutter never '
                'guesses the unit.',
            'duration menginginkan Duration, bukan angka polos. Flutter tidak '
                'pernah menebak satuannya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final d = _durationOf(v[0]);
        return PreviewCanvas(
          child: _Toggle(
            builder: (wide) => AnimatedContainer(
              duration: d,
              width: wide ? 200 : 80,
              height: 80,
              color: Colors.teal,
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'When no curve is named, how does the motion flow?',
        'Saat tidak ada curve yang disebut, bagaimana gerakannya mengalir?',
      ),
      code: r'''
final box = AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: 100,
);
expect(box.curve, __);''',
      answers: ['Curves.linear'],
      verify: () => [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 100,
        ).curve,
      ],
      explanation: const Tr(
        'Without a curve, the value changes by the same amount every frame. '
            'Things in the real world speed up and slow down, so a curve such '
            'as Curves.easeInOut usually feels more natural.',
        'Tanpa curve, nilainya berubah sebesar yang sama di setiap frame. '
            'Benda di dunia nyata bertambah cepat lalu melambat, jadi curve '
            'seperti Curves.easeInOut biasanya terasa lebih alami.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget/curve.html',
      mistakes: const [
        Mistake(
          ['Curves.easeInOut'],
          Tr(
            'A popular choice, but it has to be asked for.',
            'Pilihan yang populer, tetapi harus diminta secara khusus.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A curve gives motion its character. Let the ball land like a real '
            'ball, bouncing as it arrives',
        'Curve memberi gerakan karakternya. Biarkan bola mendarat seperti '
            'bola sungguhan, memantul saat tiba',
      ),
      code: r'''
AnimatedAlign(
  alignment: _there ? Alignment.centerRight : Alignment.centerLeft,
  duration: Duration(milliseconds: 900),
  curve: __,
  child: Ball(),
)''',
      answers: ['Curves.bounceOut'],
      hint: const Tr(
        'Browse the suggestions: each curve replays the motion.',
        'Telusuri saran yang ada: setiap curve memutar ulang gerakannya.',
      ),
      explanation: const Tr(
        'A curve maps the time passed to the progress made. "In" curves do '
            'their character at the start, "Out" curves at the end, so '
            'bounceOut bounces as it lands. Elastic and back curves overshoot '
            'the goal, which is why we cannot assume a value stays in range.',
        'Curve memetakan waktu yang berlalu ke kemajuan yang dicapai. Curve '
            '"In" menunjukkan karakternya di awal, curve "Out" di akhir, jadi '
            'bounceOut memantul saat mendarat. Curve elastic dan back '
            'melampaui tujuannya, itulah sebabnya kita tidak bisa menganggap '
            'nilainya selalu dalam rentang.',
      ),
      docs: 'https://api.flutter.dev/flutter/animation/Curves-class.html',
      mistakes: const [
        Mistake(
          ['Curves.bounceIn'],
          Tr(
            '"In" curves do their bouncing at the start. We want it as the ball '
                'arrives.',
            'Curve "In" memantul di awal. Kita ingin pantulannya saat bola '
                'tiba.',
          ),
        ),
        Mistake(
          ['Curves.elasticOut'],
          Tr(
            'Elastic overshoots and springs back like a rubber band; a ball '
                'bounces short of the ground and settles.',
            'Elastic melampaui tujuan lalu memegas kembali seperti karet; bola '
                'memantul tanpa menembus tanah lalu diam.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(child: _CurveTrack(curve: v[0] as Curve)),
    ),
    Koan(
      prompt: const Tr(
        'Name a new place and the stone glides there. Send A to the bottom '
            'right corner',
        'Sebut tempat baru dan batu itu meluncur ke sana. Kirim A ke sudut '
            'kanan bawah',
      ),
      code: r'''
AnimatedAlign(
  alignment: __,
  duration: Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  child: Box('A'),
)''',
      answers: ['Alignment.bottomRight'],
      explanation: const Tr(
        'AnimatedAlign is Align with a memory: each new alignment becomes a '
            'smooth path from the old one. Alignment(1, 1) names the same '
            'corner, and every alignment in between is a valid stop.',
        'AnimatedAlign adalah Align yang punya ingatan: setiap alignment '
            'baru menjadi lintasan mulus dari yang lama. Alignment(1, 1) '
            'menyebut sudut yang sama, dan setiap alignment di antaranya '
            'adalah perhentian yang sah.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/AnimatedAlign-class.html',
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Frame(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedAlign(
              alignment: v[0] as AlignmentGeometry,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: const Box('A', width: 56, height: 56),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Fade A until only a quarter of it remains',
        'Pudarkan A sampai hanya seperempatnya yang tersisa',
      ),
      code: r'''
AnimatedOpacity(
  opacity: __,
  duration: Duration(milliseconds: 500),
  child: Box('Mist'),
)''',
      answers: ['0.25'],
      accept: (v) => isNum(v[0], 0.25),
      explanation: const Tr(
        'AnimatedOpacity fades its child, which still takes its place in the '
            'layout and still receives taps, even at 0.0. Wrap it in '
            'IgnorePointer, or remove the child, when it should truly be gone.',
        'AnimatedOpacity memudarkan child-nya, yang tetap menempati '
            'tempatnya di layout dan tetap menerima ketukan, bahkan pada 0.0. '
            'Bungkus dengan IgnorePointer, atau hapus child-nya, saat ia '
            'benar-benar harus hilang.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html',
      mistakes: const [
        Mistake(
          ['25'],
          Tr(
            'Opacity is a fraction from 0.0 to 1.0, not a percentage.',
            'Opacity adalah pecahan dari 0.0 sampai 1.0, bukan persentase.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Frame(
            child: AnimatedOpacity(
              opacity: px(v[0], max: 1),
              duration: const Duration(milliseconds: 500),
              child: const Box('Mist', width: 140, height: 90, color: kSage),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'AnimatedSwitcher animates only when it believes the child is new. '
            'A Text is still a Text, so give each number a key of its own',
        'AnimatedSwitcher hanya beranimasi saat ia yakin child-nya baru. '
            'Text tetaplah Text, jadi beri setiap angka key-nya sendiri',
      ),
      code: r'''
AnimatedSwitcher(
  duration: Duration(milliseconds: 400),
  child: Text(
    '$_count',
    key: __(_count),
  ),
)''',
      answers: ['ValueKey'],
      explanation: const Tr(
        'AnimatedSwitcher compares the new child with the old one by type and '
            'key, as Flutter does when it updates elements. Without a key, '
            'Text("1") and Text("2") look like one widget being updated, so '
            'there is nothing to switch.',
        'AnimatedSwitcher membandingkan child baru dengan yang lama '
            'berdasarkan tipe dan key, seperti yang dilakukan Flutter saat '
            'memperbarui element. Tanpa key, Text("1") dan Text("2") tampak '
            'seperti satu widget yang diperbarui, jadi tidak ada yang perlu '
            'ditukar.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html',
      mistakes: const [
        Mistake(
          ['UniqueKey'],
          Tr(
            'A UniqueKey takes no value and is new on every build, so the '
                'switcher would animate even when the number stays the same.',
            'UniqueKey tidak menerima nilai dan selalu baru di setiap build, '
                'jadi switcher akan beranimasi bahkan saat angkanya tetap sama.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        if (!_keyTypes.contains(v[0])) throw ArgumentError.value(v[0]);
        return PreviewCanvas(child: _SwitchCounter(keyType: v[0]));
      },
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a switch whose knob glides in step with its track, '
            'easing in and out, and rests on the right when on',
        'Satukan semuanya: sebuah switch yang kenopnya meluncur seirama '
            'dengan lintasannya, melambat di awal dan akhir, dan berhenti di '
            'kanan saat menyala',
      ),
      code: r'''
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: 120,
  color: _on ? Colors.teal : Colors.grey,
  child: AnimatedAlign(
    duration: __,
    curve: __,
    alignment: _on ? __ : Alignment.centerLeft,
    child: Knob(),
  ),
)''',
      answers: [
        'Duration(milliseconds: 300)',
        'Curves.easeInOut',
        'Alignment.centerRight',
      ],
      capstone: true,
      explanation: const Tr(
        'Two implicit animations driven by the same state, with the same '
            'duration and curve, move as one. Each widget animates only its '
            'own properties, so they stay in step only because we gave them '
            'the same timing.',
        'Dua animasi implisit yang digerakkan oleh state yang sama, dengan '
            'durasi dan curve yang sama, bergerak sebagai satu kesatuan. '
            'Setiap widget hanya menganimasikan properti miliknya, jadi '
            'mereka seirama hanya karena kita memberi waktu yang sama.',
      ),
      docs: 'https://docs.flutter.dev/ui/animations/implicit-animations',
      mistakes: const [
        Mistake(
          [null, null, 'Alignment.centerLeft'],
          Tr(
            'Then on and off look the same; the knob never leaves home.',
            'Maka nyala dan mati terlihat sama; kenopnya tidak pernah '
                'meninggalkan tempatnya.',
          ),
        ),
        Mistake(
          [null, 'Curves.linear', null],
          Tr(
            'Linear motion is even and mechanical, and it no longer matches '
                'the track.',
            'Gerakan linear itu rata dan mekanis, dan tidak lagi seirama dengan '
                'lintasannya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _Switch(
          knobDuration: _durationOf(v[0]),
          curve: v[1] as Curve,
          onAlignment: v[2] as AlignmentGeometry,
        ),
      ),
    ),
  ],
);

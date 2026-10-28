import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

Widget _aligned(AlignmentGeometry alignment) => PreviewCanvas(
  child: Frame(
    child: Align(
      alignment: alignment,
      child: const Box('A', width: 64, height: 64),
    ),
  ),
);

final stack = Category(
  id: 'stack',
  title: const Tr('Stack and Align', 'Stack dan Align'),
  intro: const Tr(
    'A Stack lets widgets rest on top of one another.',
    'Stack membuat widget dapat bertumpuk satu di atas yang lain.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Leaves fall on a pond, one over another; the last one rests on top',
        'Daun-daun jatuh di atas kolam, satu menimpa yang lain; yang '
            'terakhir berada paling atas',
      ),
      code: r'''
__(
  children: [
    Box('A', width: 140, height: 96),
    Box('B', width: 72, height: 72),
  ],
)''',
      answers: ['Stack'],
      explanation: const Tr(
        'A Stack paints its children in order, so each later child lies on '
            'top of the ones before it. Children that are not positioned '
            'gather at the top left, and the Stack takes the size of the '
            'largest of them.',
        'Stack menggambar children-nya secara berurutan, sehingga setiap child '
            'yang datang belakangan berada di atas yang sebelumnya. Children '
            'yang tidak diberi posisi berkumpul di kiri atas, dan ukuran Stack '
            'mengikuti yang terbesar di antara mereka.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Stack-class.html',
      mistakes: const [
        Mistake(
          ['Row'],
          Tr(
            'A Row lays the leaves side by side, so neither rests on the '
                'other.',
            'Row meletakkan daun-daun itu berdampingan, sehingga tidak ada '
                'yang menimpa yang lain.',
          ),
        ),
        Mistake(
          ['Column'],
          Tr(
            'A Column lays the leaves one below the other, so neither rests '
                'on the other.',
            'Column meletakkan daun-daun itu satu di bawah yang lain, sehingga '
                'tidak ada yang menimpa yang lain.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        const children = [
          Box('A', width: 140, height: 96),
          Box('B', width: 72, height: 72),
        ];
        return PreviewCanvas(
          child: Center(
            child: type == Stack
                ? const Stack(children: children)
                : type == Row
                ? const Row(mainAxisSize: MainAxisSize.min, children: children)
                : type == Column
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Positioned measures from the edges of its Stack. Tuck B 16 pixels '
            'from the bottom and from the right',
        'Positioned mengukur dari tepi Stack-nya. Selipkan B 16 piksel dari '
            'bawah dan dari kanan',
      ),
      code: r'''
Stack(
  children: [
    Box('A'),
    Positioned(
      bottom: __,
      right: __,
      child: Box('B'),
    ),
  ],
)''',
      answers: ['16', '16'],
      accept: (v) => isNum(v[0], 16) && isNum(v[1], 16),
      explanation: const Tr(
        'Each edge of a Positioned is a distance inward from the same edge of '
            'the Stack: bottom: 16 means 16 above the Stack\'s bottom. The '
            'Stack takes its size from A, since positioned children never '
            'affect it.',
        'Setiap tepi Positioned adalah jarak ke dalam dari tepi Stack yang '
            'sama: bottom: 16 berarti 16 di atas sisi bawah Stack. Ukuran '
            'Stack ditentukan oleh A, karena children yang diberi posisi tidak '
            'pernah memengaruhinya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Positioned-class.html',
      mistakes: const [
        Mistake(
          ['-16', '-16'],
          Tr(
            'Negative distances push B outward, past the Stack\'s edges. '
                'Positioned measures inward.',
            'Jarak negatif mendorong B keluar, melewati tepi Stack. Positioned '
                'mengukur ke arah dalam.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final bottom = px(v[0], min: -40, max: 200);
        final right = px(v[1], min: -40, max: 240);
        return PreviewCanvas(
          child: Frame(
            child: Stack(
              children: [
                const Box('A'),
                Positioned(bottom: bottom, right: right, child: const Box('B')),
              ],
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Children that are not Positioned gather at the Stack\'s alignment. '
            'Make yours match the goal',
        'Children yang tidak Positioned berkumpul di alignment milik Stack. '
            'Samakan dengan tujuan',
      ),
      code: r'''
Stack(
  alignment: __,
  children: [
    Box('A', width: 160, height: 110),
    Box('B', width: 64, height: 64),
  ],
)''',
      answers: ['Alignment.bottomCenter'],
      hint: const Tr(
        'By default they gather at the top left.',
        'Secara default mereka berkumpul di kiri atas.',
      ),
      explanation: const Tr(
        'Stack.alignment places every child that is not positioned, and '
            'defaults to the top start corner. bottomCenter rests B on the '
            'bottom edge, halfway across, while A, being as large as the '
            'Stack, does not move.',
        'Stack.alignment menempatkan setiap child yang tidak diberi posisi, '
            'dan default-nya di sudut kiri atas. bottomCenter meletakkan B di '
            'tepi bawah, di tengah-tengah, sementara A yang seukuran Stack '
            'tidak bergeser.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Stack/alignment.html',
      mistakes: const [
        Mistake(
          ['Alignment.center'],
          Tr(
            'B floats in the very middle; in the goal it rests lower.',
            'B melayang tepat di tengah; pada tujuan, ia berada lebih rendah.',
          ),
        ),
        Mistake(
          ['Alignment.topCenter'],
          Tr(
            'B hangs from the top edge; in the goal it rests elsewhere.',
            'B menggantung di tepi atas; pada tujuan, ia berada di tempat '
                'lain.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Frame(
          child: Stack(
            alignment: v[0] as AlignmentGeometry,
            children: const [
              Box('A', width: 160, height: 110),
              Box('B', width: 64, height: 64),
            ],
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Positioned.fill is a Positioned that touches every edge',
        'Positioned.fill adalah Positioned yang menyentuh setiap tepi',
      ),
      code: r'''
final layer = Positioned.fill(child: Box('A'));
expect(layer.left, __);
expect(layer.width, __);''',
      answers: ['0.0', 'null'],
      verify: () {
        const layer = Positioned.fill(child: SizedBox());
        return [layer.left, layer.width];
      },
      accept: (v) => isNum(v[0], 0) && v[1] == null,
      hint: const Tr(
        'Its size comes from the edges, not from a width of its own.',
        'Ukurannya ditentukan oleh tepi-tepinya, bukan oleh width miliknya '
            'sendiri.',
      ),
      explanation: const Tr(
        'Positioned.fill pins left, top, right and bottom to 0.0 and leaves '
            'width and height null, so the child is stretched between the '
            'edges to cover the Stack exactly. It is the usual way to lay a '
            'background or an overlay across a whole Stack.',
        'Positioned.fill mengunci left, top, right, dan bottom di 0.0 serta '
            'membiarkan width dan height bernilai null, sehingga child-nya '
            'direntangkan di antara tepi-tepi itu untuk menutupi Stack dengan '
            'pas. Ini cara umum untuk memasang latar atau lapisan di atas '
            'seluruh Stack.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Positioned/Positioned.fill.html',
      mistakes: const [
        Mistake(
          [null, 'double.infinity'],
          Tr(
            'Filling comes from pinning the edges, not from an endless width.',
            'Memenuhi Stack berasal dari mengunci tepi-tepinya, bukan dari '
                'width yang tak terbatas.',
          ),
        ),
        Mistake(
          ['null', null],
          Tr(
            'A Positioned that touches every edge must say where those edges '
                'are.',
            'Positioned yang menyentuh setiap tepi harus menyatakan di mana '
                'tepi-tepi itu.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Align places its child at a point within its space. Send A to the '
            'top right',
        'Align menempatkan child-nya di satu titik dalam ruangnya. Kirim A '
            'ke kanan atas',
      ),
      code: r'''
Align(
  alignment: __,
  child: Box('A'),
)''',
      answers: ['Alignment.topRight'],
      explanation: const Tr(
        'Align takes all the space it is given, then places its child at one '
            'point within it. Alignment.topRight is Alignment(1, -1): the far '
            'right and the very top.',
        'Align mengambil seluruh ruang yang diberikan, lalu menempatkan '
            'child-nya di satu titik di dalamnya. Alignment.topRight sama '
            'dengan Alignment(1, -1): paling kanan dan paling atas.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Align-class.html',
      registry: flutterRegistry,
      preview: (v) => _aligned(v[0] as AlignmentGeometry),
    ),
    Koan(
      prompt: const Tr(
        'Alignment(0, 0) is the center; -1 and 1 are the edges. Make yours '
            'match the goal',
        'Alignment(0, 0) adalah titik tengah; -1 dan 1 adalah tepinya. '
            'Samakan dengan tujuan',
      ),
      code: r'''
Align(
  alignment: Alignment(__, __),
  child: Box('A'),
)''',
      answers: ['-1', '1'],
      accept: (v) => isNum(v[0], -1) && isNum(v[1], 1),
      hint: const Tr(
        'x runs from left to right, y from top to bottom.',
        'x bergerak dari kiri ke kanan, y dari atas ke bawah.',
      ),
      explanation: const Tr(
        'Alignment maps -1 to 1 across the box on each axis, and y grows '
            'downward as it does everywhere on screen. So Alignment(-1, 1) is '
            'the bottom left, the same as Alignment.bottomLeft; values like 0.5 '
            'land in between.',
        'Alignment memetakan -1 hingga 1 di sepanjang kotak pada setiap axis, '
            'dan y bertambah ke arah bawah seperti di mana pun di layar. Jadi '
            'Alignment(-1, 1) adalah kiri bawah, sama dengan '
            'Alignment.bottomLeft; nilai seperti 0.5 berada di antaranya.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/Alignment-class.html',
      mistakes: const [
        Mistake(
          ['-1', '-1'],
          Tr(
            'On screen, y grows downward, so -1 is the top edge, not the '
                'bottom.',
            'Di layar, y bertambah ke arah bawah, jadi -1 adalah tepi atas, '
                'bukan bawah.',
          ),
        ),
        Mistake(
          ['1', '1'],
          Tr(
            'x runs from left to right, so 1 is the right edge.',
            'x bergerak dari kiri ke kanan, jadi 1 adalah tepi kanan.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _aligned(
        Alignment(px(v[0], min: -1, max: 1), px(v[1], min: -1, max: 1)),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Center is only an Align that has made up its mind',
        'Center hanyalah Align yang sudah menetapkan pilihannya',
      ),
      code: r'''
expect(const Center().alignment, __);''',
      answers: ['Alignment.center'],
      verify: () => [const Center().alignment],
      explanation: const Tr(
        'Center is a subclass of Align whose alignment is always '
            'Alignment.center. Like Align, it also has widthFactor and '
            'heightFactor, to size itself relative to its child instead of '
            'filling its parent.',
        'Center adalah subclass dari Align yang alignment-nya selalu '
            'Alignment.center. Seperti Align, ia juga punya widthFactor dan '
            'heightFactor, untuk menentukan ukurannya relatif terhadap child, '
            'alih-alih memenuhi parent-nya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Center-class.html',
      mistakes: const [
        Mistake(
          ['null'],
          Tr(
            'Center has already made up its mind; its alignment is never left '
                'empty.',
            'Center sudah menetapkan pilihannya; alignment-nya tidak pernah '
                'dibiarkan kosong.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A Stack may ask its children to fill all the space it has. Let A '
            'fill the Stack',
        'Stack bisa meminta children-nya mengisi seluruh ruang yang ia '
            'punya. Biarkan A memenuhi Stack',
      ),
      code: r'''
Stack(
  fit: __,
  children: [
    Box('A'),
    Positioned(right: 12, bottom: 12, child: Box('B')),
  ],
)''',
      answers: ['StackFit.expand'],
      explanation: const Tr(
        'StackFit.expand gives every child that is not positioned tight '
            'constraints as large as the Stack can be, so A fills it. The '
            'default, loose, lets them be smaller, and passthrough hands down '
            'the parent\'s constraints unchanged.',
        'StackFit.expand memberi setiap child yang tidak diberi posisi '
            'constraint pasti sebesar ukuran maksimal Stack, sehingga A '
            'memenuhinya. Default-nya, loose, membolehkan mereka lebih kecil, '
            'dan passthrough meneruskan constraint dari parent apa adanya.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/StackFit.html',
      mistakes: const [
        Mistake(
          ['StackFit.loose'],
          Tr(
            'That is the default, which lets A keep its own size.',
            'Itu nilai default, yang membiarkan A tetap dengan ukurannya '
                'sendiri.',
          ),
        ),
        Mistake(
          ['StackFit.passthrough'],
          Tr(
            'passthrough hands A its parent\'s constraints unchanged; here they '
                'are loose, so A keeps its own size.',
            'passthrough meneruskan constraint dari parent kepada A apa '
                'adanya; di sini constraint itu longgar, sehingga A tetap '
                'dengan ukurannya sendiri.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220, maxHeight: 150),
            child: Frame(
              child: Stack(
                fit: v[0] as StackFit,
                children: const [
                  Box('A'),
                  Positioned(right: 12, bottom: 12, child: Box('B')),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'By default a Stack trims whatever reaches past its edges. Let B '
            'spill over',
        'Secara default, Stack memangkas apa pun yang melewati tepinya. '
            'Biarkan B meluap keluar',
      ),
      code: r'''
Stack(
  clipBehavior: __,
  children: [
    Box('A', width: 160, height: 100),
    Positioned(top: -20, right: -20, child: Box('B')),
  ],
)''',
      answers: ['Clip.none'],
      explanation: const Tr(
        'A Stack clips with Clip.hardEdge by default; Clip.none lets children '
            'paint past its edges. Taps outside the Stack\'s bounds still will '
            'not reach the overflowing part, because hit testing stops at the '
            'edges.',
        'Secara default, Stack memotong dengan Clip.hardEdge; Clip.none '
            'membiarkan children digambar melewati tepinya. Ketukan di luar '
            'batas Stack tetap tidak akan mencapai bagian yang meluap, karena '
            'hit testing berhenti di tepinya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Stack/clipBehavior.html',
      mistakes: const [
        Mistake(
          ['Clip.hardEdge'],
          Tr(
            'That is the default, which trims B at the edges.',
            'Itu nilai default, yang memangkas B di tepinya.',
          ),
        ),
        Mistake(
          ['Clip.antiAlias'],
          Tr(
            'antiAlias still clips, only with smoother edges.',
            'antiAlias tetap memotong, hanya dengan tepi yang lebih halus.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Stack(
            clipBehavior: v[0] as Clip,
            children: const [
              Box('A', width: 160, height: 100),
              Positioned(top: -20, right: -20, child: Box('B')),
            ],
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'A badge rests on the avatar\'s top right corner, spilling 8 pixels '
            'past each edge. Let it spill',
        'Sebuah badge bertengger di sudut kanan atas avatar, meluap 8 piksel '
            'melewati setiap tepinya. Biarkan ia meluap',
      ),
      code: r'''
Stack(
  clipBehavior: __,
  children: [
    Avatar(size: 88),
    Positioned(
      top: __,
      right: __,
      child: Badge('3'),
    ),
  ],
)''',
      answers: ['Clip.none', '-8', '-8'],
      accept: (v) => v[0] == Clip.none && isNum(v[1], -8) && isNum(v[2], -8),
      capstone: true,
      explanation: const Tr(
        'The avatar sets the Stack\'s size and the badge, painted last, lies '
            'on top. Positioned measures inward from the edges, so -8 moves the '
            'badge 8 pixels outward, and only Clip.none lets that part show '
            'instead of being trimmed.',
        'Avatar menentukan ukuran Stack, dan badge yang digambar terakhir '
            'berada di atasnya. Positioned mengukur ke dalam dari tepi, '
            'sehingga -8 menggeser badge 8 piksel ke luar, dan hanya Clip.none '
            'yang membiarkan bagian itu tampak alih-alih terpangkas.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Positioned-class.html',
      mistakes: const [
        Mistake(
          [null, '8', '8'],
          Tr(
            'Positive distances move the badge inward, onto the avatar, '
                'rather than past its edges.',
            'Jarak positif menggeser badge ke dalam, ke atas avatar, bukan '
                'melewati tepinya.',
          ),
        ),
        Mistake(
          ['Clip.hardEdge', null, null],
          Tr(
            'That is the default, which trims the badge where it spills past '
                'the Stack.',
            'Itu nilai default, yang memangkas badge di bagian yang meluap '
                'melewati Stack.',
          ),
        ),
        Mistake(
          ['Clip.antiAlias', null, null],
          Tr(
            'antiAlias still clips, only with smoother edges.',
            'antiAlias tetap memotong, hanya dengan tepi yang lebih halus.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final clip = v[0] as Clip;
        final top = px(v[1], min: -40, max: 60);
        final right = px(v[2], min: -40, max: 60);
        return PreviewCanvas(
          child: Center(
            child: Stack(
              clipBehavior: clip,
              children: [
                const Avatar(size: 88),
                Positioned(top: top, right: right, child: const _Badge('3')),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

/// A small round count, like an unread badge.
class _Badge extends StatelessWidget {
  const _Badge(this.count);

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kRose,
        shape: BoxShape.circle,
        border: Border.all(color: kMist, width: 3),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

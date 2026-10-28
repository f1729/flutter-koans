import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'preview_kit_more.dart';
import 'registry.dart';

/// A tight parent of [width] × [height], drawn as a frame.
Widget _tightParent(double width, double height, Widget child) => PreviewCanvas(
  child: Center(
    child: Frame(
      child: SizedBox(width: width, height: height, child: child),
    ),
  ),
);

final constraints = Category(
  id: 'constraints',
  title: const Tr('Constraints', 'Constraints'),
  intro: const Tr(
    'Constraints go down, sizes go up, and the parent sets the position.',
    'Constraints turun ke bawah, ukuran naik ke atas, dan parent yang '
        'menentukan posisi.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A tight constraint leaves no choice: the smallest allowed size and '
            'the largest are one and the same',
        'Constraint yang ketat tidak memberi pilihan: ukuran terkecil dan '
            'terbesar yang diizinkan adalah sama',
      ),
      code: r'''
final c = BoxConstraints.tight(Size(100, 50));
expect(c.minWidth, __);
expect(c.maxWidth, __);
expect(c.isTight, __);''',
      answers: ['100.0', '100.0', 'true'],
      verify: () {
        final c = BoxConstraints.tight(const Size(100, 50));
        return [c.minWidth, c.maxWidth, c.isTight];
      },
      accept: (v) => isNum(v[0], 100) && isNum(v[1], 100) && v[2] == true,
      explanation: const Tr(
        'BoxConstraints.tight sets the minimum and the maximum to the same '
            'size, so the child has exactly one legal size. The screen hands '
            'the root widget tight constraints, which is why the first widget '
            'always fills it.',
        'BoxConstraints.tight membuat nilai minimum dan maksimum sama besar, '
            'sehingga child hanya punya satu ukuran yang sah. Layar memberi '
            'widget root constraints yang ketat, itulah sebabnya widget '
            'pertama selalu memenuhi layar.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/BoxConstraints/BoxConstraints.tight.html',
      mistakes: const [
        Mistake(
          ['0', null, null],
          Tr(
            'That would leave room to be smaller. Does a tight constraint '
                'leave any room at all?',
            'Itu memberi ruang untuk menjadi lebih kecil. Apakah constraint '
                'yang ketat menyisakan ruang sama sekali?',
          ),
        ),
        Mistake(
          [null, null, 'false'],
          Tr(
            'isTight asks whether minimum and maximum meet, on both axes. '
                'Compare them.',
            'isTight menanyakan apakah minimum dan maksimum bertemu, di kedua '
                'sumbu. Bandingkan keduanya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A loose constraint sets only a ceiling; the floor is always zero',
        'Constraint yang longgar hanya menetapkan batas atas; batas bawahnya '
            'selalu nol',
      ),
      code: r'''
final c = BoxConstraints.loose(Size(100, 50));
expect(c.minWidth, __);
expect(c.maxHeight, __);
expect(c.isTight, __);''',
      answers: ['0.0', '50.0', 'false'],
      verify: () {
        final c = BoxConstraints.loose(const Size(100, 50));
        return [c.minWidth, c.maxHeight, c.isTight];
      },
      accept: (v) => isNum(v[0], 0) && isNum(v[1], 50) && v[2] == false,
      explanation: const Tr(
        'Loose constraints start at zero, so the child may take any size up '
            'to the maximum. Center and Align loosen what they receive before '
            'passing it on, which is why their child can be smaller than '
            'they are.',
        'Constraints yang longgar dimulai dari nol, jadi child boleh '
            'mengambil ukuran berapa pun sampai batas maksimum. Center dan '
            'Align melonggarkan apa yang mereka terima sebelum meneruskannya, '
            'itulah sebabnya child mereka bisa lebih kecil daripada mereka.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/BoxConstraints/BoxConstraints.loose.html',
      mistakes: const [
        Mistake(
          ['100', null, null],
          Tr(
            'That is the ceiling. Loose means the child may also be smaller, '
                'all the way down.',
            'Itu batas atasnya. Longgar berarti child juga boleh lebih kecil, '
                'sampai serendah-rendahnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Constraints that say nothing allow everything, from zero to beyond '
            'any number',
        'Constraints yang tidak menyebut apa pun mengizinkan segalanya, dari '
            'nol sampai melampaui angka berapa pun',
      ),
      code: r'''
const c = BoxConstraints();
expect(c.minWidth, __);
expect(c.maxWidth, __);
expect(c.hasBoundedWidth, __);''',
      answers: ['0.0', 'double.infinity', 'false'],
      verify: () {
        const c = BoxConstraints();
        return [c.minWidth, c.maxWidth, c.hasBoundedWidth];
      },
      accept: (v) => isNum(v[0], 0) && v[1] == double.infinity && v[2] == false,
      explanation: const Tr(
        'An unbounded maximum is what a Row offers its children along its '
            'width, and what a vertical list offers along its height. A child '
            'that wants to fill an infinite space cannot pick a size, which '
            'is where the "unbounded" layout errors come from.',
        'Batas maksimum yang tak terbatas adalah apa yang diberikan Row '
            'kepada child-nya ke arah lebar, dan yang diberikan list vertikal '
            'ke arah tinggi. Child yang ingin memenuhi ruang tak terbatas '
            'tidak bisa memilih ukuran, dan dari situlah error layout '
            '"unbounded" berasal.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/BoxConstraints/BoxConstraints.html',
      mistakes: const [
        Mistake(
          [null, '0', null],
          Tr(
            'A maximum of zero would allow only nothing. Saying nothing puts no '
                'ceiling at all.',
            'Batas maksimum nol hanya mengizinkan ketiadaan. Tidak menyebut apa '
                'pun berarti tidak ada batas atas sama sekali.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Sizes go up, but only within the limits that came down. What size '
            'may a child that wants 300 by 20 take?',
        'Ukuran naik ke atas, tetapi hanya di dalam batas yang turun dari '
            'atas. Ukuran berapa yang boleh diambil child yang menginginkan '
            '300 kali 20?',
      ),
      code: r'''
const c = BoxConstraints(
  minWidth: 50,
  maxWidth: 200,
  minHeight: 40,
  maxHeight: 100,
);
expect(c.constrain(Size(300, 20)), __);''',
      answers: ['Size(200, 40)'],
      verify: () {
        const c = BoxConstraints(
          minWidth: 50,
          maxWidth: 200,
          minHeight: 40,
          maxHeight: 100,
        );
        return [c.constrain(const Size(300, 20))];
      },
      explanation: const Tr(
        'constrain clamps each side into its range: 300 falls to the '
            'maximum width and 20 rises to the minimum height. Every render '
            'box must choose a size that satisfies its constraints, so a '
            "child's wish is always clamped like this.",
        'constrain menjepit setiap sisi ke dalam rentangnya: 300 turun ke '
            'lebar maksimum dan 20 naik ke tinggi minimum. Setiap render box '
            'harus memilih ukuran yang memenuhi constraints-nya, jadi '
            'keinginan child selalu dijepit seperti ini.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/BoxConstraints/constrain.html',
      mistakes: const [
        Mistake(
          ['Size(300, 20)'],
          Tr(
            'That is what the child wished for, but the limits from above '
                'always win.',
            'Itu yang diinginkan child, tetapi batas dari atas selalu menang.',
          ),
        ),
        Mistake(
          ['Size(200, 20)'],
          Tr(
            'The width is right. Is a height of 20 really allowed here?',
            'Lebarnya sudah benar. Apakah tinggi 20 benar-benar diizinkan di '
                'sini?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Constraints go down. Hand A a constraint so tight that it must be '
            'exactly 160 by 80',
        'Constraints turun ke bawah. Berikan A constraint yang begitu ketat '
            'sehingga ukurannya harus tepat 160 kali 80',
      ),
      code: r'''
Center(
  child: ConstrainedBox(
    constraints: __,
    child: Box('A'),
  ),
)''',
      answers: ['BoxConstraints.tight(Size(160, 80))'],
      explanation: const Tr(
        'ConstrainedBox adds its constraints to the ones from above, and '
            'Center passed down loose ones, so A receives exactly 160 × 80 '
            'and has no say. BoxConstraints.tightFor(width: 160, height: 80) '
            'is the same constraint, written another way.',
        'ConstrainedBox menambahkan constraints-nya pada constraints dari '
            'atas, dan Center meneruskan constraints yang longgar, sehingga A '
            'menerima tepat 160 × 80 dan tidak bisa menawar. '
            'BoxConstraints.tightFor(width: 160, height: 80) adalah '
            'constraint yang sama, hanya ditulis dengan cara lain.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html',
      mistakes: const [
        Mistake(
          ['BoxConstraints.loose(Size(160, 80))'],
          Tr(
            'A loose constraint is only a ceiling. A is still free to stay as '
                'small as its label.',
            'Constraint yang longgar hanyalah batas atas. A masih bebas tetap '
                'sekecil label-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final c = v[0] as BoxConstraints;
        if (!c.isNormalized) throw ArgumentError.value(c);
        return PreviewCanvas(
          child: Center(
            child: ConstrainedBox(
              constraints: c,
              child: const ConstraintsBox('A'),
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A SizedBox only asks; it keeps its wish within what its parent '
            'allows. Inside a tight parent, what is left of the wish?',
        'SizedBox hanya meminta; ia menjaga keinginannya tetap di dalam apa '
            'yang diizinkan parent. Di dalam parent yang ketat, apa yang '
            'tersisa dari keinginan itu?',
      ),
      code: r'''
final parent = BoxConstraints.tight(Size(240, 160));
const wish = BoxConstraints.tightFor(width: 60, height: 60);
expect(wish.enforce(parent).biggest, __);''',
      answers: ['Size(240, 160)'],
      verify: () {
        final parent = BoxConstraints.tight(const Size(240, 160));
        const wish = BoxConstraints.tightFor(width: 60, height: 60);
        return [wish.enforce(parent).biggest];
      },
      hint: const Tr(
        'enforce clamps every limit of the wish into the range of the parent.',
        'enforce menjepit setiap batas dari keinginan ke dalam rentang '
            'parent.',
      ),
      explanation: const Tr(
        'A SizedBox is a ConstrainedBox with tight constraints, and it '
            'enforces them within its parent\'s. A tight parent leaves no '
            'range, so 240 × 160 wins. That is why SizedBox(width: 60) '
            'directly inside a screen-sized parent still fills the screen.',
        'SizedBox adalah ConstrainedBox dengan constraints yang ketat, dan ia '
            'menerapkannya di dalam constraints milik parent. Parent yang '
            'ketat tidak menyisakan rentang, jadi 240 × 160 yang menang. '
            'Itulah sebabnya SizedBox(width: 60) yang langsung berada di '
            'dalam parent seukuran layar tetap memenuhi layar.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/BoxConstraints/enforce.html',
      mistakes: const [
        Mistake(
          ['Size(60, 60)'],
          Tr(
            'The child may only wish within the range its parent allows. How '
                'much range does a tight parent leave?',
            'Child hanya boleh berharap di dalam rentang yang diizinkan parent. '
                'Berapa banyak rentang yang disisakan parent yang ketat?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'The tight parent swallowed the wish. Place something between them '
            'that loosens the grip, so A can be its own 60 by 60',
        'Parent yang ketat menelan keinginan itu. Letakkan sesuatu di antara '
            'keduanya yang melonggarkan genggaman, agar A bisa menjadi 60 '
            'kali 60 miliknya sendiri',
      ),
      code: r'''
SizedBox(
  width: 240,
  height: 160,
  child: __(
    child: SizedBox(
      width: 60,
      height: 60,
      child: Box('A'),
    ),
  ),
)''',
      answers: ['Center'],
      accept: (v) =>
          v[0] == Center || v[0] == Align || v[0] == UnconstrainedBox,
      explanation: const Tr(
        'Center takes the tight 240 × 160 itself, then offers its child loose '
            'constraints from zero up to that size, so 60 × 60 now fits. '
            'Then, as the parent, Center sets the position: a child never '
            'chooses where it sits.',
        'Center mengambil 240 × 160 yang ketat untuk dirinya sendiri, lalu '
            'memberi child-nya constraints longgar dari nol sampai ukuran '
            'itu, sehingga 60 × 60 kini muat. Kemudian, sebagai parent, '
            'Center yang menentukan posisinya: child tidak pernah memilih di '
            'mana ia berada.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout/constraints',
      mistakes: const [
        Mistake(
          ['Container'],
          Tr(
            'A Container with nothing but a child passes the tight constraints '
                'straight through.',
            'Container yang hanya berisi child meneruskan constraints yang '
                'ketat begitu saja.',
          ),
        ),
        Mistake(
          ['SizedBox'],
          Tr(
            'A SizedBox without a size passes the tight constraints straight '
                'through.',
            'SizedBox tanpa ukuran meneruskan constraints yang ketat begitu '
                'saja.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        const a = SizedBox(width: 60, height: 60, child: ConstraintsBox('A'));
        final Widget middle = switch (type) {
          const (Center) => const Center(child: a),
          const (Align) => const Align(child: a),
          const (UnconstrainedBox) => const UnconstrainedBox(child: a),
          const (Container) => Container(child: a),
          _ => a,
        };
        return _tightParent(240, 160, middle);
      },
    ),
    Koan(
      prompt: const Tr(
        'UnconstrainedBox sets its child free, yet may keep one axis bound. '
            'Let A keep the full height but choose its own width',
        'UnconstrainedBox membebaskan child-nya, tetapi bisa tetap mengikat '
            'satu sumbu. Biarkan A tetap setinggi penuh tetapi memilih '
            'lebarnya sendiri',
      ),
      code: r'''
SizedBox(
  width: 240,
  height: 120,
  child: UnconstrainedBox(
    constrainedAxis: __,
    child: Box('A', width: 80),
  ),
)''',
      answers: ['Axis.vertical'],
      explanation: const Tr(
        'UnconstrainedBox lays its child out with no constraints at all, '
            'except along constrainedAxis, then aligns it within itself. A '
            'free child that grows larger than the box overflows, and debug '
            'builds paint the familiar yellow and black stripes.',
        'UnconstrainedBox menata child-nya tanpa constraints sama sekali, '
            'kecuali di sepanjang constrainedAxis, lalu meratakannya di dalam '
            'dirinya. Child bebas yang tumbuh melebihi box akan overflow, dan '
            'build debug menggambar garis-garis kuning hitam yang sudah '
            'akrab itu.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/UnconstrainedBox/constrainedAxis.html',
      mistakes: const [
        Mistake(
          ['Axis.horizontal'],
          Tr(
            'The axis we name is the one that stays constrained. Which one '
                'should stay full?',
            'Sumbu yang kita sebut adalah sumbu yang tetap dibatasi. Sumbu mana '
                'yang harus tetap penuh?',
          ),
        ),
        Mistake(
          ['null'],
          Tr(
            'With no axis named, A is free on both, and its height shrinks to '
                'its label.',
            'Tanpa sumbu yang disebut, A bebas di keduanya, dan tingginya '
                'menyusut sebesar label-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _tightParent(
        240,
        120,
        UnconstrainedBox(
          constrainedAxis: v[0] as Axis?,
          child: const SizedBox(width: 80, child: ConstraintsBox('A')),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Gather it all: a card never wider than 200, whose button stretches '
            'across all the width it is given',
        'Satukan semuanya: kartu yang tidak pernah lebih lebar dari 200, '
            'dengan tombol yang membentang selebar ruang yang diberikan',
      ),
      code: r'''
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: __),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Constraints go down, sizes go up'),
        SizedBox(width: __, child: FilledButton(onPressed: () {}, child: Text('Begin'))),
      ],
    ),
  ),
)''',
      answers: ['200', 'double.infinity'],
      accept: (v) => isNum(v[0], 200) && v[1] == double.infinity,
      capstone: true,
      explanation: const Tr(
        'The card passes down a ceiling of 200, and the SizedBox asks for '
            'infinity, which its constraints clamp to all 200. '
            'width: double.infinity is the idiom for "as wide as my parent '
            'allows"; it only breaks when the parent allows infinity too.',
        'Kartu meneruskan batas atas 200, dan SizedBox meminta tak hingga, '
            'yang dijepit oleh constraints-nya menjadi 200 penuh. '
            'width: double.infinity adalah idiom untuk "selebar yang '
            'diizinkan parent"; ia baru bermasalah ketika parent juga '
            'mengizinkan tak hingga.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout/constraints',
      mistakes: const [
        Mistake(
          [null, 'null'],
          Tr(
            'Without a width, the SizedBox lets the button choose, and a button '
                'chooses to hug its label.',
            'Tanpa lebar, SizedBox membiarkan tombol memilih, dan tombol memilih '
                'untuk memeluk label-nya.',
          ),
        ),
        Mistake(
          ['double.infinity', null],
          Tr(
            'With no ceiling, the card stretches to the edges of its parent.',
            'Tanpa batas atas, kartu membentang sampai ke tepi parent-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final maxWidth = px(v[0], max: double.infinity);
        final button = v[1] == null ? null : px(v[1], max: double.infinity);
        return PreviewCanvas(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kFrame),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Constraints go down, sizes go up',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: button,
                        child: FilledButton(
                          onPressed: () {},
                          child: const Text('Begin'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

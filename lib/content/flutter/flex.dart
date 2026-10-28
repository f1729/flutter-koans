import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

const _h = 56.0;

Widget _row(List<Widget> children) => PreviewCanvas(
  child: Center(child: Row(spacing: 8, children: children)),
);

final flex = Category(
  id: 'flex',
  title: const Tr('Flex', 'Flex'),
  intro: const Tr(
    'Expanded, Flexible and Spacer share out the space that is left.',
    'Expanded, Flexible, dan Spacer membagi ruang yang tersisa.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'A and C know their size; let B fill whatever space remains',
        'A dan C tahu ukurannya; biarkan B mengisi ruang yang tersisa',
      ),
      code: r'''
Row(
  children: [
    Box('A', width: 56),
    __(child: Box('B')),
    Box('C', width: 56),
  ],
)''',
      answers: ['Expanded'],
      explanation: const Tr(
        'A Row first lays out the children with a fixed size, then shares the '
            'space left over among its flexible children. Expanded makes B '
            'fill all of that space; a Flexible would let B stay at its '
            'natural size.',
        'Row lebih dulu menata children yang ukurannya tetap, lalu membagi '
            'sisa ruangnya kepada children yang fleksibel. Expanded membuat B '
            'mengisi seluruh ruang itu; Flexible akan membiarkan B tetap '
            'seukuran aslinya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Expanded-class.html',
      mistakes: const [
        Mistake(
          ['Flexible'],
          Tr(
            'Flexible offers B the space but lets it stay smaller, so B only '
                'hugs its label.',
            'Flexible menawarkan ruang kepada B tetapi membiarkannya lebih '
                'kecil, sehingga B hanya memeluk labelnya.',
          ),
        ),
        Mistake(
          ['Spacer'],
          Tr(
            'A Spacer is empty space and takes no child; here B itself must '
                'grow.',
            'Spacer adalah ruang kosong dan tidak menerima child; di sini B '
                'sendiri yang harus tumbuh.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        const b = Box('B', height: _h);
        return _row([
          const Box('A', width: 56, height: _h),
          if (type == Expanded)
            const Expanded(child: b)
          else if (type == Flexible)
            const Flexible(child: b)
          else
            b,
          const Box('C', width: 56, height: _h),
        ]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Flex factors divide the space like shares of rice. Give A twice '
            'as much as B',
        'Flex factor membagi ruang seperti membagi nasi. Beri A dua kali '
            'lipat bagian B',
      ),
      code: r'''
Row(
  children: [
    Expanded(flex: __, child: Box('A')),
    Expanded(child: Box('B')),
  ],
)''',
      answers: ['2'],
      explanation: const Tr(
        'The free space is split in proportion to the flex factors: A gets 2 '
            'parts out of 2 + 1 = 3, B gets 1. Every Expanded starts with a '
            'flex of 1, which is why B needs none.',
        'Ruang kosong dibagi sebanding dengan flex factor-nya: A mendapat 2 '
            'bagian dari 2 + 1 = 3, B mendapat 1. Setiap Expanded memiliki '
            'flex 1 secara default, karena itu B tidak perlu menuliskannya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Flexible/flex.html',
      mistakes: const [
        Mistake(
          ['1'],
          Tr(
            'That is the default flex, so A and B would share equally.',
            'Itu nilai flex default, sehingga A dan B akan berbagi sama rata.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final a = flexOf(v[0]);
        return _row([
          Expanded(
            flex: a,
            child: const Box('A', height: _h),
          ),
          const Expanded(child: Box('B', height: _h)),
        ]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Flex is a ratio, not a size. Make B three times as wide as A',
        'Flex adalah perbandingan, bukan ukuran. Buat B tiga kali lebih '
            'lebar daripada A',
      ),
      code: r'''
Row(
  children: [
    Expanded(flex: __, child: Box('A')),
    Expanded(flex: __, child: Box('B')),
  ],
)''',
      answers: ['1', '3'],
      accept: (v) =>
          v[0] is int &&
          v[1] is int &&
          (v[0] as int) > 0 &&
          v[1] == (v[0] as int) * 3,
      hint: const Tr(
        'Many pairs of numbers share the same ratio.',
        'Banyak pasangan angka yang memiliki perbandingan sama.',
      ),
      explanation: const Tr(
        'Only the ratio matters: flex 1 and 3, or 2 and 6, both give B three '
            'quarters of the free space. Flex factors are ints, and the '
            'actual widths depend on how much room the Row has.',
        'Yang penting hanya perbandingannya: flex 1 dan 3, atau 2 dan 6, '
            'sama-sama memberi B tiga perempat ruang kosong. Flex factor '
            'berupa int, dan lebar sebenarnya bergantung pada ruang yang '
            'dimiliki Row.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Flexible/flex.html',
      mistakes: const [
        Mistake(
          ['3', '1'],
          Tr(
            'That makes A the wide one. Which child should get more shares?',
            'Itu membuat A menjadi yang lebar. Child mana yang seharusnya '
                'mendapat bagian lebih banyak?',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final a = flexOf(v[0], max: 30);
        final b = flexOf(v[1], max: 30);
        return _row([
          Expanded(
            flex: a,
            child: const Box('A', height: _h),
          ),
          Expanded(
            flex: b,
            child: const Box('B', height: _h),
          ),
        ]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Expanded is only a Flexible that insists on filling its share. '
            'Make this Flexible insist too',
        'Expanded hanyalah Flexible yang bersikeras mengisi bagiannya. '
            'Buat Flexible ini ikut bersikeras',
      ),
      code: r'''
Row(
  children: [
    Box('A', width: 56),
    Flexible(fit: __, child: Box('B')),
    Box('C', width: 56),
  ],
)''',
      answers: ['FlexFit.tight'],
      explanation: const Tr(
        'fit decides how a flexible child uses its share. FlexFit.tight forces '
            'it to fill the share exactly, while FlexFit.loose, the default '
            'for Flexible, lets it be smaller. Flexible with a tight fit is '
            'exactly what Expanded is.',
        'fit menentukan bagaimana child fleksibel memakai bagiannya. '
            'FlexFit.tight memaksanya mengisi bagian itu sepenuhnya, sedangkan '
            'FlexFit.loose, default untuk Flexible, membolehkannya lebih kecil. '
            'Flexible dengan fit tight sama persis dengan Expanded.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/FlexFit.html',
      mistakes: const [
        Mistake(
          ['FlexFit.loose'],
          Tr(
            'loose is what Flexible already does: B may stay at its natural '
                'size.',
            'loose adalah perilaku bawaan Flexible: B boleh tetap seukuran '
                'aslinya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _row([
        const Box('A', width: 56, height: _h),
        Flexible(
          fit: v[0] as FlexFit,
          child: const Box('B', height: _h),
        ),
        const Box('C', width: 56, height: _h),
      ]),
    ),
    Koan(
      prompt: const Tr(
        'A Flexible may take less than it is offered; an Expanded may not',
        'Flexible boleh mengambil kurang dari yang ditawarkan; Expanded '
            'tidak boleh',
      ),
      code: r'''
expect(const Flexible(child: Text('a')).fit, __);
expect(const Expanded(child: Text('b')).fit, __);''',
      answers: ['FlexFit.loose', 'FlexFit.tight'],
      explanation: const Tr(
        'Expanded is a subclass of Flexible whose fit is always '
            'FlexFit.tight. A plain Flexible defaults to FlexFit.loose, so its '
            'child may be as small as it likes, up to its share.',
        'Expanded adalah subclass dari Flexible yang fit-nya selalu '
            'FlexFit.tight. Flexible biasa memakai FlexFit.loose secara '
            'default, sehingga child-nya boleh sekecil apa pun, hingga sebesar '
            'bagiannya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Flexible-class.html',
      mistakes: const [
        Mistake(
          ['FlexFit.tight', 'FlexFit.loose'],
          Tr(
            'Swapped. Which of the two may take less than it is offered?',
            'Tertukar. Mana dari keduanya yang boleh mengambil kurang dari yang '
                'ditawarkan?',
          ),
        ),
        Mistake(
          ['FlexFit.tight', 'FlexFit.tight'],
          Tr(
            'Both are flexible children, but only one of them insists on '
                'filling its share.',
            'Keduanya child yang fleksibel, tetapi hanya satu yang bersikeras '
                'mengisi bagiannya.',
          ),
        ),
      ],
      verify: () => [
        const Flexible(child: Text('a')).fit,
        const Expanded(child: Text('b')).fit,
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Sometimes the best thing to place between two stones is emptiness '
            'that grows',
        'Terkadang yang paling tepat di antara dua batu adalah kekosongan '
            'yang bisa tumbuh',
      ),
      code: r'''
Row(
  children: [
    Box('A'),
    __(),
    Box('B'),
  ],
)''',
      answers: ['Spacer'],
      hint: const Tr(
        'It is a widget with no child, made only of flex.',
        'Ini adalah widget tanpa child, yang isinya hanya flex.',
      ),
      explanation: const Tr(
        'A Spacer is an Expanded around an empty box: it soaks up the free '
            'space and pushes B to the far edge. Unlike '
            'MainAxisAlignment.spaceBetween, it can sit between exactly the '
            'children we choose.',
        'Spacer adalah Expanded yang membungkus kotak kosong: ia menyerap '
            'ruang kosong dan mendorong B ke tepi seberang. Berbeda dengan '
            'MainAxisAlignment.spaceBetween, Spacer bisa diletakkan tepat di '
            'antara children yang kita pilih.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Spacer-class.html',
      mistakes: const [
        Mistake(
          ['Expanded'],
          Tr(
            'Expanded needs a child to fill its share; this widget has none.',
            'Expanded membutuhkan child untuk mengisi bagiannya; widget ini '
                'tidak punya child.',
          ),
        ),
        Mistake(
          ['Flexible'],
          Tr(
            'Flexible needs a child, and lets it stay small; this widget has no '
                'child at all.',
            'Flexible membutuhkan child, dan membiarkannya tetap kecil; widget '
                'ini sama sekali tidak punya child.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _row([
        const Box('A', height: _h),
        if (v[0] == Spacer) const Spacer(),
        const Box('B', height: _h),
      ]),
    ),
    Koan(
      prompt: const Tr(
        'Empty space has flex too. Make the gap after A twice the gap '
            'after B',
        'Ruang kosong pun punya flex. Buat jarak setelah A dua kali lipat '
            'jarak setelah B',
      ),
      code: r'''
Row(
  children: [
    Box('A'),
    Spacer(flex: __),
    Box('B'),
    Spacer(),
    Box('C'),
  ],
)''',
      answers: ['2'],
      explanation: const Tr(
        'A Spacer takes part in the flex sharing like any Expanded: with flex '
            '2 against the default 1, the first gap gets two thirds of the free '
            'space and the second gets one third.',
        'Spacer ikut membagi flex seperti Expanded lainnya: dengan flex 2 '
            'melawan nilai default 1, jarak pertama mendapat dua pertiga ruang '
            'kosong dan jarak kedua mendapat sepertiganya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Spacer-class.html',
      mistakes: const [
        Mistake(
          ['1'],
          Tr(
            'That is the default flex, so both gaps would be the same.',
            'Itu nilai flex default, sehingga kedua jarak akan sama besar.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final gap = flexOf(v[0]);
        return _row([
          const Box('A', height: _h),
          Spacer(flex: gap),
          const Box('B', height: _h),
          const Spacer(),
          const Box('C', height: _h),
        ]);
      },
    ),
    Koan(
      prompt: const Tr(
        'Expanded grows along the main axis of its parent. Let B grow '
            'downward',
        'Expanded tumbuh mengikuti main axis parent-nya. Biarkan B tumbuh '
            'ke bawah',
      ),
      code: r'''
__(
  children: [
    Box('A', width: 80, height: 40),
    Expanded(child: Box('B', width: 80)),
    Box('C', width: 80, height: 40),
  ],
)''',
      answers: ['Column'],
      explanation: const Tr(
        'Expanded always grows along the main axis of the Row, Column or Flex '
            'that holds it. In a Column that axis is vertical, so B takes the '
            'height left over. Expanded must be a direct child of one of '
            'them.',
        'Expanded selalu tumbuh mengikuti main axis dari Row, Column, atau '
            'Flex yang memegangnya. Pada Column, axis itu vertikal, sehingga B '
            'mengambil sisa tingginya. Expanded harus menjadi child langsung '
            'dari salah satunya.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Expanded-class.html',
      mistakes: const [
        Mistake(
          ['Row'],
          Tr(
            'In a Row, B grows sideways, along the Row\'s main axis.',
            'Pada Row, B tumbuh ke samping, mengikuti main axis milik Row.',
          ),
        ),
        Mistake(
          ['Stack'],
          Tr(
            'A Stack has no main axis to share out, so Expanded cannot live '
                'inside it.',
            'Stack tidak punya main axis untuk dibagi, sehingga Expanded tidak '
                'bisa berada di dalamnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        const children = [
          Box('A', width: 80, height: 40),
          Expanded(child: Box('B', width: 80)),
          Box('C', width: 80, height: 40),
        ];
        return PreviewCanvas(
          child: type == Row
              ? const Row(spacing: 8, children: children)
              : type == Column
              ? const Column(spacing: 8, children: children)
              : const SizedBox.shrink(),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'A song has played 2:40 of its 4:00. Let the played part fill two '
            'thirds of the bar, and let empty space push the two times apart',
        'Sebuah lagu sudah diputar 2:40 dari 4:00. Biarkan bagian yang sudah '
            'diputar mengisi dua pertiga bar, dan biarkan ruang kosong '
            'mendorong kedua waktu itu berjauhan',
      ),
      code: r'''
Column(
  children: [
    Row(children: [
      __(flex: __, child: Bar(Colors.teal)),
      Expanded(child: Bar(Colors.grey)),
    ]),
    Row(children: [Text('2:40'), __(), Text('4:00')]),
  ],
)''',
      answers: ['Expanded', '2', 'Spacer'],
      capstone: true,
      explanation: const Tr(
        'Both Expanded children share the bar\'s width in the ratio 2 : 1, '
            'so the played part is two thirds of it, just as 2:40 is two '
            'thirds of 4:00. In the second Row a Spacer takes all the free '
            'space, pushing the times to the edges. Flex factors, Expanded and '
            'Spacer are all the same idea: sharing what is left.',
        'Kedua Expanded membagi lebar bar dengan perbandingan 2 : 1, sehingga '
            'bagian yang sudah diputar adalah dua pertiganya, sama seperti 2:40 '
            'adalah dua pertiga dari 4:00. Di Row kedua, Spacer mengambil '
            'seluruh ruang kosong dan mendorong kedua waktu ke tepi. Flex '
            'factor, Expanded, dan Spacer berasal dari gagasan yang sama: '
            'membagi ruang yang tersisa.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Expanded-class.html',
      mistakes: const [
        Mistake(
          ['Flexible', null, null],
          Tr(
            'A Flexible lets the played part stay as small as it likes, so it '
                'shrinks to a stub instead of filling its share.',
            'Flexible membiarkan bagian yang sudah diputar sekecil apa pun, '
                'sehingga ia menyusut menjadi potongan kecil alih-alih mengisi '
                'bagiannya.',
          ),
        ),
        Mistake(
          [null, '1', null],
          Tr(
            'With equal shares the bar shows half the song, 2:00 rather than '
                '2:40.',
            'Dengan bagian yang sama, bar hanya menunjukkan setengah lagu, '
                '2:00 dan bukan 2:40.',
          ),
        ),
        Mistake(
          [null, null, 'Expanded'],
          Tr(
            'Expanded needs a child to fill its share; between the times we '
                'want nothing but growing emptiness.',
            'Expanded membutuhkan child untuk mengisi bagiannya; di antara '
                'kedua waktu itu kita hanya ingin kekosongan yang tumbuh.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final share = flexOf(v[1]);
        final played = switch (v[0]) {
          const (Expanded) => Expanded(flex: share, child: _bar(kSage)),
          const (Flexible) => Flexible(flex: share, child: _bar(kSage)),
          const (Spacer) => Spacer(flex: share),
          _ => throw ArgumentError.value(v[0]),
        };
        final time = TextStyle(
          fontSize: 12,
          color: kInk.withValues(alpha: 0.6),
        );
        return PreviewCanvas(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.music_note, color: kSage),
                      Text(
                        'Frog Song',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 2,
                    children: [
                      played,
                      Expanded(child: _bar(kFrame)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('2:40', style: time),
                      if (v[2] == Spacer) const Spacer(),
                      Text('4:00', style: time),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ],
);

/// A segment of a progress bar, as small as it may be unless told to fill.
Widget _bar(Color color) => Container(
  height: 10,
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(5),
  ),
  child: const SizedBox(width: 10),
);

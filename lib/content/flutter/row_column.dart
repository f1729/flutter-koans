import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

List<Widget> _abc({double height = 48}) => [
  Box('A', width: 56, height: height),
  Box('B', width: 56, height: height),
  Box('C', width: 56, height: height),
];

List<Widget> _tall() => const [
  Box('A', width: 56, height: 40),
  Box('B', width: 56, height: 80),
  Box('C', width: 56, height: 60),
];

List<Widget> _wide() => const [
  Box('A', width: 72, height: 40),
  Box('B', width: 128, height: 40),
  Box('C', width: 100, height: 40),
];

Widget _flex(
  Axis direction, {
  MainAxisAlignment main = MainAxisAlignment.start,
  CrossAxisAlignment cross = CrossAxisAlignment.center,
  MainAxisSize size = MainAxisSize.max,
  required List<Widget> children,
}) => Flex(
  direction: direction,
  mainAxisAlignment: main,
  crossAxisAlignment: cross,
  mainAxisSize: size,
  textBaseline: TextBaseline.alphabetic,
  children: children,
);

final rowColumn = Category(
  id: 'row-column',
  title: const Tr('Rows and Columns', 'Row dan Column'),
  intro: const Tr(
    'Rows and Columns line their children up along a single axis.',
    'Row dan Column menyusun children-nya berderet di sepanjang satu axis.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Stones laid side by side form a path. Make yours match the goal',
        'Batu yang disusun berdampingan membentuk jalan setapak. Samakan '
            'dengan tujuan',
      ),
      code: r'''
__(
  children: [
    Box('A'),
    Box('B'),
    Box('C'),
  ],
)''',
      answers: ['Row'],
      explanation: const Tr(
        'A Row lays its children out horizontally, one after another, along '
            'its main axis. A Column does the same vertically, and a Stack '
            'piles them on top of each other.',
        'Row menyusun children-nya secara horizontal, satu demi satu, di '
            'sepanjang main axis-nya. Column melakukan hal yang sama secara '
            'vertikal, sedangkan Stack menumpuknya satu di atas yang lain.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Row-class.html',
      mistakes: const [
        Mistake(
          ['Column'],
          Tr(
            'A Column lines its children up from top to bottom; this path '
                'runs from side to side.',
            'Column menyusun children-nya dari atas ke bawah; jalan setapak '
                'ini membentang dari sisi ke sisi.',
          ),
        ),
        Mistake(
          ['Stack'],
          Tr(
            'A Stack lays its children on top of one another, so the stones '
                'cover each other.',
            'Stack meletakkan children-nya saling menimpa, sehingga batu-batu '
                'itu saling menutupi.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final type = v[0];
        return PreviewCanvas(
          child: type == Row
              ? Row(children: _abc())
              : type == Column
              ? Column(children: _abc())
              : type == Stack
              ? Stack(children: _abc())
              : const SizedBox.shrink(),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'The main axis of a Row runs from where the sun rises to where it '
            'sets. Gather the stones in the middle of the path',
        'Main axis sebuah Row membentang dari tempat matahari terbit hingga '
            'tempat ia terbenam. Kumpulkan batu-batu itu di tengah jalan',
      ),
      code: r'''
Row(
  mainAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['MainAxisAlignment.center'],
      explanation: const Tr(
        'mainAxisAlignment decides where the free space along the main axis '
            'goes. center splits it equally before and after the group, so '
            'the children stay together in the middle. There is free space '
            'only because a Row takes all the width it is offered.',
        'mainAxisAlignment menentukan ke mana ruang kosong di sepanjang main '
            'axis diletakkan. center membaginya sama rata sebelum dan sesudah '
            'kelompok itu, sehingga children tetap berkumpul di tengah. Ruang '
            'kosong itu ada karena Row mengambil seluruh lebar yang '
            'ditawarkan.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/MainAxisAlignment.html',
      mistakes: const [
        Mistake(
          ['CrossAxisAlignment.center'],
          Tr(
            'That is the cross axis, which runs vertically in a Row. The path '
                'runs along the main axis.',
            'Itu cross axis, yang pada Row arahnya vertikal. Jalan setapak '
                'ini mengikuti main axis.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.spaceEvenly'],
          Tr(
            'spaceEvenly also puts space between the stones; here they should '
                'stay close together.',
            'spaceEvenly juga memberi jarak di antara batu-batu; di sini '
                'mereka harus tetap berdekatan.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.spaceAround'],
          Tr(
            'spaceAround also puts space between the stones; here they should '
                'stay close together.',
            'spaceAround juga memberi jarak di antara batu-batu; di sini '
                'mereka harus tetap berdekatan.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.horizontal,
          main: v[0] as MainAxisAlignment,
          children: _abc(),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Let the outer stones touch the edges, and the space gather between '
            'them',
        'Biarkan batu terluar menyentuh tepi, dan ruang kosong berkumpul di '
            'antaranya',
      ),
      code: r'''
Row(
  mainAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['MainAxisAlignment.spaceBetween'],
      hint: const Tr(
        'Of the three "space" alignments, only one leaves nothing at the '
            'edges.',
        'Dari tiga alignment berawalan "space", hanya satu yang tidak '
            'menyisakan ruang di tepi.',
      ),
      explanation: const Tr(
        'spaceBetween puts all the free space between the children, so the '
            'first and last touch the edges. spaceAround gives each child '
            'half a gap on each side, and spaceEvenly makes every gap equal, '
            'edges included.',
        'spaceBetween menaruh semua ruang kosong di antara children, sehingga '
            'yang pertama dan terakhir menyentuh tepi. spaceAround memberi '
            'setiap child setengah jarak di tiap sisinya, dan spaceEvenly '
            'membuat semua jarak sama besar, termasuk di tepi.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/MainAxisAlignment.html',
      mistakes: const [
        Mistake(
          ['MainAxisAlignment.spaceAround'],
          Tr(
            'spaceAround still leaves half a gap at each edge, so the outer '
                'stones never touch them.',
            'spaceAround masih menyisakan setengah jarak di setiap tepi, '
                'sehingga batu terluar tidak pernah menyentuhnya.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.spaceEvenly'],
          Tr(
            'spaceEvenly puts a full gap at the edges too, so the outer stones '
                'never touch them.',
            'spaceEvenly juga memberi jarak penuh di tepi, sehingga batu '
                'terluar tidak pernah menyentuhnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.horizontal,
          main: v[0] as MainAxisAlignment,
          children: _abc(),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'The main axis of a Column falls like rain, from top to bottom. Let '
            'the stones settle at the bottom',
        'Main axis sebuah Column jatuh seperti hujan, dari atas ke bawah. '
            'Biarkan batu-batu itu mengendap di dasar',
      ),
      code: r'''
Column(
  mainAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['MainAxisAlignment.end'],
      explanation: const Tr(
        'A Column\'s main axis is vertical, so start is the top and end is the '
            'bottom. The same names work for both Row and Column because they '
            'follow the axis, not the screen.',
        'Main axis sebuah Column arahnya vertikal, jadi start adalah atas dan '
            'end adalah bawah. Nama yang sama berlaku untuk Row maupun Column '
            'karena mengikuti axis, bukan layar.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Column-class.html',
      mistakes: const [
        Mistake(
          ['CrossAxisAlignment.end'],
          Tr(
            'A Column\'s cross axis runs from left to right, so that would push '
                'the stones sideways, not down.',
            'Cross axis sebuah Column membentang dari kiri ke kanan, jadi itu '
                'akan mendorong batu ke samping, bukan ke bawah.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.start'],
          Tr(
            'start is where a Column begins, at the top, which is where it '
                'already puts its children.',
            'start adalah awal sebuah Column, yaitu di atas, tempat ia memang '
                'sudah meletakkan children-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.vertical,
          main: v[0] as MainAxisAlignment,
          children: _abc(height: 34),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'The cross axis runs across the main one; in a Row, it is vertical. '
            'Make yours match the goal',
        'Cross axis melintang terhadap main axis; pada Row, arahnya '
            'vertikal. Samakan dengan tujuan',
      ),
      code: r'''
Row(
  crossAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['CrossAxisAlignment.end'],
      explanation: const Tr(
        'A Row is as tall as its tallest child, and crossAxisAlignment places '
            'each child within that height. end lines up their bottoms; start '
            'would line up their tops.',
        'Tinggi sebuah Row sama dengan child tertingginya, dan '
            'crossAxisAlignment menempatkan setiap child di dalam tinggi '
            'tersebut. end menyejajarkan sisi bawahnya; start akan '
            'menyejajarkan sisi atasnya.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/CrossAxisAlignment.html',
      mistakes: const [
        Mistake(
          ['CrossAxisAlignment.start'],
          Tr(
            'start is the top of a Row\'s cross axis. Look at which edge the '
                'goal\'s stones share.',
            'start adalah bagian atas cross axis sebuah Row. Lihat tepi mana '
                'yang sama-sama disentuh batu-batu pada tujuan.',
          ),
        ),
        Mistake(
          ['CrossAxisAlignment.stretch'],
          Tr(
            'stretch makes every child as tall as the Row, ignoring its own '
                'height.',
            'stretch membuat setiap child setinggi Row, mengabaikan tingginya '
                'sendiri.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.horizontal,
          main: MainAxisAlignment.spaceEvenly,
          cross: v[0] as CrossAxisAlignment,
          children: _tall(),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'To stretch is to reach both shores of the cross axis',
        'Meregang berarti menjangkau kedua tepi cross axis',
      ),
      code: r'''
Column(
  crossAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['CrossAxisAlignment.stretch'],
      explanation: const Tr(
        'stretch gives every child a tight width equal to the Column\'s, '
            'overriding the widths they asked for. It is the usual way to make '
            'full-width buttons, and it needs a Column with a bounded width.',
        'stretch memberi setiap child lebar yang pasti, sama dengan lebar '
            'Column, mengabaikan lebar yang mereka minta. Ini cara umum untuk '
            'membuat tombol selebar layar, dan Column-nya harus punya lebar '
            'yang terbatas.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/CrossAxisAlignment.html',
      mistakes: const [
        Mistake(
          ['CrossAxisAlignment.center'],
          Tr(
            'That is where a Column already puts its children, each keeping '
                'its own width.',
            'Di situlah Column memang meletakkan children-nya, masing-masing '
                'dengan lebarnya sendiri.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.vertical,
          main: MainAxisAlignment.spaceEvenly,
          cross: v[0] as CrossAxisAlignment,
          children: _wide(),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'A Row is greedy by nature and takes all the width it is offered. '
            'Teach it to take only what it needs',
        'Row pada dasarnya serakah dan mengambil seluruh lebar yang '
            'ditawarkan. Ajari ia mengambil secukupnya saja',
      ),
      code: r'''
Row(
  mainAxisSize: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['MainAxisSize.min'],
      explanation: const Tr(
        'With the default MainAxisSize.max, a Row fills its parent\'s width; '
            'with min, it shrinks to fit its children, so the frame hugs them. '
            'With no free space left, mainAxisAlignment has nothing to '
            'distribute.',
        'Dengan default MainAxisSize.max, Row memenuhi lebar parent-nya; '
            'dengan min, ia menyusut seukuran children-nya, sehingga bingkainya '
            'memeluk mereka. Tanpa ruang kosong, mainAxisAlignment tidak punya '
            'apa pun untuk dibagi.',
      ),
      docs: 'https://api.flutter.dev/flutter/rendering/MainAxisSize.html',
      mistakes: const [
        Mistake(
          ['MainAxisSize.max'],
          Tr(
            'That is the greedy default, which takes all the width there is.',
            'Itu default yang serakah, yang mengambil seluruh lebar yang ada.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Frame(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _flex(
                Axis.horizontal,
                size: v[0] as MainAxisSize,
                main: MainAxisAlignment.center,
                children: _abc(),
              ),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'In a Column the axes trade places. Rest the stones in the middle, '
            'leaning to the left',
        'Pada Column, kedua axis bertukar tempat. Letakkan batu-batu itu di '
            'tengah, condong ke kiri',
      ),
      code: r'''
Column(
  mainAxisAlignment: __,
  crossAxisAlignment: __,
  children: [Box('A'), Box('B'), Box('C')],
)''',
      answers: ['MainAxisAlignment.center', 'CrossAxisAlignment.start'],
      hint: const Tr(
        'Up and down is the main axis of a Column; left and right is its '
            'cross axis.',
        'Atas-bawah adalah main axis sebuah Column; kiri-kanan adalah cross '
            'axis-nya.',
      ),
      explanation: const Tr(
        'In a Column, mainAxisAlignment works vertically and '
            'crossAxisAlignment horizontally: center rests the group halfway '
            'down, and start lines up their left edges (in a left-to-right '
            'language).',
        'Pada Column, mainAxisAlignment bekerja secara vertikal dan '
            'crossAxisAlignment secara horizontal: center meletakkan kelompok '
            'itu di tengah ketinggian, dan start menyejajarkan tepi kirinya '
            '(dalam bahasa yang ditulis dari kiri ke kanan).',
      ),
      docs: 'https://docs.flutter.dev/ui/layout',
      mistakes: const [
        Mistake(
          ['MainAxisAlignment.start', 'CrossAxisAlignment.center'],
          Tr(
            'These pull the stones to the top and center them sideways: the '
                'axes are the wrong way round.',
            'Ini menarik batu ke atas dan menengahkannya ke samping: kedua '
                'axis-nya tertukar.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.center', 'CrossAxisAlignment.center'],
          Tr(
            'The stones rest in the middle, but they do not lean yet.',
            'Batu-batu sudah di tengah, tetapi belum condong.',
          ),
        ),
        Mistake(
          [null, 'CrossAxisAlignment.end'],
          Tr(
            'In a left-to-right language, the end of a Column\'s cross axis is '
                'on the right.',
            'Dalam bahasa yang ditulis dari kiri ke kanan, ujung akhir cross '
                'axis sebuah Column ada di kanan.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: _flex(
          Axis.vertical,
          main: v[0] as MainAxisAlignment,
          cross: v[1] as CrossAxisAlignment,
          children: _wide(),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Beneath every Row and Column lies a Flex that knows its direction',
        'Di balik setiap Row dan Column ada sebuah Flex yang tahu arahnya',
      ),
      code: r'''
expect(const Row(children: []).direction, __);
expect(const Column(children: []).direction, __);''',
      answers: ['Axis.horizontal', 'Axis.vertical'],
      verify: () => [
        const Row(children: []).direction,
        const Column(children: []).direction,
      ],
      explanation: const Tr(
        'Row and Column are thin subclasses of Flex that fix its direction. '
            'When the direction is only known at runtime, for example from the '
            'screen width, we can use Flex directly.',
        'Row dan Column adalah subclass tipis dari Flex yang menetapkan '
            'arahnya. Jika arahnya baru diketahui saat runtime, misalnya dari '
            'lebar layar, kita bisa memakai Flex secara langsung.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Flex-class.html',
      mistakes: const [
        Mistake(
          ['Axis.vertical', 'Axis.horizontal'],
          Tr(
            'Swapped. Which way does a Row lay out its children?',
            'Tertukar. Ke arah mana Row menyusun children-nya?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A toolbar: the title on the far left, the actions on the far right, '
            'and the two lines of the title leaning left. Make yours match '
            'the goal',
        'Sebuah toolbar: judul di ujung kiri, tombol aksi di ujung kanan, '
            'dan dua baris judulnya condong ke kiri. Samakan dengan tujuan',
      ),
      code: r'''
Row(
  mainAxisAlignment: __,
  children: [
    Column(
      crossAxisAlignment: __,
      children: [Text('Inbox'), Text('3 new koans')],
    ),
    Row(children: [Icon(Icons.search), Icon(Icons.more_vert)]),
  ],
)''',
      answers: ['MainAxisAlignment.spaceBetween', 'CrossAxisAlignment.start'],
      capstone: true,
      explanation: const Tr(
        'The outer Row works horizontally, so spaceBetween pushes the title '
            'and the actions to opposite edges. The Column\'s cross axis is '
            'horizontal too, so start makes both lines begin at the same left '
            'edge. Rows and Columns nest freely, each with its own pair of '
            'axes.',
        'Row terluar bekerja secara horizontal, sehingga spaceBetween '
            'mendorong judul dan tombol aksi ke tepi yang berseberangan. Cross '
            'axis milik Column juga horizontal, sehingga start membuat kedua '
            'baris dimulai dari tepi kiri yang sama. Row dan Column bisa '
            'saling bersarang, masing-masing dengan pasangan axis-nya sendiri.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout',
      mistakes: const [
        Mistake(
          ['MainAxisAlignment.spaceAround', null],
          Tr(
            'spaceAround leaves half a gap at each edge, so neither group '
                'reaches its side.',
            'spaceAround menyisakan setengah jarak di setiap tepi, sehingga '
                'kedua kelompok tidak sampai ke sisinya.',
          ),
        ),
        Mistake(
          ['MainAxisAlignment.spaceEvenly', null],
          Tr(
            'spaceEvenly puts a gap at the edges too, so neither group reaches '
                'its side.',
            'spaceEvenly juga memberi jarak di tepi, sehingga kedua kelompok '
                'tidak sampai ke sisinya.',
          ),
        ),
        Mistake(
          [null, 'CrossAxisAlignment.stretch'],
          Tr(
            'Inside a Row, a Column may be as wide as it likes, so there is no '
                'edge to stretch to; Flutter would report an error.',
            'Di dalam Row, lebar Column tidak dibatasi, sehingga tidak ada tepi '
                'untuk diraih; Flutter akan melaporkan error.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final main = v[0] as MainAxisAlignment;
        final cross = v[1] as CrossAxisAlignment;
        // A Column inside a Row has unbounded width, so stretch is an error.
        if (cross == CrossAxisAlignment.stretch) {
          throw ArgumentError.value(cross);
        }
        return PreviewCanvas(
          child: Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: main,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: cross,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Inbox',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '3 new koans',
                        style: TextStyle(
                          fontSize: 13,
                          color: kInk.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.search, color: kSky),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.more_vert, color: kSky),
                      ),
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

import 'package:flutter/material.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

Widget _padded(EdgeInsetsGeometry padding) => PreviewCanvas(
  child: Center(
    child: Frame(
      child: Padding(
        padding: padding,
        child: const Box('A', width: 64, height: 64),
      ),
    ),
  ),
);

bool _isNums(List<Object?> v, List<num> expected) {
  for (var i = 0; i < expected.length; i++) {
    if (!isNum(v[i], expected[i])) return false;
  }
  return true;
}

final boxModel = Category(
  id: 'box-model',
  title: const Tr('The Box Model', 'Box Model'),
  intro: const Tr(
    'Every widget is a box, with space inside it and space around it.',
    'Setiap widget adalah sebuah kotak, dengan ruang di dalam dan di '
        'sekelilingnya.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Sometimes the wisest widget is empty space with a size. Leave 40 '
            'pixels of silence between A and B',
        'Terkadang widget paling bijak adalah ruang kosong yang punya ukuran. '
            'Sisakan 40 piksel keheningan di antara A dan B',
      ),
      code: r'''
Column(
  children: [
    Box('A'),
    SizedBox(height: __),
    Box('B'),
  ],
)''',
      answers: ['40'],
      accept: (v) => isNum(v[0], 40),
      explanation: const Tr(
        'A SizedBox with only a height is an invisible gap of exactly that '
            'size, the usual way to space things out in a Column. Row and '
            'Column also accept a spacing parameter that puts the same gap '
            'between every child.',
        'SizedBox yang hanya diberi height adalah celah tak terlihat dengan '
            'ukuran persis itu, cara yang lazim untuk memberi jarak di dalam '
            'Column. Row dan Column juga menerima parameter spacing yang '
            'memberi jarak sama di antara setiap child.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/SizedBox-class.html',
      mistakes: const [
        Mistake(
          ['EdgeInsets.all(40)'],
          Tr(
            'EdgeInsets describes padding around something; a SizedBox simply '
                'takes a number.',
            'EdgeInsets menggambarkan padding di sekeliling sesuatu; SizedBox '
                'cukup menerima sebuah angka.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final gap = px(v[0], max: 90);
        return PreviewCanvas(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Box('A', width: 120, height: 40),
                SizedBox(height: gap),
                const Box('B', width: 120, height: 40),
              ],
            ),
          ),
        );
      },
    ),
    Koan(
      prompt: const Tr(
        'Padding is breathing room. Give A 24 pixels on every side',
        'Padding adalah ruang untuk bernapas. Beri A 24 piksel di setiap '
            'sisi',
      ),
      code: r'''
Padding(
  padding: __,
  child: Box('A'),
)''',
      answers: ['EdgeInsets.all(24)'],
      explanation: const Tr(
        'Padding shrinks the space offered to its child by the insets, then '
            'grows around it by the same amount. EdgeInsets.all(24) puts 24 on '
            'every side, so the whole box is 48 wider and 48 taller than A.',
        'Padding memperkecil ruang yang ditawarkan kepada child-nya sebesar '
            'inset-nya, lalu tumbuh di sekelilingnya dengan jumlah yang sama. '
            'EdgeInsets.all(24) memberi 24 di setiap sisi, sehingga seluruh '
            'kotak 48 lebih lebar dan 48 lebih tinggi daripada A.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Padding-class.html',
      mistakes: const [
        Mistake(
          ['24'],
          Tr(
            'padding expects an EdgeInsets, which says how much goes on each '
                'side, not a bare number.',
            'padding membutuhkan EdgeInsets, yang menyatakan berapa banyak di '
                'setiap sisi, bukan sekadar angka.',
          ),
        ),
        Mistake(
          ['EdgeInsets.symmetric(horizontal: 24)'],
          Tr(
            'That pads only the left and the right; the top and bottom stay '
                'tight.',
            'Itu hanya memberi padding di kiri dan kanan; bagian atas dan '
                'bawah tetap rapat.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _padded(v[0] as EdgeInsetsGeometry),
    ),
    Koan(
      prompt: const Tr(
        'Breathe wide, not tall: 32 to the left and right, 8 above and below',
        'Bernapaslah melebar, bukan meninggi: 32 di kiri dan kanan, 8 di '
            'atas dan bawah',
      ),
      code: r'''
Padding(
  padding: __,
  child: Box('A'),
)''',
      answers: ['EdgeInsets.symmetric(horizontal: 32, vertical: 8)'],
      explanation: const Tr(
        'EdgeInsets.symmetric sets mirrored pairs: horizontal goes on the left '
            'and the right, vertical on the top and the bottom. It is the same '
            'as EdgeInsets.fromLTRB(32, 8, 32, 8), only easier to read.',
        'EdgeInsets.symmetric mengatur pasangan yang saling bercermin: '
            'horizontal untuk kiri dan kanan, vertical untuk atas dan bawah. '
            'Hasilnya sama dengan EdgeInsets.fromLTRB(32, 8, 32, 8), hanya '
            'lebih mudah dibaca.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/EdgeInsets/EdgeInsets.symmetric.html',
      mistakes: const [
        Mistake(
          ['EdgeInsets.symmetric(horizontal: 8, vertical: 32)'],
          Tr(
            'Swapped: horizontal is the left and right, which should be the '
                'wide ones.',
            'Tertukar: horizontal adalah kiri dan kanan, yang seharusnya '
                'lebih lebar.',
          ),
        ),
        Mistake(
          ['EdgeInsets.all(32)'],
          Tr(
            'That is the same on every side; the goal is wider than it is '
                'tall.',
            'Itu sama di setiap sisi; tujuannya lebih lebar daripada '
                'tingginya.',
          ),
        ),
      ],
      hint: const Tr(
        'There is an EdgeInsets constructor for mirrored sides.',
        'Ada constructor EdgeInsets untuk sisi yang saling berhadapan.',
      ),
      registry: flutterRegistry,
      preview: (v) => _padded(v[0] as EdgeInsetsGeometry),
    ),
    Koan(
      prompt: const Tr(
        'Indent only where it matters: 40 on the left, nothing elsewhere',
        'Beri jarak hanya di tempat yang perlu: 40 di kiri, tidak ada di '
            'sisi lain',
      ),
      code: r'''
Padding(
  padding: __,
  child: Box('A'),
)''',
      answers: ['EdgeInsets.only(left: 40)'],
      explanation: const Tr(
        'EdgeInsets.only sets just the sides we name, and the rest are 0. In '
            'apps that may run right-to-left, EdgeInsetsDirectional.only(start: '
            '40) follows the reading direction instead.',
        'EdgeInsets.only hanya mengatur sisi yang kita sebutkan, sisanya 0. '
            'Untuk aplikasi yang mungkin berjalan dari kanan ke kiri, '
            'EdgeInsetsDirectional.only(start: 40) mengikuti arah baca.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/EdgeInsets/EdgeInsets.only.html',
      mistakes: const [
        Mistake(
          ['EdgeInsets.symmetric(horizontal: 40)'],
          Tr(
            'symmetric pads the right as well as the left.',
            'symmetric memberi padding di kanan juga, bukan hanya di kiri.',
          ),
        ),
        Mistake(
          ['EdgeInsets.all(40)'],
          Tr(
            'That pads every side, not only where it matters.',
            'Itu memberi padding di setiap sisi, bukan hanya di tempat yang '
                'perlu.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => _padded(v[0] as EdgeInsetsGeometry),
    ),
    Koan(
      prompt: const Tr(
        'Symmetric insets mirror each other; horizontal is the sum of both '
            'sides',
        'Inset simetris saling bercermin; horizontal adalah jumlah kedua '
            'sisinya',
      ),
      code: r'''
const insets = EdgeInsets.symmetric(horizontal: 10);
expect(insets.left, __);
expect(insets.horizontal, __);''',
      answers: ['10.0', '20.0'],
      verify: () {
        const insets = EdgeInsets.symmetric(horizontal: 10);
        return [insets.left, insets.horizontal];
      },
      accept: (v) => _isNums(v, [10, 20]),
      explanation: const Tr(
        'symmetric(horizontal: 10) sets left and right to 10.0 each, since '
            'insets are doubles. The horizontal getter is the total of both '
            'sides, 20.0, which is handy when working out how much width the '
            'padding uses up.',
        'symmetric(horizontal: 10) mengisi left dan right masing-masing '
            '10.0, karena inset bertipe double. Getter horizontal adalah total '
            'kedua sisinya, 20.0, yang berguna untuk menghitung berapa lebar '
            'yang terpakai oleh padding.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/EdgeInsetsGeometry/horizontal.html',
      mistakes: const [
        Mistake(
          [null, '10'],
          Tr(
            'horizontal is not one side, but the sum of both.',
            'horizontal bukan satu sisi, melainkan jumlah kedua sisinya.',
          ),
        ),
        Mistake(
          [null, '10.0'],
          Tr(
            'horizontal is not one side, but the sum of both.',
            'horizontal bukan satu sisi, melainkan jumlah kedua sisinya.',
          ),
        ),
        Mistake(
          ['5', null],
          Tr(
            'The 10 is not split in two; each side gets all of it.',
            'Angka 10 tidak dibagi dua; setiap sisi mendapat seluruhnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A Container can be given a size and a color. Shape a teal box, '
            '120 wide and 60 tall',
        'Container bisa diberi ukuran dan warna. Bentuklah kotak berwarna '
            'teal, lebar 120 dan tinggi 60',
      ),
      code: r'''
Container(
  width: __,
  height: __,
  color: __,
)''',
      answers: ['120', '60', 'Colors.teal'],
      accept: (v) => _isNums(v, [120, 60]) && v[2] == Colors.teal,
      explanation: const Tr(
        'A Container gathers sizing, padding, color and decoration into one '
            'widget. width and height become tight constraints, as long as '
            'the parent allows them, and color is shorthand for a '
            'BoxDecoration with that color.',
        'Container menggabungkan ukuran, padding, warna, dan dekorasi dalam '
            'satu widget. width dan height menjadi constraint yang pasti, '
            'selama parent-nya mengizinkan, dan color adalah singkatan untuk '
            'BoxDecoration dengan warna tersebut.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Container-class.html',
      mistakes: const [
        Mistake(
          ['60', '120', null],
          Tr(
            'Width and height are swapped: the goal is wider than it is tall.',
            'Lebar dan tinggi tertukar: tujuannya lebih lebar daripada '
                'tingginya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Container(
            width: px(v[0], max: 256),
            height: px(v[1], max: 176),
            color: v[2] as Color,
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Margin keeps the world away; padding keeps the content comfortable. '
            'Give 32 outside the amber and 8 inside it',
        'Margin menjaga jarak dari sekitarnya; padding membuat isinya '
            'lapang. Beri 32 di luar warna amber dan 8 di dalamnya',
      ),
      code: r'''
Container(
  margin: __,
  padding: __,
  color: Colors.amber,
  child: Text('koan'),
)''',
      answers: ['EdgeInsets.all(32)', 'EdgeInsets.all(8)'],
      hint: const Tr(
        'The color fills the padding, but never the margin.',
        'Warna mengisi area padding, tetapi tidak pernah area margin.',
      ),
      explanation: const Tr(
        'margin is space outside the Container\'s decoration, and padding is '
            'space inside it, between the decoration and the child. So the '
            'amber fills the 8 around the text, while the 32 outside stays '
            'empty.',
        'margin adalah ruang di luar dekorasi Container, sedangkan padding '
            'adalah ruang di dalamnya, di antara dekorasi dan child. Jadi warna '
            'amber mengisi 8 di sekitar teks, sementara 32 di luarnya tetap '
            'kosong.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Container/margin.html',
      mistakes: const [
        Mistake(
          ['EdgeInsets.all(8)', 'EdgeInsets.all(32)'],
          Tr(
            'Swapped: the amber would grow thick around the text, with only a '
                'thin gap outside it.',
            'Tertukar: warna amber akan menebal di sekitar teks, dengan celah '
                'tipis saja di luarnya.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Frame(
            child: Container(
              margin: v[0] as EdgeInsetsGeometry,
              padding: v[1] as EdgeInsetsGeometry,
              color: Colors.amber,
              child: const Text('koan'),
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Even a box may soften its corners. Round them by 24',
        'Kotak pun bisa melembutkan sudutnya. Bulatkan sebesar 24',
      ),
      code: r'''
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    color: Colors.indigo,
    borderRadius: __,
  ),
)''',
      answers: ['BorderRadius.circular(24)'],
      explanation: const Tr(
        'BorderRadius.circular(24) gives all four corners a radius of 24. The '
            'decoration paints rounded, but does not clip the child; for that '
            'we use ClipRRect or the Container\'s clipBehavior.',
        'BorderRadius.circular(24) memberi keempat sudut radius 24. Dekorasi '
            'digambar membulat, tetapi tidak memotong child-nya; untuk itu kita '
            'memakai ClipRRect atau clipBehavior milik Container.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/BoxDecoration/borderRadius.html',
      mistakes: const [
        Mistake(
          ['Radius.circular(24)'],
          Tr(
            'A Radius describes a single corner; borderRadius wants all four '
                'of them.',
            'Radius hanya menggambarkan satu sudut; borderRadius membutuhkan '
                'keempatnya.',
          ),
        ),
        Mistake(
          ['24'],
          Tr(
            'borderRadius needs a value that describes every corner, not a '
                'bare number.',
            'borderRadius membutuhkan nilai yang menggambarkan setiap sudut, '
                'bukan sekadar angka.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: v[0] as BorderRadiusGeometry,
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'Not every box has corners. Make yours match the goal',
        'Tidak semua kotak punya sudut. Samakan dengan tujuan',
      ),
      code: r'''
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    color: Colors.indigo,
    shape: __,
  ),
)''',
      answers: ['BoxShape.circle'],
      explanation: const Tr(
        'BoxShape.circle paints the decoration as a circle as wide as the '
            'box\'s shortest side, which suits avatars and dots. A circle has '
            'no corners, so it cannot be combined with a borderRadius.',
        'BoxShape.circle menggambar dekorasi sebagai lingkaran selebar sisi '
            'terpendek kotaknya, cocok untuk avatar dan titik. Lingkaran tidak '
            'punya sudut, sehingga tidak bisa digabung dengan borderRadius.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/BoxShape.html',
      mistakes: const [
        Mistake(
          ['BoxShape.rectangle'],
          Tr(
            'That is the default shape, and it keeps its corners.',
            'Itu bentuk default, dan sudut-sudutnya tetap ada.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.indigo,
              shape: v[0] as BoxShape,
            ),
          ),
        ),
      ),
    ),
    Koan(
      prompt: const Tr(
        'A contact card: 16 of breathing room inside, corners rounded by 24, '
            'and a round avatar. Make yours match the goal',
        'Sebuah kartu kontak: ruang bernapas 16 di dalamnya, sudut yang '
            'dibulatkan sebesar 24, dan avatar yang bundar. Samakan dengan '
            'tujuan',
      ),
      code: r'''
Container(
  padding: __,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: __,
  ),
  child: Row(children: [
    Avatar(shape: __),
    SizedBox(width: 12),
    Text('Ratu'),
  ]),
)''',
      answers: [
        'EdgeInsets.all(16)',
        'BorderRadius.circular(24)',
        'BoxShape.circle',
      ],
      capstone: true,
      explanation: const Tr(
        'One Container holds the whole box model: padding inside the white '
            'decoration, a BorderRadius for all its corners, and a SizedBox '
            'gap between the children. The avatar is another decoration, '
            'painted as a circle instead of a rectangle.',
        'Satu Container memuat seluruh box model: padding di dalam dekorasi '
            'putih, BorderRadius untuk semua sudutnya, dan celah SizedBox di '
            'antara children. Avatar adalah dekorasi lain, yang digambar '
            'sebagai lingkaran, bukan persegi panjang.',
      ),
      docs: 'https://api.flutter.dev/flutter/painting/BoxDecoration-class.html',
      mistakes: const [
        Mistake(
          ['EdgeInsets.all(24)', 'BorderRadius.circular(16)', null],
          Tr(
            'The two numbers have traded places: one is room inside, the other '
                'is the roundness of the corners.',
            'Kedua angka itu bertukar tempat: yang satu ruang di dalam, yang '
                'lain kebulatan sudutnya.',
          ),
        ),
        Mistake(
          [null, 'Radius.circular(24)', null],
          Tr(
            'A Radius describes a single corner; borderRadius wants all four '
                'of them.',
            'Radius hanya menggambarkan satu sudut; borderRadius membutuhkan '
                'keempatnya.',
          ),
        ),
        Mistake(
          [null, null, 'BoxShape.rectangle'],
          Tr(
            'The avatar keeps its corners; in the goal it has none.',
            'Avatar masih punya sudut; pada tujuan, ia tidak punya sudut sama '
                'sekali.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) {
        final padding = insetsOf(v[0]);
        final radius = v[1] as BorderRadiusGeometry;
        final shape = v[2] as BoxShape;
        return PreviewCanvas(
          child: Center(
            child: Container(
              width: 220,
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
                border: Border.all(color: kInk.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Avatar(shape: shape, color: kSage),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Ratu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

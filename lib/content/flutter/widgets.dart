import 'package:flutter/widgets.dart';

import '../../engine/koan.dart';
import 'preview_kit.dart';
import 'registry.dart';

final widgets = Category(
  id: 'widgets',
  title: const Tr('Widgets', 'Widget'),
  intro: const Tr(
    'In Flutter, everything we see begins as a widget.',
    'Di Flutter, semua yang kita lihat berawal dari sebuah widget.',
  ),
  koans: [
    Koan(
      prompt: const Tr(
        'Even a single word on the screen is a widget',
        'Bahkan satu kata di layar pun adalah sebuah widget',
      ),
      code: r'''
const greeting = Text('Hello');
expect(greeting is Widget, __);''',
      answers: ['true'],
      verify: () => [_text('Hello') is Widget],
      explanation: const Tr(
        'Text extends StatelessWidget, which extends Widget. Padding, '
            'buttons and the whole app are widgets too, so Flutter needs only '
            'one idea to describe an entire screen.',
        'Text adalah turunan StatelessWidget, yang merupakan turunan Widget. '
            'Padding, tombol, bahkan seluruh aplikasi juga widget, sehingga '
            'Flutter cukup memakai satu konsep untuk menggambarkan satu layar '
            'penuh.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Widget-class.html',
      mistakes: const [
        Mistake(
          ['false'],
          Tr(
            'Text may look like plain data, but follow its class upward: '
                'what does it extend in the end?',
            'Text mungkin terlihat seperti data biasa, tetapi telusuri '
                'class-nya ke atas: pada akhirnya ia turunan dari apa?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A widget with nothing to remember is stateless',
        'Widget yang tidak perlu mengingat apa pun bersifat stateless',
      ),
      code: r'''
class Greeting extends __ {
  const Greeting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hello, koan');
  }
}''',
      answers: ['StatelessWidget'],
      explanation: const Tr(
        'A StatelessWidget only has to build: what it shows depends on its '
            'own fields and on what it reads from context. Anything that '
            'changes over time belongs in the State of a StatefulWidget.',
        'StatelessWidget hanya perlu build: tampilannya bergantung pada '
            'field miliknya dan apa yang ia baca dari context. Apa pun yang '
            'berubah seiring waktu harus disimpan di State milik '
            'StatefulWidget.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html',
      mistakes: const [
        Mistake(
          ['StatefulWidget'],
          Tr(
            'A StatefulWidget does not build by itself; it creates a State '
                'that builds for it. This class builds directly and remembers '
                'nothing.',
            'StatefulWidget tidak melakukan build sendiri; ia membuat State '
                'yang melakukan build untuknya. Class ini melakukan build '
                'langsung dan tidak mengingat apa pun.',
          ),
        ),
        Mistake(
          ['Widget'],
          Tr(
            'Widget itself has no build method to override. Which subclass '
                'adds one?',
            'Widget sendiri tidak punya method build untuk di-override. '
                'Subclass mana yang menambahkannya?',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A widget describes itself in one method, called whenever Flutter '
            'needs to know how it looks',
        'Sebuah widget menggambarkan dirinya lewat satu method, yang '
            'dipanggil setiap kali Flutter perlu tahu tampilannya',
      ),
      code: r'''
class Badge extends StatelessWidget {
  const Badge({super.key});

  @override
  Widget __(__ context) {
    return const Text('koan');
  }
}''',
      answers: ['build', 'BuildContext'],
      hint: const Tr(
        'The second blank is the type that tells a widget where it stands '
            'in the tree.',
        'Bagian kedua adalah tipe yang memberi tahu widget di mana posisinya '
            'di dalam tree.',
      ),
      explanation: const Tr(
        'build may run many times: when the parent rebuilds, or when '
            'something it reads from context changes. So it should be fast '
            'and free of side effects. The BuildContext is the widget\'s place '
            'in the tree, which is how Theme.of(context) finds the nearest '
            'Theme.',
        'build bisa dijalankan berkali-kali: saat parent-nya build ulang, '
            'atau saat sesuatu yang ia baca dari context berubah. Karena itu '
            'build harus cepat dan bebas efek samping. BuildContext adalah '
            'posisi widget di dalam tree, dan lewat itulah Theme.of(context) '
            'menemukan Theme terdekat.',
      ),
      docs:
          'https://api.flutter.dev/flutter/widgets/StatelessWidget/build.html',
      mistakes: const [
        Mistake(
          ['createState', null],
          Tr(
            'createState belongs to StatefulWidget, and returns a State rather '
                'than a widget. This one describes how it looks.',
            'createState milik StatefulWidget, dan mengembalikan State, bukan '
                'widget. Method ini menggambarkan tampilannya.',
          ),
        ),
        Mistake(
          [null, 'Widget'],
          Tr(
            'The parameter is not a widget, but the widget\'s place in the '
                'tree.',
            'Parameter ini bukan widget, melainkan posisi widget di dalam '
                'tree.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A widget is only a description; it remembers what it was told',
        'Widget hanyalah sebuah deskripsi; ia mengingat apa yang diberikan '
            'kepadanya',
      ),
      code: r'''
const label = Text('hi');
expect(label.data, __);''',
      answers: ["'hi'"],
      verify: () => [const Text('hi').data],
      explanation: const Tr(
        'A widget is a light, immutable object that holds its configuration. '
            'Text keeps its string in data; drawing it is the job of the '
            'elements and render objects that Flutter creates from the widget.',
        'Widget adalah objek ringan dan immutable yang menyimpan '
            'konfigurasinya. Text menyimpan string-nya di data; '
            'menggambarnya adalah tugas element dan render object yang dibuat '
            'Flutter dari widget tersebut.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Text/data.html',
      mistakes: const [
        Mistake(
          ['hi'],
          Tr(
            'Without quotes, hi is a name, not a string.',
            'Tanpa tanda kutip, hi adalah sebuah nama, bukan string.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Widgets are immutable: to change one, Flutter builds a new one',
        'Widget bersifat immutable: untuk mengubahnya, Flutter membuat widget '
            'yang baru',
      ),
      code: r'''
class Tag extends StatelessWidget {
  const Tag(this.name, {super.key});

  __ String name;

  @override
  Widget build(BuildContext context) => Text(name);
}''',
      answers: ['final'],
      explanation: const Tr(
        'Widget is marked @immutable, so the analyzer warns about any field '
            'that is not final. To show a new name, the parent builds a new '
            'Tag; values that change on their own belong in a State.',
        'Widget ditandai @immutable, sehingga analyzer memberi peringatan '
            'untuk setiap field yang tidak final. Untuk menampilkan nama baru, '
            'parent membuat Tag yang baru; nilai yang berubah dengan sendirinya '
            'disimpan di State.',
      ),
      docs: 'https://api.flutter.dev/flutter/widgets/Widget-class.html',
      mistakes: const [
        Mistake(
          ['var'],
          Tr(
            'A var field could be reassigned after the widget is built, and '
                'widgets promise never to change.',
            'Field var bisa diubah setelah widget dibuat, padahal widget '
                'berjanji tidak akan pernah berubah.',
          ),
        ),
        Mistake(
          ['const'],
          Tr(
            'An instance field cannot be const in Dart; only static fields '
                'can. Each Tag has its own name, set once.',
            'Di Dart, field instance tidak bisa const; hanya field static '
                'yang bisa. Setiap Tag punya name sendiri, yang diisi sekali.',
          ),
        ),
        Mistake(
          ['late'],
          Tr(
            'late delays when a field is set, but a late field without '
                'another keyword can still be reassigned.',
            'late menunda kapan field diisi, tetapi field late tanpa kata '
                'kunci lain tetap bisa diubah.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'When every field is final, a widget may be born before the app runs',
        'Jika semua field-nya final, sebuah widget bisa lahir bahkan sebelum '
            'aplikasi berjalan',
      ),
      code: r'''
class Dot extends StatelessWidget {
  __ Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 8, height: 8);
  }
}''',
      answers: ['const'],
      hint: const Tr(
        'The keyword that makes a value a compile-time constant.',
        'Kata kunci yang menjadikan sebuah nilai konstanta saat kompilasi.',
      ),
      explanation: const Tr(
        'A const constructor lets callers write const Dot(): the instance is '
            'created at compile time, and every const Dot() is the very same '
            'object. That requires final fields and a const super '
            'constructor.',
        'Constructor const memungkinkan pemanggil menulis const Dot(): '
            'instance-nya dibuat saat kompilasi, dan setiap const Dot() '
            'adalah objek yang sama persis. Syaratnya, semua field harus final '
            'dan constructor super-nya juga const.',
      ),
      docs: 'https://dart.dev/language/constructors#constant-constructors',
      mistakes: const [
        Mistake(
          ['final'],
          Tr(
            'final marks variables and fields, not constructors.',
            'final dipakai untuk variabel dan field, bukan constructor.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A const subtree is made once and shared, so Flutter need not '
            'rebuild it',
        'Subtree yang const dibuat sekali lalu dipakai bersama, sehingga '
            'Flutter tidak perlu membangunnya ulang',
      ),
      code: r'''
@override
Widget build(BuildContext context) {
  return __ Padding(
    padding: EdgeInsets.all(8),
    child: Text('still'),
  );
}''',
      answers: ['const'],
      explanation: const Tr(
        'One const covers the whole expression, so EdgeInsets.all(8) and '
            'Text(\'still\') become const too. When Flutter meets the very '
            'same widget object as last time, it can skip rebuilding that '
            'subtree.',
        'Satu const mencakup seluruh ekspresi, sehingga EdgeInsets.all(8) '
            'dan Text(\'still\') ikut menjadi const. Saat Flutter menemukan '
            'objek widget yang sama persis dengan sebelumnya, ia bisa '
            'melewati build ulang subtree tersebut.',
      ),
      docs: 'https://docs.flutter.dev/perf/best-practices#control-build-cost',
      mistakes: const [
        Mistake(
          ['final'],
          Tr(
            'final declares a variable; it cannot stand in front of an '
                'expression.',
            'final mendeklarasikan variabel; ia tidak bisa diletakkan di '
                'depan sebuah ekspresi.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Some widgets hold a single child; others hold many children',
        'Ada widget yang hanya memegang satu child; ada pula yang memegang '
            'banyak children',
      ),
      code: r'''
Center(
  __: Text('one'),
)

Column(
  __: [Text('one'), Text('two')],
)''',
      answers: ['child', 'children'],
      explanation: const Tr(
        'Widgets that wrap one widget, like Center, Padding and Align, take '
            'child. Widgets that arrange several, like Row, Column and Stack, '
            'take a list called children. The convention holds all across '
            'Flutter.',
        'Widget yang membungkus satu widget, seperti Center, Padding, dan '
            'Align, menerima child. Widget yang menyusun beberapa widget, '
            'seperti Row, Column, dan Stack, menerima list bernama children. '
            'Konvensi ini berlaku di seluruh Flutter.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout',
      mistakes: const [
        Mistake(
          ['children', 'child'],
          Tr(
            'Look at the brackets: which of the two receives a list?',
            'Perhatikan kurung sikunya: mana dari keduanya yang menerima '
                'list?',
          ),
        ),
        Mistake(
          ['child', 'child'],
          Tr(
            'A Column holds a whole list, and the name of the parameter says '
                'so.',
            'Column memegang satu list utuh, dan nama parameternya pun '
                'menunjukkan hal itu.',
          ),
        ),
        Mistake(
          ['children', 'children'],
          Tr(
            'Center has room for only one widget, and the name of the '
                'parameter says so.',
            'Center hanya punya tempat untuk satu widget, dan nama '
                'parameternya pun menunjukkan hal itu.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'Widgets nest within widgets, forming a tree; follow the branch to '
            'reach the leaf',
        'Widget bersarang di dalam widget hingga membentuk tree; telusuri '
            'cabangnya untuk sampai ke daun',
      ),
      code: r'''
const tree = Padding(
  padding: EdgeInsets.all(8),
  child: Text('leaf'),
);
expect((tree.child as Text).data, __);''',
      answers: ["'leaf'"],
      verify: () {
        const tree = Padding(padding: EdgeInsets.all(8), child: Text('leaf'));
        return [(tree.child! as Text).data];
      },
      explanation: const Tr(
        'A widget tree is just objects inside objects: tree.child is the '
            'Text, and its data is the string. Flutter walks this description '
            'to create the elements and render objects that actually lay out '
            'and paint.',
        'Widget tree hanyalah objek di dalam objek: tree.child adalah Text, '
            'dan data-nya adalah string tersebut. Flutter menelusuri deskripsi '
            'ini untuk membuat element dan render object yang benar-benar '
            'mengatur tata letak dan menggambar.',
      ),
      docs: 'https://docs.flutter.dev/resources/architectural-overview#composition',
      mistakes: const [
        Mistake(
          ["'Padding'"],
          Tr(
            'Padding is the branch we start from; the cast follows its child.',
            'Padding adalah cabang tempat kita mulai; cast-nya mengikuti '
                'child-nya.',
          ),
        ),
      ],
      registry: flutterRegistry,
    ),
    Koan(
      prompt: const Tr(
        'A profile card is a small tree of widgets: the avatar beside the '
            'words, the name above the role. Make yours match the goal',
        'Kartu profil adalah tree kecil berisi widget: avatar di samping '
            'tulisan, nama di atas peran. Samakan dengan tujuan',
      ),
      code: r'''
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const __(children: [
      Avatar(),
      __(children: [Text('Ratu'), Text('Gardener')]),
    ]);
  }
}''',
      answers: ['Row', 'Column'],
      capstone: true,
      explanation: const Tr(
        'Screens are built by composing small widgets: a Row holds the avatar '
            'and a Column, and the Column holds two Texts. Because the whole '
            'tree is const and the class remembers nothing, ProfileCard can '
            'be a StatelessWidget that Flutter rarely needs to rebuild.',
        'Layar dibangun dengan menyusun widget-widget kecil: Row memegang '
            'avatar dan sebuah Column, dan Column memegang dua Text. Karena '
            'seluruh tree-nya const dan class-nya tidak mengingat apa pun, '
            'ProfileCard bisa menjadi StatelessWidget yang jarang perlu di-build '
            'ulang oleh Flutter.',
      ),
      docs: 'https://docs.flutter.dev/ui/layout',
      mistakes: const [
        Mistake(
          ['Column', 'Row'],
          Tr(
            'The outer widget should set the avatar beside the words, and the '
                'inner one should set the name above the role. Which runs '
                'which way?',
            'Widget terluar seharusnya menaruh avatar di samping tulisan, dan '
                'widget di dalamnya menaruh nama di atas peran. Mana yang '
                'mengarah ke mana?',
          ),
        ),
        Mistake(
          [null, 'Row'],
          Tr(
            'The name and the role now sit side by side; in the goal one rests '
                'above the other.',
            'Nama dan peran kini duduk berdampingan; pada tujuan, yang satu '
                'berada di atas yang lain.',
          ),
        ),
        Mistake(
          ['Stack', null],
          Tr(
            'A Stack lays its children over one another, so the words cover '
                'the avatar.',
            'Stack menumpuk children-nya satu di atas yang lain, sehingga '
                'tulisan menutupi avatar.',
          ),
        ),
      ],
      registry: flutterRegistry,
      preview: (v) => PreviewCanvas(
        child: Center(child: _profile(_layout(v[0]), _layout(v[1]))),
      ),
    ),
  ],
);

// Typed as Object so the analyzer does not call the type check unnecessary.
Object _text(String data) => Text(data);

/// Lays out children the way the widget type [type] would.
Widget Function(List<Widget>) _layout(Object? type) => switch (type) {
  const (Row) => (c) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 10,
    children: c,
  ),
  const (Column) => (c) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: c,
  ),
  const (Stack) => (c) => Stack(children: c),
  _ => throw ArgumentError.value(type),
};

Widget _profile(
  Widget Function(List<Widget>) outer,
  Widget Function(List<Widget>) inner,
) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color(0xFFFFFFFF),
    borderRadius: BorderRadius.circular(14),
  ),
  child: outer([
    const Avatar(size: 56),
    inner(const [
      Text('Ratu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      Text(
        'Gardener',
        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      ),
    ]),
  ]),
);
